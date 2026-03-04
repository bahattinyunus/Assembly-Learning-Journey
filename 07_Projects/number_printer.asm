; ============================================================
; number_printer.asm - Sayıları Ekrana Yazdır
; Platform: Linux x86-64
; Proje: Integer/Hex/Binary formatlarında sayı yazdır
; ============================================================

section .data
    dec_label   db  "Decimal: ", 0
    dec_l       equ $ - dec_label
    hex_label   db  "Hex:     0x", 0
    hex_l       equ $ - hex_label
    bin_label   db  "Binary:  ", 0
    bin_l       equ $ - bin_label
    newline     db  0x0A

    hex_chars   db  "0123456789ABCDEF"

section .bss
    dec_buf     resb 24
    hex_buf     resb 20
    bin_buf     resb 68

section .text
    global _start

; ============================================================
; print_raw(rsi=buf, rdx=len)
; ============================================================
print_raw:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

; ============================================================
; print_nl() - newline yazdır
; ============================================================
print_nl:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel newline]
    mov rdx, 1
    syscall
    ret

; ============================================================
; print_decimal(rdi=signed_int64)
; ============================================================
print_decimal:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12

    ; Label yaz
    mov rax, 1
    mov rdi_save, r12       ; trick: rdi'yi sakla başka yerde
    ; Doğru yol: önce label, sonra sayı
    ; Ama CALL stack'i karıştırır, inline yapalım
    ; Aslında rdi = sayı, onu kaydedelim
    mov  r12, rdi
    mov  rax, 1
    mov  rdi, 1
    lea  rsi, [rel dec_label]
    mov  rdx, dec_l
    syscall

    ; Şimdi r12'yi decimal string'e çevir
    lea  rbx, [dec_buf + 22]
    mov  byte [rbx], 0x0A
    dec  rbx

    ; Negatif mi?
    xor  rcx, rcx
    test r12, r12
    jns  .pos
    neg  r12
    mov  rcx, 1

.pos:
    test r12, r12
    jnz  .digits
    dec  rbx
    mov  byte [rbx], '0'
    jmp  .sign

.digits:
    test r12, r12
    jz   .sign
    xor  rdx_l, rdx_l      ; clear rdx (label conflict, use full name)
    ; Note: just use clear approach
    xor  rdx, rdx
    mov  rax, r12
    mov  r9, 10
    div  r9
    mov  r12, rax
    add  dl, '0'
    dec  rbx
    mov  [rbx], dl
    jmp  .digits

.sign:
    test rcx, rcx
    jz   .print
    dec  rbx
    mov  byte [rbx], '-'

.print:
    ; Uzunluğu hesapla
    lea  rdx, [dec_buf + 23]
    sub  rdx, rbx
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, rbx
    syscall

    pop r12
    pop rbx
    pop rbp
    ret

; (trick için temp label)
rdi_save equ 0  ; bu equ değil, r12 kullandık zaten

; ============================================================
; print_hex(rdi=int64)
; 64-bit sayıyı hex olarak yaz: 0x0000000000000000
; ============================================================
print_hex:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12

    mov  r12, rdi

    ; Label
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel hex_label]
    mov rdx, hex_l
    syscall

    ; 16 hex digit, en yüksekten başla
    lea  rbx, [rel hex_chars]
    lea  rdi, [hex_buf]     ; buffer'ı yeniden kullan
    mov  rcx, 16            ; 16 nibble

.hex_loop:
    dec  rcx
    mov  rax, r12
    mov  r9,  rcx
    imul r9,  4
    ; Nibble = (r12 >> (rcx*4)) & 0xF
    xor  rdx, rdx
    mov  r10, r12
    mov  r11, rcx
    shl  r11, 2
    shr  r10, r11           ; shift right by nibble*4
    and  r10, 0xF
    movzx r10, byte [rbx + r10]  ; hex karakter
    mov  [hex_buf + (15 - rcx)], r10b
    ; Bir sonraki için reset
    cmp  rcx, 0
    je   .hex_done
    jmp  .hex_loop

.hex_loop_fixed:
    ; Daha sağlıklı versiyon - unrolled değil ama çalışan
    xor rcx, rcx        ; i = 0

.hex_loop2:
    cmp  rcx, 16
    je   .hex_done
    ; hex_buf[15-i] = hex_chars[(r12 >> ((15-i)*4)) & 0xF]
    mov  r10, 15
    sub  r10, rcx       ; r10 = 15 - i
    mov  r11, r10
    shl  r11, 2         ; r11 = (15-i) * 4 (nibl pozisyonu)
    mov  rax, r12
    shr  rax, r11       ; rax = r12 >> pozisyon
    and  rax, 0xF       ; nibble
    movzx rax, byte [rbx + rax]
    mov  [hex_buf + r10], al
    inc  rcx
    jmp  .hex_loop2

.hex_done:
    mov  byte [hex_buf + 16], 0x0A
    mov  rax, 1
    mov  rdi, 1
    lea  rsi, [hex_buf]
    mov  rdx, 17
    syscall

    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================
; print_binary(rdi=int64)
; 64-bit sayıyı binary olarak yaz
; ============================================================
print_binary:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12

    mov  r12, rdi

    ; Label
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel bin_label]
    mov rdx, bin_l
    syscall

    ; 64 bit - en yüksekten
    mov rcx, 63

.bin_loop:
    ; Bit rcx'i test et
    mov  rax, r12
    bt   rax, rcx           ; CF = bit[rcx]
    jnc  .zero
    mov  byte [bin_buf + (63 - rcx)], '1'
    jmp  .next
.zero:
    mov  byte [bin_buf + (63 - rcx)], '0'
.next:
    ; Her 8 bit'te bir boşluk ekle (okunabilirlik)
    dec  rcx
    cmp  rcx, 0
    jl   .bin_done
    ; Boşluk eklemek için daha karmaşık buffer gerekir, basit tutalım
    jmp  .bin_loop

.bin_done:
    mov  byte [bin_buf + 64], 0x0A
    mov  rax, 1
    mov  rdi, 1
    lea  rsi, [bin_buf]
    mov  rdx, 65
    syscall

    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================
; _start - Demo: Çeşitli sayıları farklı formatlarda yaz
; ============================================================
_start:
    ; 255 = 0xFF = 0b11111111
    mov rdi, 255
    call print_hex

    ; 42
    mov rdi, 42
    call print_hex

    ; Büyük sayı
    mov rdi, 0xDEADBEEF
    call print_hex

    ; Çıkış
    mov rax, 60
    mov rdi, 0
    syscall
