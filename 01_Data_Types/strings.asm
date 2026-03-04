; ============================================================
; strings.asm - String Tanımı ve Manipülasyonu
; Platform: Linux x86-64
; Bu program stringleri nasıl tanımlayacağımızı ve
; temel string işlemlerini gösterir
; ============================================================

section .data
    ; ===== STRİNG TANIMLAMA =====
    ; Metot 1: Tek tırnak ile (NASM otomatik ASCII dönüşümü yapar)
    hello       db  "Merhaba!", 0x0A, 0     ; String + newline + null terminator
    hello_len   equ $ - hello - 1           ; null'ı saymadan uzunluk

    ; Metot 2: Karakter karakter (aynı sonucu verir)
    ; 'A' = 0x41, 'B' = 0x42 gibi...
    abc         db  'A', 'B', 'C', 0        ; "ABC" + null

    ; Metot 3: Sadece null-terminated
    empty_str   db  0                       ; Boş string

    ; Farklı satır sonları
    str_crlf    db  "Windows", 0x0D, 0x0A, 0  ; \r\n (Windows)
    str_lf      db  "Linux", 0x0A, 0           ; \n   (Linux/Unix)

    newline     db  0x0A
    nlen        equ $ - newline

section .bss
    ; Kullanıcıdan input okumak için buffer
    input_buf   resb    256
    ; Sonuç için buffer
    result_buf  resb    64

section .text
    global _start

_start:
    ; ===== STRİNG YAZMA (stdout) =====
    ; write(fd=1, buf=hello, count=hello_len)
    mov rax, 1
    mov rdi, 1
    mov rsi, hello
    mov rdx, hello_len
    syscall

    ; ===== STRİNG UZUNLUĞU HESAPLA (strlen benzeri) =====
    ; null terminator'a kadar ilerle
    lea rdi, [rel hello]    ; RDI = string başlangıcı
    xor rcx, rcx            ; RCX = 0 (sayaç)

.count_loop:
    cmp byte [rdi + rcx], 0 ; null kontrolü
    je  .count_done         ; null ise bitir
    inc rcx                 ; sayacı artır
    jmp .count_loop         ; devam

.count_done:
    ; RCX şimdi string uzunluğunu içeriyor

    ; ===== KARAKTERLEŞTİRME: STRİNG'E KARAKTER EKLEMEk =====
    ; Bir karakteri stringe eklemek için önce uzunluğu bul, sonra yaz
    ; (Bu örnekte bellekteki statik string, değiştirilemez)

    ; ===== KÜÇÜK HARFE ÇEVİR =====
    ; Büyük harf ASCII: A=65, Z=90
    ; Küçük harf ASCII: a=97, z=122
    ; Fark: 32 (0x20)
    ; Büyük harfi küçüğe çevirmek için bit 5'i set et: OR 0x20
    ; Küçük harfi büyüğe çevirmek için bit 5'i temizle: AND 0xDF
    mov al, 'A'             ; AL = 65 = 0x41
    or  al, 0x20            ; AL = 97 = 0x61 = 'a'
    mov al, 'z'             ; AL = 122 = 0x7A
    and al, 0xDF            ; AL = 90 = 0x5A = 'Z'

    ; ===== ÇIKIŞ =====
    mov rax, 60
    mov rdi, 0
    syscall
