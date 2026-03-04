; ============================================================
; memory_addressing.asm - Bellek Adresleme Modları
; Platform: Linux x86-64
; ============================================================
;
; x86-64 Adresleme Modu: [base + index * scale + displacement]
;   base        : herhangi bir register
;   index       : RSP hariç herhangi bir register
;   scale       : 1, 2, 4 veya 8
;   displacement: sabit bir sayı (offset)
; ============================================================

section .data
    array       dq  10, 20, 30, 40, 50     ; 5 elementli qword dizisi
    matrix      db  1, 2, 3,               ; 3x3 matrix (byte)
                db  4, 5, 6,
                db  7, 8, 9
    M_COLS      equ 3

    value       dq  0xDEADBEEFCAFEBABE

section .bss
    result      resq    1
    buf         resb    256

section .text
    global _start

_start:
    ; ===== 1. IMMEDIATE (Sabit değer) =====
    mov rax, 42             ; RAX = 42 (doğrudan sabit)
    mov rax, 0xFF00         ; RAX = 65280

    ; ===== 2. REGISTER =====
    mov rbx, rax            ; RBX = RAX (register'dan register'a)
    xchg rax, rbx           ; swap (register'ları değiştir)

    ; ===== 3. DIRECT MEMORY =====
    mov rax, [value]        ; RAX = bellekteki değer (8 byte oku)
    mov byte [result], 255  ; Belleğe 1 byte yaz
    mov qword [result], rax ; Belleğe 8 byte yaz

    ; ===== 4. REGISTER INDIRECT =====
    lea rsi, [array]        ; RSI = array'in adresi
    mov rax, [rsi]          ; RAX = array[0] = 10

    ; ===== 5. BASE + DISPLACEMENT =====
    mov rax, [rsi + 8]      ; array[1] (her qword = 8 byte)
    mov rax, [rsi + 16]     ; array[2]
    mov rax, [rsi + 24]     ; array[3]
    mov rax, [rsi + 32]     ; array[4]

    ; ===== 6. BASE + INDEX * SCALE =====
    ; Dinamik index ile dizi erişimi
    xor rcx, rcx            ; index = 0

.array_loop:
    cmp rcx, 5
    jge .array_done
    mov rax, [rsi + rcx * 8]    ; array[rcx] (qword = 8 byte)
    inc rcx
    jmp .array_loop
.array_done:

    ; ===== 7. BASE + INDEX * SCALE + DISPLACEMENT =====
    ; 2D matris erişimi: matrix[satır][sütun]
    lea rbx, [matrix]       ; matrix base adresi
    mov rcx, 1              ; satır = 1
    mov rdx, 2              ; sütun = 2

    ; matrix[1][2] = matrix + (1 * 3 + 2) * 1
    ; NASM: [base + index * scale + disp]
    ; Satır * sütun sayısı + Sütun:
    imul rcx, M_COLS        ; rcx = 1 * 3 = 3
    add  rcx, rdx           ; rcx = 3 + 2 = 5
    movzx rax, byte [rbx + rcx]  ; matrix[1][2] = 6

    ; ===== 8. LEA - Load Effective Address =====
    ; LEA bellekten okumaz, sadece adresi hesaplar
    lea rax, [rsi + 24]         ; RAX = &array[3] (adres, değil değer)
    lea rax, [rcx * 4 + 100]    ; RAX = rcx * 4 + 100 (hızlı çarpma!)

    ; LEA ile hızlı çarpma (MUL kullanmadan):
    lea rax, [rcx + rcx * 2]    ; RAX = rcx * 3
    lea rax, [rcx * 4]          ; RAX = rcx * 4
    lea rax, [rcx + rcx * 4]    ; RAX = rcx * 5
    lea rax, [rcx + rcx * 8]    ; RAX = rcx * 9

    ; ===== ÇIKIŞ =====
    mov rax, 60
    mov rdi, 0
    syscall
