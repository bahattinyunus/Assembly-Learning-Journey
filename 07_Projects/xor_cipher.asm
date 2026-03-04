; ============================================================
; xor_cipher.asm - Basit XOR Şifreleme Projesi
; Platform: Linux x86-64
; Açıklama: Bir metni sabit bir anahtar (key) ile XOR'layarak
;            şifreler veya çözer.
; ============================================================

section .data
    msg_orig    db "Assembly ile Sifreleme Cok Eglenceli!", 0
    msg_len     equ $ - msg_orig
    key         db 0x42             ; Şifreleme anahtarı
    
    lbl_before  db "Orijinal: ", 0
    lbl_after   db "Sonuc:    ", 0
    newline     db 10, 0

section .bss
    buffer      resb 64             ; İşlenmiş metin için yer

section .text
    global _start

_start:
    ; 1. Orijinal metni yazdır
    mov rdi, lbl_before
    call print_string
    mov rdi, msg_orig
    call print_string
    call print_newline

    ; 2. Şifreleme işlemi (XOR)
    mov rsi, msg_orig               ; Kaynak
    mov rdi, buffer                 ; Hedef
    mov rcx, msg_len                ; Uzunluk
    mov al, [key]                   ; Anahtar

xor_loop:
    mov bl, [rsi]                   ; Karakteri oku
    xor bl, al                      ; XOR işlemi
    mov [rdi], bl                   ; Hedefe yaz
    inc rsi
    inc rdi
    loop xor_loop

    ; 3. Şifreli metni yazdır
    mov rdi, lbl_after
    call print_string
    mov rdi, buffer
    call print_string
    call print_newline

    ; 4. Çıkış
    mov rax, 60
    xor rdi, rdi
    syscall

; --- Helper Functions ---

print_string:
    push rbp
    mov rbp, rsp
    push rbx
    
    mov rbx, rdi                    ; string pointer
    mov rdx, 0                      ; length counter
count_loop:
    cmp byte [rbx + rdx], 0
    je do_print
    inc rdx
    jmp count_loop
do_print:
    mov rax, 1                      ; sys_write
    mov rsi, rdi                    ; buffer
    mov rdi, 1                      ; stdout
    syscall
    
    pop rbx
    pop rbp
    ret

print_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret
