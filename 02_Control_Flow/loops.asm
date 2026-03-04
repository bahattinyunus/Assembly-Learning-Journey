; ============================================================
; loops.asm - Döngü Örnekleri
; Platform: Linux x86-64
; Derle: nasm -f elf64 loops.asm -o loops.o && ld loops.o -o loops
; ============================================================

section .data
    msg     db  "X", 0x0A   ; 'X' karakteri + newline
    msglen  equ $ - msg

section .text
    global _start

_start:
    ; ===== METOT 1: JMP ile Basit Döngü =====
    ; C karşılığı: for(int i = 0; i < 5; i++)
    mov rcx, 0              ; i = 0 (sayaç)
    mov r9,  5              ; limit = 5

.loop1_start:
    cmp rcx, r9             ; i < 5 ?
    jge .loop1_end          ; hayır ise çık

    ; --- döngü gövdesi ---
    push rcx                ; rcx'i koru (syscall bozabilir)
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msglen
    syscall
    pop rcx                 ; rcx'i geri al
    ; --- döngü gövdesi sonu ---

    inc rcx                 ; i++
    jmp .loop1_start        ; başa dön

.loop1_end:

    ; ===== METOT 2: LOOP Instruction (RCX sayacını otomatik azaltır) =====
    ; LOOP: RCX'i 1 azaltır, RCX != 0 ise hedef adrese atlar
    ; C karşılığı: for(int i = 3; i > 0; i--)
    mov rcx, 3              ; döngü sayısı (LOOP RCX'i azaltır)

.loop2_body:
    ; --- döngü gövdesi ---
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msglen
    syscall
    pop rcx
    ; --- döngü gövdesi sonu ---

    loop .loop2_body        ; RCX-- ve RCX != 0 ise .loop2_body'ye atla

    ; ===== METOT 3: DO-WHILE benzeri =====
    ; Koşulu sonda kontrol et - en az 1 kez çalışır
    mov r8, 0               ; sayaç = 0
    mov r10, 3              ; limit = 3

.do_while:
    ; --- gövde ---
    inc r8                  ; sayacı artır
    ; --- gövde sonu ---
    cmp r8, r10
    jl .do_while            ; r8 < 3 ise devam

    ; ===== METOT 4: WHILE (0'dan başla) =====
    ; Koşulu başta kontrol et
    mov rax, 10             ; başlangıç değeri
    jmp .while_cond         ; önce koşulu kontrol et

.while_body:
    sub rax, 1              ; rax--

.while_cond:
    cmp rax, 0              ; rax > 0 ?
    jg  .while_body         ; evet ise devam

    ; ===== METOT 5: Geri Sayım (Genellikle daha verimli) =====
    mov rbx, 5

.countdown:
    dec rbx                 ; rbx-- (ZF günceller)
    jnz .countdown          ; rbx != 0 ise devam
    ; NOT: dec/inc, CF'yi güncellemez!

    ; ===== ÇIKIŞ =====
    mov rax, 60
    mov rdi, 0
    syscall
