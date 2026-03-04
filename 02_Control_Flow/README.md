# 02 - Kontrol Akışı (Control Flow)

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`conditionals.asm`](./conditionals.asm) | CMP, TEST ve koşullu atlamalar |
| [`loops.asm`](./loops.asm) | JMP döngüsü, LOOP instruction, while/do-while |

## Koşullu Atlama Instruction'ları

### İşaretli Karşılaştırmalar

| Instruction | Etki | C Karşılığı |
|-------------|------|-------------|
| `JE` / `JZ` | Eşit | `==` |
| `JNE` / `JNZ` | Eşit değil | `!=` |
| `JG` / `JNLE` | Büyük (signed) | `>` |
| `JGE` / `JNL` | Büyük/eşit (signed) | `>=` |
| `JL` / `JNGE` | Küçük (signed) | `<` |
| `JLE` / `JNG` | Küçük/eşit (signed) | `<=` |

### İşaretsiz Karşılaştırmalar

| Instruction | Etki |
|-------------|------|
| `JA` / `JNBE` | Üstünde (above) |
| `JAE` / `JNB` | Üstünde veya eşit |
| `JB` / `JNAE` | Altında (below) |
| `JBE` / `JNA` | Altında veya eşit |

## CMP vs TEST

```nasm
cmp rax, rbx    ; rax - rbx hesapla, sadece flags güncelle
; Kullan: eşitlik ve büyüklük karşılaştırmaları için

test rax, rbx   ; rax AND rbx hesapla, sadece flags güncelle
; Kullan: bit testi için
; test rax, rax → rax == 0 kontrolü (çok yaygın!)
```

## Döngü Örüntüleri

```nasm
; for(int i=0; i<N; i++) karşılığı
    mov rcx, 0
    mov r9, N
.loop:
    cmp rcx, r9
    jge .done
    ; gövde
    inc rcx
    jmp .loop
.done:

; LOOP instruction (geriye sayım)
    mov rcx, 5   ; sayaç
.loop:
    ; gövde
    loop .loop   ; rcx-- ve != 0 ise atla
```

## Flag Kaydı (FLAGS Register)

| Flag | Anlam | Ne Zaman Set? |
|------|-------|---------------|
| `ZF` | Zero | Sonuç 0 |
| `SF` | Sign | Sonuç negatif |
| `CF` | Carry | İşaretsiz taşma |
| `OF` | Overflow | İşaretli taşma |
| `PF` | Parity | Sonuçtaki 1 bitleri çift sayıda |
