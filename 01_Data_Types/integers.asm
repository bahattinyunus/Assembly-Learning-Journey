; ============================================================
; integers.asm - Integer Veri Tipleri
; Platform: Linux x86-64
; Derleme:
;   nasm -f elf64 integers.asm -o integers.o
;   ld integers.o -o integers
; ============================================================

section .data
    ; ===== VERİ TANIMI DİREKTİFLERİ =====
    ; DB  = Define Byte     (1 byte  = 8  bit)
    ; DW  = Define Word     (2 byte  = 16 bit)
    ; DD  = Define Doubleword (4 byte = 32 bit)
    ; DQ  = Define Quadword (8 byte  = 64 bit)

    byte_val    db  255         ; 1 byte, işaretsiz: 0-255 arası
    word_val    dw  65535       ; 2 byte, işaretsiz: 0-65535
    dword_val   dd  4294967295  ; 4 byte, işaretsiz: 0-4,294,967,295
    qword_val   dq  -1          ; 8 byte, işaretli: -9.2e18 ile +9.2e18

    ; Hex gösterim
    hex_val     db  0xFF        ; 255 (hex)
    hex_big     dq  0xDEADBEEFCAFEBABE

    ; Multiple değerler (dizi gibi)
    array       db  10, 20, 30, 40, 50
    array_len   equ $ - array  ; 5 (byte cinsinden uzunluk)

    ; Negatif sayılar (ikiye tümleyen - two's complement)
    negative    db  -1          ; İkiye tümleyen: 0xFF (255)
    neg_word    dw  -1000       ; 0xFC18

section .bss
    ; ===== BİLDİRİLMEMİŞ (BAŞLANGIÇ DEĞERSİZ) VERİ =====
    ; RESB  = Reserve Byte
    ; RESW  = Reserve Word
    ; RESD  = Reserve Doubleword
    ; RESQ  = Reserve Quadword
    result      resq    1       ; 8 byte'lık alan ayır
    buffer      resb    64      ; 64 byte'lık buffer

section .text
    global _start

_start:
    ; ===== BYTE OKUMA =====
    movzx rax, byte [byte_val]  ; Zero-extend ile byte oku (0'la doldur)
    ; movzx = Move with Zero-eXtend

    movsx rax, byte [negative]  ; Sign-extend ile byte oku (işaret bitini kopyala)
    ; movsx = Move with Sign-eXtend

    ; ===== QWORD OKUMA VE ARİTMETİK =====
    mov rax, [qword_val]        ; RAX = -1 (0xFFFFFFFFFFFFFFFF)
    mov rbx, 10
    add rax, rbx                ; RAX = -1 + 10 = 9

    ; ===== DİZİ ERİŞİMİ =====
    lea rsi, [array]            ; RSI = array'in başlangıç adresi
    movzx rax, byte [rsi]       ; array[0] = 10
    movzx rbx, byte [rsi + 1]   ; array[1] = 20
    movzx rcx, byte [rsi + 2]   ; array[2] = 30

    ; Genel: [base + index * scale + displacement]
    ; Örnek: [array + rcx*1] (rcx = index)

    ; ===== SONUÇ KAYDET =====
    mov [result], rax           ; Sonucu bellege yaz

    ; ===== ÇIKIŞ =====
    mov rax, 60
    mov rdi, 0
    syscall
