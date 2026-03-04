; ============================================================
; registers.asm - Register Kullanım Örnekleri
; Platform: Linux x86-64
; Bu program register'lara değer atar ve basit arithmetic yapar
; ============================================================

section .data
    newline db 0x0A

section .text
    global _start

_start:
    ; ========== GENEL AMAÇLI REGISTER'LAR ==========
    ; RAX - Accumulator, genellikle return value ve syscall no için
    mov rax, 42             ; RAX = 42

    ; RBX - Base register (callee-saved)
    mov rbx, 10             ; RBX = 10

    ; RCX - Counter, döngülerde ve 4. parametre için
    mov rcx, 5              ; RCX = 5

    ; RDX - Data, 3. parametre ve çarpma/bölme için
    mov rdx, 0              ; RDX = 0

    ; ========== ARİTMETİK İŞLEMLER ==========
    ; Toplama
    add rax, rbx            ; RAX = 42 + 10 = 52

    ; Çıkarma
    sub rax, rcx            ; RAX = 52 - 5 = 47

    ; Çarpma (imul = işaretli çarp)
    mov r8, 2
    imul rax, r8            ; RAX = 47 * 2 = 94

    ; ========== ALT REGISTER ERİŞİMİ ==========
    ; RAX'ın 64, 32, 16 ve 8 bit versiyonları:
    ; RAX (64-bit) -> EAX (32-bit) -> AX (16-bit) -> AL / AH (8-bit)
    mov al, 0xFF            ; RAX'ın en düşük 8 bitini ayarla
    mov ah, 0x01            ; RAX'ın 8-16 arası bitlerini ayarla

    ; ========== STACK REGISTER'LARI ==========
    ; RSP (Stack Pointer) - stack'in tepesini gösterir
    ; RBP (Base Pointer)  - stack frame'i gösterir
    ; Bu register'ları doğrudan değiştirmekten kaçın!

    ; ========== İNDEX REGISTER'LARI ==========
    ; RSI - Source Index (kaynak adresi)
    ; RDI - Destination Index (hedef adres), aynı zamanda 1. syscall param
    lea rsi, [rel newline]  ; RSI = newline adresini yükle
    ; lea = Load Effective Address

    ; ========== EK REGISTER'LAR (R8-R15) ==========
    mov r8,  100            ; R8  = 100
    mov r9,  200            ; R9  = 200
    mov r10, 300            ; R10 = 300
    mov r11, 400            ; R11 = 400
    ; R12-R15 callee-saved register'lardır

    ; ========== PROGRAM SONLANDIR ==========
    mov rax, 60
    mov rdi, 0
    syscall
