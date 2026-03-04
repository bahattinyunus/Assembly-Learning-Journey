# 09 - C/C++ ve Assembly Entegrasyonu (Inline Asm)

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`inline.c`](./inline.c) | GCC Extended Inline Assembly örnekleri |

## Neden C/C++ İçinde Assembly?

Bazen tüm projeyi Assembly ile yazmak çok zordur, ancak kritik birkaç fonksiyonun veya algoritmanın (örn: kriptografi, codec işlemleri) performansını Assembly seviyesine çıkarmak veya doğrudan CPU'ya özgü komutlara (SIMD, CPUID) erişmek isteriz. Bu durumda C/C++ projesinin içine Assembly kodları gömebiliriz.

## Derleme ve Çalıştırma

C kodumuzu derlemek için `gcc` kullanacağız:

```bash
# Sadece derlemek ve çalıştırmak için
gcc inline.c -o inline_app
./inline_app

# Optimizasyon bayraklarıyla derleyip C compiler'ın ASM'ye dokunuşunu görmek için
gcc -O3 inline.c -o inline_app

# C kodunun oluşturduğu Assembly çıktısını incelemek için (-S bayrağı)
gcc -S -masm=intel inline.c
```

## GCC Extended Assembly Syntax

GCC'de Inline Assembly yazarken AT&T syntax var sayılır. Ancak `intel` direktifi ile NASM'a benzeyen Intel syntax'ında yazabiliriz.

Genel formül şudur:

```c
__asm__ __volatile__ (
    "assembly_komutu_1\n\t"
    "assembly_komutu_2"
    : output_operands         /* Opsiyonel: ASM'den C'ye değer çıkışı */
    : input_operands          /* Opsiyonel: C'den ASM'ye değer girişi */
    : clobbered_registers     /* Opsiyonel: ASM bloğunda bozulan register'lar */
);
```

### Constraint'ler (Kısıtlamalar)

Değişkenlerin hangi kaynaklara atandığını belirtmek için kullanılır.

- `"r"`, `"a"`, `"b"`, `"c"`, `"d"`: Genel registerlar. (Sırayla: herhangi biri, RAX, RBX, RCX, RDX).
- `"="`: Write-only (Sadece yazılır) output işareti.
- `"+"`: Read-write (Okunur ve yazılır) output/input işareti.
- `"m"`: Bellek referansı.

**Örnek:**
```c
int a = 10, b;
__asm__ ("mov %0, %1" : "=r" (b) : "r" (a)); 
// b'ye = (%0 çıkış değişkenine), a'nın değerini (%1 giriş değişkenini) aktar
```
Bu sayede değişkenlerin register adreslerini derleyici bizim için ayarlar.
