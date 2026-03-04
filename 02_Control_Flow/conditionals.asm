; ============================================================
; conditionals.asm - Koşullu Yürütme (if/else karşılığı)
; Platform: Linux x86-64
; ============================================================
;
; C kodu karşılığı:
;   int x = 10, y = 20;
;   if (x > y) {
;       // büyük dalı
;   } else {
;       // küçük dalı
;   }
; ============================================================

section .data
    msg_greater db  "X, Y'den büyük!", 0x0A
    msg_greater_len equ $ - msg_greater
    msg_lesser  db  "X, Y'den küçük veya eşit!", 0x0A
    msg_lesser_len equ $ - msg_lesser

section .text
    global _start

_start:
    ; ===== TEMEL KARŞILAŞTIRMA =====
    mov rax, 10             ; x = 10
    mov rbx, 20             ; y = 20

    cmp rax, rbx            ; x - y hesapla, sonucu flag'larda sakla
    ; CMP instruction'ı sonucu saklamaz, sadece flag'ları günceller:
    ; ZF (Zero Flag)     - eşit ise 1
    ; SF (Sign Flag)     - sonuç negatifse 1
    ; CF (Carry Flag)    - unsigned taşma
    ; OF (Overflow Flag) - signed taşma

    jg  .greater            ; Jump if Greater (işaretli): RAX > RBX ise atla
    ; JG = SF = OF (signed greater than)

.lesser_or_equal:
    ; x <= y
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_lesser
    mov rdx, msg_lesser_len
    syscall
    jmp .end                ; else dalını atla

.greater:
    ; x > y
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_greater
    mov rdx, msg_greater_len
    syscall

.end:
    ; ===== KOŞULLU ATLAMA TALİMATLARI =====
    ; JE  / JZ   : Eşit / Zero
    ; JNE / JNZ  : Eşit değil / Not Zero
    ; JG  / JNLE : İşaretli büyük
    ; JGE / JNL  : İşaretli büyük veya eşit
    ; JL  / JNGE : İşaretli küçük
    ; JLE / JNG  : İşaretli küçük veya eşit
    ; JA  / JNBE : İşaretsiz büyük (above)
    ; JAE / JNB  : İşaretsiz büyük veya eşit
    ; JB  / JNAE / JC  : İşaretsiz küçük (below)
    ; JBE / JNA  : İşaretsiz küçük veya eşit

    ; ===== BİTSEL KARŞILAŞTIRMA (TEST) =====
    ; TEST, AND gibi çalışır ama sonucu saklamaz, sadece ZF günceller
    mov rax, 0b1010         ; RAX = 10
    test rax, 0b0001        ; 10 AND 1 = 0, ZF = 1 (tek sayı değil)
    jz  .even               ; ZF = 1 ise (çift sayı)
    ; ... tek sayı işlemi ...
.even:
    ; ... çift sayı işlemi ...

    mov rax, 60
    mov rdi, 0
    syscall
