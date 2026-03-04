; ============================================================
; stack.asm - Stack Frame Yönetimi
; Platform: Linux x86-64
; ============================================================
;
; Stack Modeli (x86-64):
; - Stack aşağıya doğru büyür (yüksek adresten düşük adrese)
; - RSP (Stack Pointer) her zaman stack'in tepesini gösterir
; - PUSH: RSP -= 8, [RSP] = değer
; - POP:  değer = [RSP], RSP += 8
; - CALL: RSP -= 8, [RSP] = return address, JMP target
; - RET:  JMP [RSP], RSP += 8
;
; Stack Çerçevesi (Stack Frame) düzeni:
;   [rbp + 16]  = 2. stack parametresi (7+. arg ise)
;   [rbp + 8]   = return address (CALL tarafından push'landı)
;   [rbp + 0]   = eski RBP (push rbp tarafından push'landı)
;   [rbp - 8]   = lokal değişken 1
;   [rbp - 16]  = lokal değişken 2
;   [rsp]       = stack'in mevcut tepesi
; ============================================================

section .text
    global _start

; ============================================================
; Fonksiyon: demo_locals(a, b)
; Lokal değişken kullanımı
; ============================================================
demo_locals:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32            ; 32 byte lokal alan ayır (16-byte hizalama için)
    ; NOT: Shadow space'i 16'nın katı tutmak kritik!

    ; Lokal değişkenlere yaz
    mov qword [rbp - 8],  100   ; lokal1 = 100
    mov qword [rbp - 16], 200   ; lokal2 = 200
    mov qword [rbp - 24], 0     ; lokal3 = 0

    ; Parametreler hala RDI ve RSI'da
    mov rax, rdi
    add rax, rsi
    mov [rbp - 24], rax         ; lokal3 = a + b

    ; Lokal değişkenleri oku
    mov rax, [rbp - 8]          ; rax = lokal1
    add rax, [rbp - 16]         ; rax += lokal2
    add rax, [rbp - 24]         ; rax += lokal3
    ; RAX = 100 + 200 + (a+b)

    ; Stack'i temizle ve dön
    leave                   ; MOV RSP, RBP + POP RBP kısaltması
    ret

; ============================================================
; PUSH/POP ile Değer Kaydetme
; ============================================================
demo_push_pop:
    push rbp
    mov  rbp, rsp

    ; Register'ları stack ile kaydet/geri yükle
    push rbx                ; rbx'i kaydet
    push r12                ; r12'yi kaydet
    push r13                ; r13'ü kaydet

    ; Şimdi bu register'ları serbestçe kullan
    mov rbx, 1
    mov r12, 2
    mov r13, 3
    add rbx, r12
    add rbx, r13            ; rbx = 1 + 2 + 3 = 6
    mov rax, rbx

    ; Ters sırayla geri yükle! (LIFO - Last In, First Out)
    pop r13
    pop r12
    pop rbx

    pop rbp
    ret

; ============================================================
; Stack Aritmetiği Gösterimi
; ============================================================
demo_stack_arithmetic:
    push rbp
    mov  rbp, rsp

    ; Stack'te basit hesap makinesi
    ; Her değeri stack'e push et, sonra pop et ve hesapla
    push 10
    push 20
    push 30

    pop  rax                ; rax = 30
    pop  rbx                ; rbx = 20
    pop  rcx                ; rcx = 10

    add  rax, rbx           ; 30 + 20 = 50
    add  rax, rcx           ; 50 + 10 = 60

    pop rbp
    ret

; ============================================================
; _start - Ana program
; ============================================================
_start:
    ; 16-byte stack hizalamasını sağla
    ; _start çağrılmadan önce RSP zaten hizalı
    ; ama güvenli olması için:
    and rsp, -16            ; RSP'yi 16'ya yuvarla (aşağı doğru)

    ; demo_locals(5, 7) çağır
    mov rdi, 5
    mov rsi, 7
    call demo_locals        ; RAX = 100 + 200 + 12 = 312

    ; demo_push_pop çağır
    call demo_push_pop      ; RAX = 6

    ; demo_stack_arithmetic çağır
    call demo_stack_arithmetic  ; RAX = 60

    ; Exit code olarak son sonucu kullan
    mov rdi, rax
    mov rax, 60
    syscall
