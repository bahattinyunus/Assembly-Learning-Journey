; ============================================================
; branch_opt.asm - Branch Prediction ve Branchless Kodlama
; Platform: Linux x86-64
; ============================================================
;
; Modern CPU'larda branch prediction kritik performans faktörüdür.
; Yanlış tahmin edilen her branch ~15-20 cycle kaybettirir.
; Çözüm: Branchless (dalsız) kod yazmak.
; ============================================================

section .data
    array_mixed db 5, 2, 8, 1, 9, 3, 7, 4, 6, 0

section .bss
    result  resq 1
    sorted  resb 10

section .text
    global _start

; ============================================================
; Abs değer - Branch'li versiyon
; ============================================================
abs_branchy:
    push rbp
    mov  rbp, rsp
    test rdi, rdi
    jns  .positive
    neg  rdi
.positive:
    mov  rax, rdi
    pop  rbp
    ret

; ============================================================
; Abs değer - Branchless (SAR + XOR trick)
; Her zaman sabit sürede çalışır, pipeline stall yok
; ============================================================
abs_branchless:
    push rbp
    mov  rbp, rsp

    mov  rax, rdi
    ; 1. İşaret bitini 63 bit sağa kaydır → hepsi 0 veya hepsi 1
    mov  rdx, rdi
    sar  rdx, 63           ; negatifse: 0xFFFFFFFFFFFFFFFF, pozitifse: 0x0
    ; 2. XOR ile işaret bitine göre tersle
    xor  rax, rdx
    ; 3. Eğer negatifse (rdx=0xFF..), +1 ekle (two's complement)
    sub  rax, rdx
    ; Sonuç: |rdi|

    pop rbp
    ret

; ============================================================
; Min değer - Branch'li versiyon
; ============================================================
min_branchy:
    push rbp
    mov  rbp, rsp
    ; rdi = a, rsi = b
    cmp  rdi, rsi
    jle  .a_smaller
    mov  rax, rsi
    jmp  .done
.a_smaller:
    mov  rax, rdi
.done:
    pop rbp
    ret

; ============================================================
; Min değer - Branchless (CMOV - Conditional Move)
; CMOV pipeline'ı bozmaz, koşullu register move
; ============================================================
min_branchless:
    push rbp
    mov  rbp, rsp
    ; rdi = a, rsi = b
    mov  rax, rdi
    cmp  rdi, rsi
    cmovg rax, rsi         ; if a > b: rax = b
    ; CMOVG = Conditional Move if Greater
    ; Diğerleri: CMOVL, CMOVE, CMOVGE, CMOVLE, CMOVNE...

    pop rbp
    ret

; ============================================================
; Clamp(x, lo, hi) - Branchless
; Sonuç: lo <= x <= hi aralığında x değeri
; ============================================================
clamp_branchless:
    push rbp
    mov  rbp, rsp
    ; rdi=x, rsi=lo, rdx=hi
    mov  rax, rdi
    cmp  rax, rsi
    cmovl rax, rsi         ; x < lo ise rax = lo
    cmp   rax, rdx
    cmovg rax, rdx         ; x > hi ise rax = hi
    pop rbp
    ret

; ============================================================
; Bit Manipulation Tricks
; ============================================================
bit_tricks:
    push rbp
    mov  rbp, rsp

    mov rax, rdi

    ; 1. En düşük set biti sıfırla: x & (x-1)
    ; Popcount / Hamming weight için kullanışlı
    mov rbx, rax
    dec rbx
    and rax, rbx            ; Artık en düşük 1-bit temizlendi

    ; 2. En düşük set bitin izolasyonu: x & (-x)
    mov rax, rdi
    neg rbx
    and rax, rdi            ; Sadece en düşük 1-bit kalır

    ; 3. 2'nin kuvveti mi? x != 0 && (x & x-1) == 0
    mov rax, rdi
    dec rax
    test rdi, rax
    sete al                 ; al = 1 ise 2'nin kuvveti (NOT!)
    xor  al, 1              ; tersle
    movzx rax, al

    ; 4. Swap (XOR swap - extra register olmadan)
    ; a ^= b; b ^= a; a ^= b;
    mov rax, 10
    mov rbx, 20
    xor rax, rbx
    xor rbx, rax
    xor rax, rbx            ; rax=20, rbx=10

    pop rbp
    ret

_start:
    ; abs_branchless(-42) test
    mov rdi, -42
    call abs_branchless     ; RAX = 42

    ; min_branchless(15, 7) test
    mov rdi, 15
    mov rsi, 7
    call min_branchless     ; RAX = 7

    ; clamp_branchless(x=150, lo=0, hi=100) test
    mov rdi, 150
    mov rsi, 0
    mov rdx, 100
    call clamp_branchless   ; RAX = 100

    mov [result], rax

    mov rax, 60
    mov rdi, 0
    syscall
