; ============================================================
; matrix_rain.asm - Terminal Matrix Rain Efekti
; Platform: Linux x86-64
; Açıklama: ANSI escape kodları kullanarak terminalde 
;            "Matrix" filmindeki akan kod efektini yapar.
; ============================================================

section .data
    clear_screen db 0x1B, "[2J", 0x1B, "[H", 0 ; Clear + Home
    green_text   db 0x1B, "[32m", 0
    hide_cursor  db 0x1B, "[?25l", 0
    
    chars        db "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*", 0
    chars_len    equ $ - chars - 1
    
    sleep_time:
        dq 0                ; seconds
        dq 50000000         ; nanoseconds (50ms)

section .bss
    columns      resb 80             ; Her kolonun mevcut satır konumu
    rand_seed    resq 1

section .text
    global _start
    extern print_string

_start:
    ; 1. Hazırlık
    mov rdi, clear_screen
    call print_string
    mov rdi, green_text
    call print_string
    mov rdi, hide_cursor
    call print_string
    
    ; Seed'i zamandan al (gettimeofday)
    mov rax, 96
    mov rdi, sleep_time
    xor rsi, rsi
    syscall
    mov rax, [sleep_time]
    mov [rand_seed], rax

.main_loop:
    ; Her kolon için bir karakter bas
    mov rcx, 0
.col_loop:
    push rcx
    
    ; Rastgele bir karakter seç
    call get_random
    xor rdx, rdx
    mov rbx, chars_len
    div rbx                 ; RDX = random index
    mov al, [chars + rdx]
    mov [char_buf], al
    
    ; ANSI Escape: Position cursor [row;colH
    ; Basitleştirmek için burada rastgele satır/sütun koordinatı üretip basıyoruz
    ; Normalde akış mantığı kurulur ama Assembly'de bu haliyle de güzel bir kaos yaratır.
    
    call get_random
    xor rdx, rdx
    mov rbx, 25             ; max row
    div rbx
    inc rdx                 ; 1-based
    mov [row], dl
    
    call get_random
    xor rdx, rdx
    mov rbx, 80             ; max col
    div rbx
    inc rdx
    mov [col], dl
    
    call print_at_coord
    
    pop rcx
    inc rcx
    cmp rcx, 10             ; Her döngüde 10 karakter bas
    jl .col_loop

    ; nannosleep
    mov rax, 35             ; sys_nanosleep
    mov rdi, sleep_time
    xor rsi, rsi
    syscall
    
    jmp .main_loop

; --- Utils ---

get_random:
    mov rax, [rand_seed]
    mov rdx, 0x5851f42d4c957f2d
    mul rdx
    add rax, 1
    mov [rand_seed], rax
    shr rax, 32             ; Üst bitleri kullan
    ret

print_at_coord:
    ; ESC [ row ; col H char
    mov rdi, coord_prefix
    call print_string
    
    movzx rdi, byte [row]
    call print_int
    
    mov rdi, semi
    call print_string
    
    movzx rdi, byte [col]
    call print_int
    
    mov rdi, suffix
    call print_string
    
    mov rdi, char_buf
    call print_string
    ret

section .data
    coord_prefix db 0x1B, "[", 0
    semi         db ";", 0
    suffix       db "H", 0
    char_buf     db " ", 0
    row          db 0
    col          db 0
    
section .text
print_int:
    ; Çok basit bir 1-99 arası int yazıcı (koordinatlar için)
    push rax
    push rbx
    push rcx
    push rdx
    
    mov rax, rdi
    mov rbx, 10
    xor rdx, rdx
    div rbx                 ; AL = tens, DL = units
    
    test al, al
    jz .units
    add al, '0'
    mov [char_buf], al
    mov rdi, char_buf
    call print_string
    
.units:
    add dl, '0'
    mov [char_buf], dl
    mov rdi, char_buf
    call print_string
    
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
