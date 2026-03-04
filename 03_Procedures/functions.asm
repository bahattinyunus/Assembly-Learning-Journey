; ============================================================
; functions.asm - Fonksiyon Tanımı ve Çağrısı
; Platform: Linux x86-64 (System V AMD64 ABI)
; ============================================================
;
; System V AMD64 ABI Calling Convention (Linux):
; -----------------------------------------------
; Parametre geçişi (soldan sağa):
;   1. param -> RDI
;   2. param -> RSI
;   3. param -> RDX
;   4. param -> RCX
;   5. param -> R8
;   6. param -> R9
;   7+ param -> Stack (sağdan sola)
;
; Return value: RAX (ve RDX eğer 128 bit ise)
;
; Caller-saved (çağıran korur): RAX, RCX, RDX, RSI, RDI, R8, R9, R10, R11
; Callee-saved (çağrılan korur): RBX, RBP, R12, R13, R14, R15
;
; RSP her CALL'dan önce 16-byte hizalanmış olmalı
; ============================================================

section .data
    result_msg  db  "Toplam: ", 0
    newline     db  0x0A

section .text
    global _start

; ============================================================
; fonksiyon: add_numbers(a, b) -> a + b
; Parametre: RDI=a, RSI=b
; Return:    RAX=a+b
; ============================================================
add_numbers:
    ; Prolog - stack frame kur
    push rbp                ; eski base pointer'ı kaydet
    mov  rbp, rsp           ; yeni base pointer
    ; (bu fonksiyonda lokal değişken yok, bu yüzden rsp değişmez)

    ; Fonksiyon gövdesi
    mov rax, rdi            ; RAX = a
    add rax, rsi            ; RAX = a + b

    ; Epilog - stack frame temizle
    pop rbp                 ; base pointer'ı geri yükle
    ret                     ; RIP'i stack'ten al ve atla

; ============================================================
; fonksiyon: multiply(a, b) -> a * b
; Parametre: RDI=a, RSI=b
; Return:    RAX=a*b
; ============================================================
multiply:
    push rbp
    mov  rbp, rsp

    mov  rax, rdi           ; RAX = a
    imul rax, rsi           ; RAX = a * b (işaretli çarpma)

    pop rbp
    ret

; ============================================================
; fonksiyon: factorial(n) -> n!
; Parametre: RDI=n
; Return:    RAX=n!
; Rekürsif fonksiyon örneği
; ============================================================
factorial:
    push rbp
    mov  rbp, rsp
    push rbx                ; rbx callee-saved, kullanacağız

    ; Base case: n <= 1, return 1
    cmp rdi, 1
    jle .base_case

    ; Rekürsif case: n * factorial(n-1)
    mov rbx, rdi            ; rbx = n (RDI rekürsif çağrıda değişecek)
    dec rdi                 ; n - 1
    call factorial          ; factorial(n-1) -> RAX
    imul rax, rbx           ; n * factorial(n-1)
    jmp .done

.base_case:
    mov rax, 1              ; return 1

.done:
    pop rbx                 ; rbx'i geri yükle
    pop rbp
    ret

; ============================================================
; fonksiyon: max_of_three(a, b, c) -> max(a,b,c)
; Parametre: RDI=a, RSI=b, RDX=c
; Return:    RAX=max
; ============================================================
max_of_three:
    push rbp
    mov  rbp, rsp

    mov  rax, rdi           ; assume a is max
    cmp  rsi, rax
    jle  .check_c
    mov  rax, rsi           ; b is bigger

.check_c:
    cmp  rdx, rax
    jle  .done2
    mov  rax, rdx           ; c is biggest

.done2:
    pop rbp
    ret

; ============================================================
; _start - Ana program
; ============================================================
_start:
    ; add_numbers(15, 27) çağır
    mov rdi, 15             ; 1. parametre
    mov rsi, 27             ; 2. parametre
    call add_numbers        ; RAX = 42

    ; multiply(6, 7) çağır
    mov rdi, 6
    mov rsi, 7
    call multiply           ; RAX = 42

    ; factorial(5) çağır
    mov rdi, 5
    call factorial          ; RAX = 120

    ; max_of_three(10, 35, 22) çağır
    mov rdi, 10
    mov rsi, 35
    mov rdx, 22
    call max_of_three       ; RAX = 35

    ; Çıkış (RAX sonucu exit code olarak kullan)
    mov rdi, rax            ; exit code = son fonksiyon sonucu
    mov rax, 60
    syscall
