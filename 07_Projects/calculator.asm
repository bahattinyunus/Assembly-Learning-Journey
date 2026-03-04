; ============================================================
; calculator.asm - Mini Hesap Makinesi
; Platform: Linux x86-64
; Proje: Komut satırından iki sayı ve operatör alıp sonuç göster
;
; Kullanım: ./calculator
;   > Giriş: 42 + 8
;   > Sonuç: 50
; ============================================================

section .data
    prompt_a    db  "Birinci sayi: ", 0
    prompt_a_l  equ $ - prompt_a
    prompt_op   db  "Operator (+,-,*,/): ", 0
    prompt_op_l equ $ - prompt_op
    prompt_b    db  "Ikinci sayi: ", 0
    prompt_b_l  equ $ - prompt_b

    result_msg  db  "Sonuc: ", 0
    result_msg_l equ $ - result_msg

    err_div0    db  "Hata: Sifira bolme!", 0x0A, 0
    err_div0_l  equ $ - err_div0
    err_op      db  "Hata: Gecersiz operator!", 0x0A, 0
    err_op_l    equ $ - err_op

    newline     db  0x0A

section .bss
    input_buf   resb 32
    num_buf     resb 24     ; Sayıyı string'e çevirmek için

section .text
    global _start

; ============================================================
; print_str(rsi=str, rdx=len)
; ============================================================
print_str:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

; ============================================================
; read_line(rsi=buf, rdx=max) -> rax=bytes_read
; ============================================================
read_line:
    mov rax, 0
    mov rdi, 0
    syscall
    ret

; ============================================================
; atoi(rsi=str) -> rax=integer
; String'i integer'a çevirir (işaretli)
; ============================================================
atoi:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12

    xor  rax, rax           ; sonuç = 0
    xor  r12, r12           ; negatif bayrağı = 0
    mov  rbx, rsi

    ; Negatif işaret kontrolü
    cmp  byte [rbx], '-'
    jne  .digits
    mov  r12, 1             ; negatif
    inc  rbx

.digits:
    movzx rcx, byte [rbx]
    cmp  rcx, '0'
    jl   .done
    cmp  rcx, '9'
    jg   .done
    sub  rcx, '0'           ; ASCII rakamı -> sayı
    imul rax, 10
    add  rax, rcx
    inc  rbx
    jmp  .digits

.done:
    test r12, r12
    jz   .positive
    neg  rax

.positive:
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================
; itoa(rax=number, rsi=buffer) -> rax=str_start, rdx=length
; Integer'ı ASCII string'e çevirir
; ============================================================
itoa:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12
    push r13

    mov  r12, rax           ; sayı
    mov  r13, rsi           ; buffer başlangıcı

    ; Buffer'ın sonundan başla
    lea  rbx, [rsi + 22]
    mov  byte [rbx], 0x0A   ; newline
    dec  rbx
    mov  byte [rbx], 0

    ; Negatif mi?
    xor  rcx, rcx
    test r12, r12
    jns  .convert
    neg  r12
    mov  rcx, 1             ; negatif bayrağı

.convert:
    ; Sıfır durumu
    test r12, r12
    jnz  .loop
    dec  rbx
    mov  byte [rbx], '0'
    jmp  .add_sign

.loop:
    test r12, r12
    jz   .add_sign
    xor  rdx, rdx
    mov  rax, r12
    mov  r9,  10
    div  r9                 ; rax = r12/10, rdx = r12%10
    mov  r12, rax
    add  dl, '0'
    dec  rbx
    mov  [rbx], dl
    jmp  .loop

.add_sign:
    test rcx, rcx
    jz   .done
    dec  rbx
    mov  byte [rbx], '-'

.done:
    ; Uzunluk hesapla
    lea  rax, [r13 + 23]    ; (buffer_end + newline pozisyonu)
    sub  rax, rbx           ; uzunluk = end - start
    mov  rdx, rax
    mov  rax, rbx           ; başlangıç adresi

    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================
; _start - Ana hesap makinesi döngüsü
; ============================================================
_start:
    ; --- A'yı oku ---
    mov rsi, prompt_a
    mov rdx, prompt_a_l
    call print_str

    mov rsi, input_buf
    mov rdx, 31
    call read_line

    mov rsi, input_buf
    call atoi
    push rax                ; a'yı stack'e kaydet

    ; --- Operatörü oku ---
    mov rsi, prompt_op
    mov rdx, prompt_op_l
    call print_str

    mov rsi, input_buf
    mov rdx, 31
    call read_line
    movzx rbx, byte [input_buf]  ; rbx = operator karakteri

    ; --- B'yi oku ---
    mov rsi, prompt_b
    mov rdx, prompt_b_l
    call print_str

    mov rsi, input_buf
    mov rdx, 31
    call read_line

    mov rsi, input_buf
    call atoi
    mov  r9,  rax           ; r9 = b

    pop  r8                 ; r8 = a

    ; --- İşlem ---
    cmp  bl, '+'
    je   .add
    cmp  bl, '-'
    je   .sub
    cmp  bl, '*'
    je   .mul
    cmp  bl, '/'
    je   .div

    ; Geçersiz operator
    mov rsi, err_op
    mov rdx, err_op_l
    call print_str
    jmp .exit_err

.add:
    mov rax, r8
    add rax, r9
    jmp .print_result

.sub:
    mov rax, r8
    sub rax, r9
    jmp .print_result

.mul:
    mov rax, r8
    imul rax, r9
    jmp .print_result

.div:
    test r9, r9
    jnz  .do_div
    mov rsi, err_div0
    mov rdx, err_div0_l
    call print_str
    jmp .exit_err
.do_div:
    mov  rax, r8
    cqo                     ; rdx:rax = sign-extend(rax)
    idiv r9                 ; rax = bölüm, rdx = kalan

.print_result:
    ; Sonucu yazdır
    mov rsi, result_msg
    mov rdx, result_msg_l
    call print_str

    ; Sayıyı stringe çevir
    mov  r10, rax           ; sonucu sakla
    lea  r11, [num_buf]
    mov  rax, r10
    mov  rsi, r11
    call itoa               ; rax=str_ptr, rdx=len

    mov  rsi, rax
    call print_str

    jmp .exit_ok

.exit_err:
    mov rdi, 1
    mov rax, 60
    syscall

.exit_ok:
    mov rax, 60
    mov rdi, 0
    syscall
