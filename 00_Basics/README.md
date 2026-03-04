# 00 - Temel Kavramlar (Basics)

Bu bölüm, x86-64 Assembly diline giriş için temel kavramları kapsar.

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`hello_world.asm`](./hello_world.asm) | İlk Assembly programı - "Merhaba Dünya" |
| [`registers.asm`](./registers.asm) | CPU register'ları ve temel aritmetik |

## Temel Kavramlar

### CPU Register'ları

x86-64 mimarisi 16 adet 64-bit general-purpose register'a sahiptir:

```
RAX  RBX  RCX  RDX  RSI  RDI  RSP  RBP  R8   R9   R10  R11  R12  R13  R14  R15
```

Her register'a farklı genişlikte erişilebilir:
- `RAX` → 64-bit
- `EAX` → 32-bit (RAX'ın düşük 32 biti)
- `AX`  → 16-bit
- `AL` / `AH` → 8-bit (düşük / yüksek)

### Özel Register Kullanımları

| Register | Kullanım |
|----------|---------|
| `RAX` | Dönüş değeri, syscall numarası |
| `RDI` | 1. parametre, syscall arg 1 |
| `RSI` | 2. parametre, syscall arg 2 |
| `RDX` | 3. parametre, syscall arg 3 |
| `RSP` | Stack pointer (değiştirme!) |
| `RBP` | Frame pointer |

### NASM Syntax Temelleri

```nasm
; Yorum satırı
section .data       ; Veri bölümü
    msg db "Hi", 10 ; null-terminated string değil! 10 = newline

section .text       ; Kod bölümü
    global _start   ; Giriş noktası

_start:
    mov rax, 1      ; RAX = 1
    add rax, 2      ; RAX = RAX + 2 = 3
```

---

## Derleme ve Çalıştırma

```bash
# hello_world.asm derle
nasm -f elf64 hello_world.asm -o hello_world.o
ld hello_world.o -o hello_world
./hello_world

# Çıktı: Merhaba, Dünya!
```

---

## Öğrenme Notları

- `mov dst, src` — hedef sol, kaynak sağ (Intel syntax)
- Instruction'lar büyük/küçük harf duyarsız: `MOV`, `mov`, `Mov` hepsi aynı
- `equ` direktifi compile-time sabit tanımlar, yer kaplamaz
- `$` NASM'de "mevcut konum"u ifade eder
