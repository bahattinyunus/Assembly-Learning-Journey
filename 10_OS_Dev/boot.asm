; ============================================================
; boot.asm - Basit 16-bit Bootloader
; Platform: x86 (16-bit Real Mode)
; Derleme: nasm -f bin boot.asm -o boot.bin
; Çalıştırma: qemu-system-x86_64 -drive format=raw,file=boot.bin
; ============================================================
;
; Bilgisayar açıldığında:
; 1. BIOS donanımı test eder (POST)
; 2. BIOS, boot edilebilir bir disk (sonu 0xAA55 ile biten 512 byte) arar.
; 3. Bulursa hafızada 0x7C00 adresine yükler ve çalıştırır.
; ============================================================

[ORG 0x7C00]        ; BIOS kodu bu hafıza adresine yükleyecek
[BITS 16]           ; Eski stil 16-bit Real Mode (8086 uyumlu)

    ; Segment registerlarını sıfırla
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  ; Stack'i kodun hemen altına(öncesine) yerleştir (aşağı yönde büyür)

    ; Ekranı temizle (BIOS Video Interrupt 0x10)
    mov ah, 0x00    ; Video modu belirleme
    mov al, 0x03    ; 80x25 Standart Text Modu
    int 0x10        ; BIOS Video Servisini Çağır

    ; Karşılama mesajını yazdır
    mov si, welcome_msg
    call print_string

    ; Animasyon/Döngü (Sistem donmasın diye sonsuz döngü)
.halt:
    hlt             ; CPU'yu bekleme durumuna al (interrupt gelene kadar güç tasarrufu)
    jmp .halt       ; Sonsuz döngü

; -----------------------------------------------------------
; Yardımcı Fonksiyon: Ekrana Karakter Dizisi Yazdır (print_string)
; Girdi: SI = Null ile biten stringin adresi (pointer)
; -----------------------------------------------------------
print_string:
    mov ah, 0x0E    ; BIOS TTY Modu (Karakter bas ve imleci ilerlet)
.loop:
    lodsb           ; AL = [SI] oku ve SI'yı 1 arttır
    test al, al     ; AL == 0 mı? (Null kontrolü)
    jz .done        ; Null ise fonksiyonu bitir
    int 0x10        ; AL içindeki karakteri ekrana bas (Interrupt 0x10)
    jmp .loop       ; Sonraki karaktere geç
.done:
    ret             ; Dön

; -----------------------------------------------------------
; Veriler
; -----------------------------------------------------------
welcome_msg: 
    db "Assembly Learning Journey - OS Dev", 0x0D, 0x0A
    db "Tebrikler! 16-bit BIOS bootloader uzerinden calisiyorsun.", 0x0D, 0x0A
    db "Gelecegin Isletim Sistemi burada basliyor!", 0x0D, 0x0A, 0

; -----------------------------------------------------------
; Bootloader İmzası
; MBR (Master Boot Record) 512 Byte uzunluğunda olmalıdır.
; Kalan boşlukları 0'lar ile doldur (times 510 - (şu_anki_boyut) db 0)
; Ve son iki byte 0x55, 0xAA olmalıdır (Magic Boot Signature)
; -----------------------------------------------------------
times 510-($-$$) db 0
dw 0xAA55
