; ============================================================
; fpu_basics.asm - x87 FPU ve SSE Floating Point
; Platform: Linux x86-64
; ============================================================
;
; x86-64 Floating Point Seçenekleri:
; 1. x87 FPU  : Legacy 80-bit extended precision, stack tabanlı
; 2. SSE/SSE2 : 128-bit XMM registerları, SIMD
; 3. AVX/AVX2 : 256-bit YMM registerları
; 4. AVX-512  : 512-bit ZMM registerları
;
; Modern Linux ABI: Float parametreler XMM0-XMM7 ile geçer
; ============================================================

section .data
    ; IEEE 754 Double precision (64-bit)
    val_a   dq  3.14159265358979  ; pi
    val_b   dq  2.71828182845905  ; e
    val_one dq  1.0
    val_two dq  2.0

    ; Single precision (32-bit)
    fval_a  dd  1.5
    fval_b  dd  2.5

    ; Tam sayıdan float'a dönüşüm için
    int_val dq  42

section .bss
    dresult dq  1           ; double sonuç

section .text
    global _start

; ============================================================
; SSE2 ile Double Precision Aritmetik
; ============================================================
sse_double_demo:
    push rbp
    mov  rbp, rsp

    ; XMM register'lara yükle
    movsd xmm0, [rel val_a]     ; xmm0 = 3.14159...
    movsd xmm1, [rel val_b]     ; xmm1 = 2.71828...

    ; Toplama
    addsd xmm0, xmm1            ; xmm0 = pi + e

    ; Çıkarma
    movsd xmm0, [rel val_a]
    subsd xmm0, xmm1            ; xmm0 = pi - e

    ; Çarpma
    movsd xmm0, [rel val_a]
    mulsd xmm0, xmm1            ; xmm0 = pi * e

    ; Bölme
    movsd xmm0, [rel val_a]
    divsd xmm0, xmm1            ; xmm0 = pi / e

    ; Karekök
    movsd xmm0, [rel val_two]
    sqrtsd xmm0, xmm0           ; xmm0 = sqrt(2) = 1.41421...

    ; Sonucu belleğe yaz
    movsd [dresult], xmm0

    pop rbp
    ret

; ============================================================
; SSE ile Single Precision (Paralel 4x float)
; Packed Single: 4 float aynı anda işle
; ============================================================
sse_packed_single_demo:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32            ; 32 byte lokal alan

    ; Belleğe 4 float dizi tanımla (lokal)
    ; [1.0, 2.0, 3.0, 4.0]
    mov  dword [rsp],      0x3F800000  ; 1.0f
    mov  dword [rsp + 4],  0x40000000  ; 2.0f
    mov  dword [rsp + 8],  0x40400000  ; 3.0f
    mov  dword [rsp + 12], 0x40800000  ; 4.0f

    ; [5.0, 6.0, 7.0, 8.0]
    mov  dword [rsp + 16], 0x40A00000  ; 5.0f
    mov  dword [rsp + 20], 0x40C00000  ; 6.0f
    mov  dword [rsp + 24], 0x40E00000  ; 7.0f
    mov  dword [rsp + 28], 0x41000000  ; 8.0f

    ; 4 float'ı XMM'e yükle
    movaps xmm0, [rsp]          ; xmm0 = [1.0, 2.0, 3.0, 4.0]
    movaps xmm1, [rsp + 16]     ; xmm1 = [5.0, 6.0, 7.0, 8.0]

    ; 4 toplama AYNI ANDA
    addps  xmm0, xmm1           ; xmm0 = [6.0, 8.0, 10.0, 12.0]

    ; 4 çarpma AYNI ANDA
    movaps xmm0, [rsp]
    mulps  xmm0, xmm1           ; xmm0 = [5.0, 12.0, 21.0, 32.0]

    ; Maksimum 4x
    movaps xmm0, [rsp]
    maxps  xmm0, xmm1           ; xmm0 = [5.0, 6.0, 7.0, 8.0] (her biri max)

    leave
    ret

; ============================================================
; Integer <-> Float Dönüşümü
; ============================================================
int_to_float_demo:
    push rbp
    mov  rbp, rsp

    ; Integer → Double
    mov   rax, 42
    cvtsi2sd xmm0, rax          ; xmm0 = 42.0 (64-bit int → double)

    ; Integer → Single (float)
    mov   rax, 100
    cvtsi2ss xmm0, rax          ; xmm0 = 100.0f (64-bit int → float)

    ; Double → Integer (truncate)
    movsd xmm0, [rel val_a]     ; xmm0 = 3.14159...
    cvttsd2si rax, xmm0         ; rax = 3 (truncate, not round)

    ; Double → Integer (round to nearest)
    cvtsd2si rax, xmm0          ; rax = 3 (4'ten küçükse 3'e yuvarla)

    pop rbp
    ret

; ============================================================
; Float Karşılaştırması
; ============================================================
float_compare_demo:
    push rbp
    mov  rbp, rsp

    movsd xmm0, [rel val_a]     ; pi
    movsd xmm1, [rel val_b]     ; e

    ucomisd xmm0, xmm1          ; Unordered Compare (NaN güvenli)
    ; Flags: ZF, PF, CF güncellenir
    ; xmm0 > xmm1: CF=0, ZF=0
    ; xmm0 < xmm1: CF=1, ZF=0
    ; xmm0 = xmm1: CF=0, ZF=1
    ja   .a_greater             ; CF=0, ZF=0
    jb   .b_greater             ; CF=1
    je   .equal

.a_greater:
    ; pi > e
    jmp .done_cmp
.b_greater:
    ; e > pi (hayır, olmamalı)
    jmp .done_cmp
.equal:
.done_cmp:
    pop rbp
    ret

_start:
    call sse_double_demo
    call sse_packed_single_demo
    call int_to_float_demo
    call float_compare_demo

    mov rax, 60
    mov rdi, 0
    syscall
