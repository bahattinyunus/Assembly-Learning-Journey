; ============================================================
; lib.asm - Ortak Yardımcı Fonksiyonlar Kütüphanesi
; Platform: Linux x86-64
; ============================================================

section .text

; ------------------------------------------------------------
; strlen - String uzunluğunu hesaplar
; Input:  RDI = string pointer
; Output: RAX = uzunluk
; ------------------------------------------------------------
global strlen
strlen:
    push rcx
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    pop rcx
    ret

; ------------------------------------------------------------
; print_string - Stringi stdout'a yazdırır
; Input:  RDI = string pointer
; ------------------------------------------------------------
global print_string
print_string:
    push rdi
    push rsi
    push rdx
    push rax
    
    mov rsi, rdi        ; buffer
    call strlen
    mov rdx, rax        ; length
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    
    pop rax
    pop rdx
    pop rsi
    pop rdi
    ret

; ------------------------------------------------------------
; print_newline - Yeni satır karakteri yazdırır
; ------------------------------------------------------------
global print_newline
print_newline:
    push rax
    push rdi
    push rsi
    push rdx
    
    push 10             ; newline on stack
    mov rsi, rsp
    mov rdx, 1
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    add rsp, 8          ; restore stack
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; ------------------------------------------------------------
; exit - Programı sonlandırır
; Input: RDI = exit code
; ------------------------------------------------------------
global exit
exit:
    mov rax, 60
    syscall
