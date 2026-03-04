; ============================================================
; string_utils.asm - String Yardımcı Fonksiyonlar Kütüphanesi
; Platform: Linux x86-64
; Proje: strlen, strcpy, strrev, toupper, tolower, strcmp
; ============================================================

section .data
    test_str1   db  "Assembly", 0
    test_str2   db  "assembly", 0
    newline     db  0x0A

section .bss
    buf1        resb 64
    buf2        resb 64

section .text
    global _start
    global strlen
    global strcpy
    global strrev
    global str_toupper
    global str_tolower
    global strcmp_fn

; ============================================================
; strlen(rdi=str) -> rax=length
; Null terminator'a kadar sayar
; ============================================================
strlen:
    push rbp
    mov  rbp, rsp

    xor  rax, rax           ; uzunluk = 0
.loop:
    cmp  byte [rdi + rax], 0
    je   .done
    inc  rax
    jmp  .loop

.done:
    pop rbp
    ret

; ============================================================
; strlen_fast(rdi=str) -> rax=length
; SCASB kullanılan optimize sürüm (REP prefix)
; ============================================================
strlen_fast:
    push rbp
    mov  rbp, rsp
    push rdi

    cld                     ; Direction Flag = 0 (ileri yöne)
    xor  rcx, rcx
    not  rcx                ; rcx = 0xFFFFFFFFFFFFFFFF (max sayaç)
    xor  al, al             ; Aranan: AL = 0 (null byte)
    repne scasb             ; rdi++ her adımda, AL = [RDI] ise dur
    ; rcx şimdi: başlangıç_rcx - sayılan_byte - 1 kadar azaldı
    not  rcx
    dec  rcx                ; null'u çıkar
    mov  rax, rcx           ; uzunluk

    pop  rdi
    pop  rbp
    ret

; ============================================================
; strcpy(rdi=dst, rsi=src) -> rax=dst
; Null-terminated string'i kopyalar
; ============================================================
strcpy:
    push rbp
    mov  rbp, rsp
    push rbx

    mov  rbx, rdi           ; dst'yi sakla

.copy_loop:
    mov  al, [rsi]          ; al = *src
    mov  [rdi], al          ; *dst = al
    test al, al
    je   .done
    inc  rsi
    inc  rdi
    jmp  .copy_loop

.done:
    mov  rax, rbx           ; return dst
    pop  rbx
    pop  rbp
    ret

; ============================================================
; strcpy_fast(rdi=dst, rsi=src) -> rax=dst
; MOVSB ile optimize sürüm
; ============================================================
strcpy_fast:
    push rbp
    mov  rbp, rsp
    push rdi

    ; Önce strlen ile uzunluğu bul
    push rdi
    push rsi
    mov  rdi, rsi
    call strlen
    pop  rsi
    pop  rdi
    mov  rcx, rax
    inc  rcx                ; null dahil

    cld
    rep  movsb              ; rcx byte kopyala: [rsi..] -> [rdi..]

    pop  rax                ; return original dst
    pop  rbp
    ret

; ============================================================
; strrev(rdi=str) - String'i yerinde tersyüz et
; ============================================================
strrev:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12

    ; Uzunluğu bul
    mov  r12, rdi           ; başlangıç
    call strlen
    ; rax = uzunluk

    test rax, rax
    jz   .done_rev
    dec  rax                ; son karakterin indexi

    ; İki pointer: left=r12, right=r12+rax
    mov  rbx, r12
    lea  rdi, [r12 + rax]   ; sona git

.rev_loop:
    cmp  rbx, rdi
    jge  .done_rev

    ; Swap [rbx] ve [rdi]
    mov  al, [rbx]
    mov  cl, [rdi]
    mov  [rbx], cl
    mov  [rdi], al

    inc  rbx
    dec  rdi
    jmp  .rev_loop

.done_rev:
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================
; str_toupper(rdi=str) - Küçük harfleri büyüğe çevir (in-place)
; ============================================================
str_toupper:
    push rbp
    mov  rbp, rsp

.loop_upper:
    mov  al, [rdi]
    test al, al
    jz   .done_upper
    cmp  al, 'a'
    jl   .next_upper
    cmp  al, 'z'
    jg   .next_upper
    and  al, 0xDF           ; bit 5'i temizle → büyüharf
    mov  [rdi], al
.next_upper:
    inc  rdi
    jmp  .loop_upper

.done_upper:
    pop rbp
    ret

; ============================================================
; str_tolower(rdi=str) - Büyük harfleri küçüğe çevir (in-place)
; ============================================================
str_tolower:
    push rbp
    mov  rbp, rsp

.loop_lower:
    mov  al, [rdi]
    test al, al
    jz   .done_lower
    cmp  al, 'A'
    jl   .next_lower
    cmp  al, 'Z'
    jg   .next_lower
    or   al, 0x20           ; bit 5'i set et → küçükharf
    mov  [rdi], al
.next_lower:
    inc  rdi
    jmp  .loop_lower

.done_lower:
    pop rbp
    ret

; ============================================================
; strcmp_fn(rdi=s1, rsi=s2) -> rax: 0=eşit, <0=s1<s2, >0=s1>s2
; ============================================================
strcmp_fn:
    push rbp
    mov  rbp, rsp

.cmp_loop:
    movzx rax, byte [rdi]
    movzx rcx, byte [rsi]
    cmp   rax, rcx
    jne   .not_equal
    test  al, al
    jz    .equal
    inc   rdi
    inc   rsi
    jmp   .cmp_loop

.not_equal:
    sub   rax, rcx
    pop   rbp
    ret

.equal:
    xor   rax, rax
    pop   rbp
    ret

; ============================================================
; _start - Demo
; ============================================================
_start:
    ; strlen("Assembly") test
    lea  rdi, [rel test_str1]
    call strlen             ; RAX = 8

    ; strcpy test
    lea  rdi, [buf1]
    lea  rsi, [rel test_str1]
    call strcpy

    ; str_toupper test
    lea  rdi, [buf1]
    call str_toupper        ; buf1 = "ASSEMBLY"

    ; strrev test
    lea  rdi, [buf1]
    call strrev             ; buf1 = "YLBMESSA"

    ; strcmp test
    lea  rdi, [rel test_str1]
    lea  rsi, [rel test_str2]
    call strcmp_fn          ; RAX != 0 (farklı)

    ; Stdout'a buf1 yaz
    lea  rdi, [buf1]
    call strlen
    mov  rdx, rax
    mov  rax, 1
    mov  rdi, 1
    lea  rsi, [buf1]
    syscall

    ; Newline
    mov  rax, 1
    mov  rdi, 1
    lea  rsi, [rel newline]
    mov  rdx, 1
    syscall

    ; Çıkış
    mov rax, 60
    mov rdi, 0
    syscall
