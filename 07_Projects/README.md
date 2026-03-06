# 07 - Projeler (Projects)

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`calculator.asm`](./calculator.asm) | İnteraktif hesap makinesi (+, -, *, /) |
| [`string_utils.asm`](./string_utils.asm) | strlen, strcpy, strrev, toupper, strcmp kütüphanesi |
| [`number_printer.asm`](./number_printer.asm) | Decimal, Hex, Binary format yazdırıcı |
| [`echo_server.asm`](./echo_server.asm) | TCP/IP Echo Server (Socket Programlama) |
| [`matrix_rain.asm`](./matrix_rain.asm) | Terminal Matrix Rain Efekti |

---

## 🌐 Echo Server
Linux Socket API kullanarak 8080 portunu dinleyen bir TCP sunucusu.
- `socket`, `bind`, `listen`, `accept` syscall'ları.
- Network programlama temelleri.

---

## 🌧️ Matrix Rain
Terminal üzerinde ANSI escape dizileri kullanarak görsel bir şov sunar.
- `nanosleep` ile zamanlama.
- Rastgele sayı üretimi (LCG algoritması).
- ANSI renk ve koordinat kontrolü.

---

## 🧮 Calculator

Stdin'den iki sayı ve operatör okuyup sonucu ekrana yazar.

```bash
nasm -f elf64 calculator.asm -o calc.o && ld calc.o -o calc
./calc
# Birinci sayi: 42
# Operator (+,-,*,/): *
# Ikinci sayi: 10
# Sonuc: 420
```

**Öğretilen teknikler:**
- `atoi()` — String → Integer dönüşümü
- `itoa()` — Integer → String dönüşümü  
- Operatör karakterini `cmp` ile kontrol
- `idiv` ile işaretli bölme ve sıfıra bölme hatası

---

## 🔤 String Utils

Sıfırdan yazılmış string kütüphanesi. `libc` olmadan:

| Fonksiyon | Açıklama | Teknik |
|-----------|----------|--------|
| `strlen` | String uzunluğu | Byte-by-byte null arama |
| `strlen_fast` | Hızlı strlen | `REPNE SCASB` instruction |
| `strcpy` | String kopyalama | Byte-by-byte kopyalama |
| `strcpy_fast` | Hızlı strcpy | `REP MOVSB` instruction |
| `strrev` | String tersyüz etme | İki pointer swap |
| `str_toupper` | Büyük harfe çevir | `AND 0xDF` bit trick |
| `str_tolower` | Küçük harfe çevir | `OR 0x20` bit trick |
| `strcmp_fn` | String karşılaştırma | Byte-by-byte compare |

---

## 🔢 Number Printer

Sayıları farklı sayı sistemlerinde yazdırır:

```
Decimal: 255
Hex:     0x00000000000000FF
Binary:  0000000011111111...
```

**Öğretilen teknikler:**
- Integer'ı decimal string'e çevirme (mod 10 döngüsü)
- `SHR` ile nibble shift → hex digit
- `BT` (Bit Test) ile binary yazdırma
