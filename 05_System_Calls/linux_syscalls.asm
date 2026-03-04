; ============================================================
; linux_syscalls.asm - Linux Sistem Çağrıları
; Platform: Linux x86-64
; ============================================================
;
; Linux x86-64 Syscall ABI:
; --------------------------
; Syscall numarası: RAX
; Parametre sırası: RDI, RSI, RDX, R10, R8, R9
;   (NOT: R10 kullanılır, RCX değil! SYSCALL instruction RCX'i kullanır)
; Return value: RAX
; Hata durumu: RAX = -errno (negatif)
;
; Önemli Syscall'lar (x86-64 Linux):
;   0  = read
;   1  = write
;   2  = open
;   3  = close
;   9  = mmap
;   12 = brk
;   39 = getpid
;   57 = fork
;   59 = execve
;   60 = exit
;   231= exit_group
; ============================================================

section .data
    ; write için mesajlar
    hello       db  "=== Linux Syscall Örnekleri ===", 0x0A
    hello_len   equ $ - hello

    prompt      db  "Adın ne? ", 0
    prompt_len  equ $ - prompt

    goodbye     db  "Görüşürüz!", 0x0A
    goodbye_len equ $ - goodbye

    pid_msg     db  "PID: ", 0
    pid_msg_len equ $ - pid_msg

    newline     db  0x0A

section .bss
    input_buf   resb    128     ; stdin için buffer
    num_buf     resb    32      ; sayı-string dönüşümü için

section .text
    global _start

; ============================================================
; Helper: int_to_str(rdi=number, rsi=buffer) -> rax=length
; Sayıyı ASCII string'e çevirir
; ============================================================
int_to_str:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12
    push r13

    mov  r12, rdi           ; sayı
    mov  r13, rsi           ; buffer başlangıcı
    lea  rbx, [rsi + 20]    ; buffer sonu'ndan başla (ters yaz)
    mov  byte [rbx], 0      ; null terminator

    ; Sayı 0 ise özel durum
    test r12, r12
    jnz  .convert
    dec  rbx
    mov  byte [rbx], '0'
    jmp  .done_convert

.convert:
    ; Her basamağı ters sırayla yaz
    xor  rdx, rdx
    mov  rax, r12
    mov  rcx, 10
.digit_loop:
    xor  rdx, rdx
    div  rcx                ; rax = rax/10, rdx = rax%10
    add  dl, '0'            ; rakamı ASCII'ye çevir
    dec  rbx
    mov  [rbx], dl          ; buffer'a yaz
    test rax, rax
    jnz  .digit_loop

.done_convert:
    ; String'i buffer başına taşı
    lea  rcx, [r13 + 20]
    sub  rcx, rbx           ; uzunluk
    mov  rax, rcx

.copy_to_front:
    ; Basitçe uzunluğu döndür, RBX buffer başını gösteriyor
    ; Gerçek uygulamada string RBX'ten başlar, R13'ten değil

    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================
; _start - Ana program
; ============================================================
_start:
    ; ===== SYS_WRITE: stdout'a yaz =====
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; fd: stdout
    mov rsi, hello              ; buffer
    mov rdx, hello_len          ; uzunluk
    syscall

    ; ===== SYS_WRITE: Prompt göster =====
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; ===== SYS_READ: stdin'den oku =====
    mov rax, 0                  ; syscall: read
    mov rdi, 0                  ; fd: stdin
    mov rsi, input_buf          ; buffer
    mov rdx, 127                ; max byte
    syscall
    ; RAX = okunan byte sayısı (hata durumunda negatif)

    ; ===== HATA KONTROLÜ =====
    test rax, rax
    js   .error                 ; RAX < 0 ise hata
    jz   .end                   ; RAX = 0 ise EOF

    ; Okunan string'i tekrar yaz (echo)
    mov rdx, rax                ; okunan byte sayısı
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buf
    syscall

    ; ===== SYS_GETPID: Process ID al =====
    mov rax, 39                 ; syscall: getpid
    syscall
    ; RAX = PID

    ; PID'i göster
    mov rsi, pid_msg
    mov rdx, pid_msg_len
    mov rax, 1
    mov rdi, 1
    syscall

    ; ===== SYS_WRITE: Veda mesajı =====
    mov rax, 1
    mov rdi, 1
    mov rsi, goodbye
    mov rdx, goodbye_len
    syscall

    jmp .end

.error:
    ; Hata durumunda exit(1)
    mov rdi, 1
    mov rax, 60
    syscall

.end:
    ; ===== SYS_EXIT: Programı sonlandır =====
    mov rax, 60                 ; syscall: exit
    mov rdi, 0                  ; exit code: 0
    syscall

    ; ===== ÖRNEK: Dosya İşlemleri =====
    ; open("dosya.txt", O_RDONLY=0, 0)
    ; mov rax, 2                ; syscall: open
    ; mov rdi, filename         ; dosya adı
    ; mov rsi, 0                ; flags: O_RDONLY
    ; mov rdx, 0                ; mode (open için önemli değil)
    ; syscall
    ; ; RAX = file descriptor (fd) veya negatif hata

    ; read(fd, buf, count)
    ; mov rdi, rax              ; fd
    ; mov rax, 0                ; syscall: read
    ; mov rsi, buf
    ; mov rdx, 256
    ; syscall

    ; close(fd)
    ; mov rdi, fd
    ; mov rax, 3                ; syscall: close
    ; syscall
