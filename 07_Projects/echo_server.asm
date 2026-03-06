; ============================================================
; echo_server.asm - TCP Echo Server Projesi
; Platform: Linux x86-64
; Açıklama: 8080 portunu dinleyen ve gelen mesajları aynen 
;            geri gönderen bir socket programı.
; ============================================================

section .data
    msg_start   db "Echo Server 8080 portunda baslatildi...", 10, 0
    msg_conn    db "Yeni bir baglanti kabul edildi.", 10, 0
    
    ; sockaddr_in yapısı (16 byte)
    ; struct sockaddr_in {
    ;    short sin_family;   // 2 byte
    ;    unsigned short port; // 2 byte
    ;    struct in_addr addr; // 4 byte
    ;    char zero[8];        // 8 byte
    ; };
    sockaddr_in:
        dw 2                ; AF_INET (2)
        dw 0x901F           ; Port 8080 (0x1F90 in big-endian)
        dd 0                ; INADDR_ANY (0.0.0.0)
        dq 0                ; Padding

section .bss
    server_fd   resq 1
    client_fd   resq 1
    buffer      resb 1024

section .text
    global _start
    extern print_string     ; lib.asm'den gelecek

_start:
    ; 1. Mesajı bas
    mov rdi, msg_start
    call print_string

    ; 2. socket(AF_INET, SOCK_STREAM, 0)
    ; Syscall 41
    mov rax, 41
    mov rdi, 2              ; AF_INET
    mov rsi, 1              ; SOCK_STREAM
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .exit
    mov [server_fd], rax

    ; 3. bind(server_fd, &sockaddr, 16)
    ; Syscall 49
    mov rax, 49
    mov rdi, [server_fd]
    mov rsi, sockaddr_in
    mov rdx, 16
    syscall
    cmp rax, 0
    jne .exit

    ; 4. listen(server_fd, 10)
    ; Syscall 50
    mov rax, 50
    mov rdi, [server_fd]
    mov rsi, 10
    syscall
    
.main_loop:
    ; 5. accept(server_fd, NULL, NULL)
    ; Syscall 43
    mov rax, 43
    mov rdi, [server_fd]
    xor rsi, rsi
    xor rdx, rdx
    syscall
    mov [client_fd], rax
    
    mov rdi, msg_conn
    call print_string

    ; 6. read(client_fd, buffer, 1024)
    ; Syscall 0
    mov rax, 0
    mov rdi, [client_fd]
    mov rsi, buffer
    mov rdx, 1024
    syscall
    mov r8, rax             ; Okunan byte sayısı

    ; 7. write(client_fd, buffer, rc)
    ; Syscall 1
    mov rax, 1
    mov rdi, [client_fd]
    mov rsi, buffer
    mov rdx, r8
    syscall

    ; 8. close(client_fd)
    ; Syscall 3
    mov rax, 3
    mov rdi, [client_fd]
    syscall
    
    jmp .main_loop

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall
