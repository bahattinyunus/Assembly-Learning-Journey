; ============================================================
; loop_unrolling.asm - Döngü Optimizasyonu
; Platform: Linux x86-64
; ============================================================
;
; Loop Unrolling: Döngü overhead'ini (cmp+jmp) azaltmak için
; döngü gövdesini katlamak. CPU'nun out-of-order execution
; ve instruction-level parallelism özelliklerinden yararlanır.
; ============================================================

section .data
    array       times 64 dq 1      ; 64 elemanlı qword dizi, hepsi 1

section .bss
    result      resq 1

section .text
    global _start

; ============================================================
; Normal döngü: dizi elemanlarını topla
; Her iteration 1 element işler
; ============================================================
sum_normal:
    push rbp
    mov  rbp, rsp

    lea  rsi, [rel array]
    xor  rax, rax           ; toplam = 0
    xor  rcx, rcx           ; i = 0
    mov  r9,  64            ; N = 64

.loop:
    add  rax, [rsi + rcx * 8]
    inc  rcx
    cmp  rcx, r9
    jl   .loop              ; 64 kez cmp+jmp = 64 overhead

    pop rbp
    ret

; ============================================================
; Unrolled döngü: 4x unroll
; Her iteration 4 element işler → 1/4 branch overhead
; ============================================================
sum_unrolled_4x:
    push rbp
    mov  rbp, rsp

    lea  rsi, [rel array]
    xor  rax, rax           ; toplam = 0
    xor  rcx, rcx           ; i = 0
    mov  r9,  64            ; N = 64

.loop:
    ; 4 element aynı anda işle
    add  rax, [rsi + rcx * 8]      ; i+0
    add  rax, [rsi + rcx * 8 + 8]  ; i+1
    add  rax, [rsi + rcx * 8 + 16] ; i+2
    add  rax, [rsi + rcx * 8 + 24] ; i+3
    add  rcx, 4
    cmp  rcx, r9
    jl   .loop              ; 16 kez cmp+jmp (4x daha az)

    pop rbp
    ret

; ============================================================
; Daha ileri: Birden fazla accumulator kullan
; CPU farklı accumulator'ları paralel hesaplayabilir
; (dependency chain'leri kırar)
; ============================================================
sum_parallel_acc:
    push rbp
    mov  rbp, rsp

    lea  rsi, [rel array]
    xor  rax, rax           ; acc0
    xor  rbx, rbx           ; acc1
    xor  rcx, rcx           ; acc2
    xor  rdx, rdx           ; acc3
    xor  r8,  r8            ; i = 0
    mov  r9,  64

.loop:
    ; 4 bağımsız accumulator → CPU bunları paralel çalıştırabilir
    add  rax, [rsi + r8 * 8]       ; acc0 += a[i+0]
    add  rbx, [rsi + r8 * 8 + 8]   ; acc1 += a[i+1]
    add  rcx, [rsi + r8 * 8 + 16]  ; acc2 += a[i+2]
    add  rdx, [rsi + r8 * 8 + 24]  ; acc3 += a[i+3]
    add  r8,  4
    cmp  r8,  r9
    jl   .loop

    ; Sonuçları birleştir
    add  rax, rbx
    add  rcx, rdx
    add  rax, rcx

    pop rbp
    ret

; ============================================================
; Duff's Device: Assembly'de unroll + switch birleşimi
; Kalan elemanları yönetmek için
; ============================================================
; (N her zaman 4'ün katı olmayabilir)
sum_with_remainder:
    push rbp
    mov  rbp, rsp
    push rbx

    lea  rsi, [rel array]
    xor  rax, rax
    mov  rbx, 64            ; N

    ; Kalan = N % 4
    mov  rcx, rbx
    and  rcx, 3             ; rcx = N mod 4

    ; Önce kalan elemanları işle
    test rcx, rcx
    jz   .main_loop_setup

.remainder_loop:
    dec  rbx
    add  rax, [rsi + rbx * 8]
    dec  rcx
    jnz  .remainder_loop

.main_loop_setup:
    ; Şimdi rbx, 4'ün katı
    test rbx, rbx
    jz   .done

.main_loop:
    sub  rbx, 4
    add  rax, [rsi + rbx * 8]
    add  rax, [rsi + rbx * 8 + 8]
    add  rax, [rsi + rbx * 8 + 16]
    add  rax, [rsi + rbx * 8 + 24]
    jnz  .main_loop

.done:
    pop rbx
    pop rbp
    ret

_start:
    call sum_normal
    mov  [result], rax

    call sum_unrolled_4x
    mov  [result], rax

    call sum_parallel_acc
    mov  [result], rax

    call sum_with_remainder
    mov  [result], rax

    ; Exit
    mov rax, 60
    mov rdi, 0
    syscall
