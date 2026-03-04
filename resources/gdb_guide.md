# GDB ile Assembly Hata Ayıklama Rehberi (Debug Guide)

GDB (GNU Debugger), Assembly programlarını incelerken CPU register'larını, stack'i ve bellek adreslerini görmenizi sağlayan en güçlü araçtır.

## Programı Derlerken Debug Sembolleri Ekleme

Assembly kodunu GDB'de rahatça incelemek kod satırlarıyla ilişkilendirmek için `-g` ve `-F dwarf` parametreleriyle derlemelisiniz:

```bash
nasm -f elf64 -g -F dwarf program.asm -o program.o
ld program.o -o program
```

## GDB Başlatma

```bash
gdb ./program
```

## Assembly İçin En Önemli GDB Ayarları

GDB varsayılan olarak AT&T syntax'ı kullanır. Biz NASM (Intel) öğrendiğimiz için her açtığınızda yazmamak adına `~/.gdbinit` dosyanıza şu satırı ekleyin:

```gdb
set disassembly-flavor intel
```

Ayrıca GDB'nin görsel arayüzü olan `layout asm` TUI modunu kullanmak işleri çok kolaylaştırır. TUI moduna geçmek için GDB içinde `layout asm` yazın.

## Temel Komutlar

### 📌 Breakpointler (Durma Noktaları)

| Komut | Kısaltma | Açıklama |
|-------|----------|----------|
| `break _start` | `b _start` | `_start` etiketine breakpoint koyar |
| `break *0x4000b0`| `b *0x...`| İlgili hafıza adresindeki komuta breakpoint koyar |
| `info breakpoints`| `i b` | Tüm breakpointleri listeler |
| `delete 1` | `d 1` | 1 numaralı breakpoint'i siler |

### 🚀 Çalıştırma

| Komut | Kısaltma | Açıklama |
|-------|----------|----------|
| `run` | `r` | Programı başlatır (veya yeniden başlatır) |
| `continue` | `c` | Sonraki breakpoint'e kadar devam ettirir |
| `stepi` | `si` | Yalnızca 1 (bir) assembly instruction'ı çalıştırır. (Fonksiyonların *içine* girer - CALL) |
| `nexti` | `ni` | 1 instruction çalıştırır fakat fonksiyonların (CALL) üzerinden atlar |

### 🔍 Değer İnceleme (Registers & Variables)

| Komut | Kısaltma | Açıklama |
|-------|----------|----------|
| `info registers` | `i r` | Tüm genel amaçlı registerları ve bayrakları (EFLAGS) listeler |
| `print $rax` | `p $rax` | RAX register'ının değerini decimal olarak yazdırır |
| `print/x $rax` | `p/x $rax`| RAX register'ının değerini **hexadecimal** yazdırır |
| `print/t $rax` | `p/t $rax`| RAX register'ının değerini **binary** yazdırır |
| `x/s $rdi` | | RDI'nin gösterdiği adresteki **karakter dizisini (string)** yazdırır |

### 🧠 Hafıza İnceleme (Memory Dump)

`x` (examine) komutu assembly hata ayıklamasının kalbidir. Formatı: `x/FMT ADRES`

**Format türleri:**
- `N`: Sayı (kaç öğe gösterileceği)
- `f`: Format karakteri (`x`=hex, `d`=decimal, `u`=unsigned, `i`=instruction, `s`=string, `c`=char, `t`=binary)
- `s`: Boyut (`b`=byte (8-bit), `h`=halfword (16-bit), `w`=word (32-bit), `g`=giant (64-bit))

| Komut | Açıklama |
|-------|----------|
| `x/8xb $rsp` | RSP'nin (Stack) ucundan itibaren 8 Dizi byte'ı hex olarak göster |
| `x/4wx &my_variable` | `.data` bölümündeki my_variable değişkeninin adresinden 4 adet 32-bit (word) değeri hex olarak göster |
| `x/10i $rip` | Mevcut kod noktasından (Instruction Pointer) itibaren sonraki 10 komutu disassemble et |

## Hata Ayıklama Akışı Örneği

1. Kod derlenir: `nasm -f elf64 -g -F dwarf app.asm -o app.o && ld app.o -o app`
2. GDB açılır: `gdb ./app`
3. TUI açılır: `layout asm` ve syntax ayarlanır: `set disassembly-flavor intel`
4. Program başına durma noktası konur: `break _start`
5. Çalıştırılır: `run`
6. Register'lara bakılır: `info registers` veya ekranın üstüne register penceresi de eklenebilir: `layout regs`
7. Komut komut ilerlenir: `stepi`, `stepi`...
8. Hafızadan veya kayıtlardan değerler test edilir. Çıktı için `quit` (veya `q`) kullanılır.
