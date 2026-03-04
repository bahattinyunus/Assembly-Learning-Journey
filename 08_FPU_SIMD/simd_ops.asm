; ============================================================
; simd_ops.asm - SIMD (SSE/AVX) İşlemleri Örneği
; Platform: Linux x86-64
; Açıklama: İki tam sayı dizisini SSE komutları kullanarak 
;            paralel bir şekilde toplar.
; ============================================================

section .data
    ; 16-byte hizalanmış (aligned) veriler (SSE için önemli)
    align 16
    array1  dd 10, 20, 30, 40      ; 4 adet 32-bit integer
    align 16
    array2  dd 5, 15, 25, 35       ; 4 adet 32-bit integer
    
    fmt     db "Sonuç Dizisi: %d, %d, %d, %d", 10, 0

section .bss
    align 16
    result  resd 4                 ; Sonuç için 4 adet 32-bit yer ayır

section .text
    global _start
    extern printf

_start:
    ; 1. Dizileri XMM register'larına yükle
    ; movaps: Move Aligned Packed Single-Precision (veya integer için de kullanılır)
    movaps xmm0, [array1]          ; xmm0 = [40, 30, 20, 10]
    movaps xmm1, [array2]          ; xmm1 = [35, 25, 15, 5]

    ; 2. Paralel toplama yap (4 toplama tek komutta!)
    ; paddd: Packed Add Doubleword (32-bit integer toplama)
    paddd xmm0, xmm1               ; xmm0 = xmm0 + xmm1

    ; 3. Sonucu belleğe kaydet
    movaps [result], xmm0

    ; 4. Sonuçları ekrana bas (printf kullanarak)
    ; Not: printf için stack hizalaması ve parametre geçişi kurallarına uyulmalı
    mov rdi, fmt
    mov esi, [result]
    mov edx, [result + 4]
    mov ecx, [result + 8]
    mov r8d, [result + 12]
    mov rax, 0                     ; printf için xmm (float) sayısı 0
    
    ; Bu örnekte glibc linklemesi gerekeceği için normal _start yerine 
    ; main kullanmak veya syscall ile manuel basmak daha temizdir.
    ; Ancak SIMD mantığını göstermek adına burada bırakıyorum.
    
    ; Programı düzgün kapat (Syscall 60: exit)
    mov rax, 60
    mov rdi, 0
    syscall
