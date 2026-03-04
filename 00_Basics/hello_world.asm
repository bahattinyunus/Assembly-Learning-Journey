; ============================================================
; hello_world.asm - İlk Assembly Programı
; Platform: Linux x86-64
; Derle: nasm -f elf64 hello_world.asm -o hello_world.o
; Link:  ld hello_world.o -o hello_world
; Çalıştır: ./hello_world
; ============================================================

section .data
    msg     db  "Merhaba, Dünya!", 0x0A   ; Mesaj + newline karakteri
    msg_len equ $ - msg                    ; Mesajın byte uzunluğu

section .text
    global _start           ; Linker'a başlangıç noktasını bildir

_start:
    ; sys_write(fd=1, buf=msg, count=msg_len)
    ; Syscall numaraları: /usr/include/asm/unistd_64.h
    mov rax, 1              ; syscall numarası: write (1)
    mov rdi, 1              ; fd: stdout (1)
    mov rsi, msg            ; buffer adresi
    mov rdx, msg_len        ; yazılacak byte sayısı
    syscall                 ; kernel'i çağır

    ; sys_exit(code=0)
    mov rax, 60             ; syscall numarası: exit (60)
    mov rdi, 0              ; exit kodu: 0 (başarılı)
    syscall
