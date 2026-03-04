# Katkıda Bulunma Rehberi

Assembly Learning Journey'e katkıda bulunmak için teşekkürler! 🙏

## 🚀 Nasıl Katkıda Bulunulur?

### 1. Hata Düzeltme

Bir `.asm` dosyasında hata bulduysan:

```bash
git clone https://github.com/bahattinyunus/Assembly-Learning-Journey
cd Assembly-Learning-Journey
git checkout -b fix/hatanin-aciklamasi
# Düzeltmeyi yap
git commit -m "fix: kısa açıklama"
git push origin fix/hatanin-aciklamasi
# Pull Request aç
```

### 2. Yeni Örnek Eklemek

Mevcut bir bölüme yeni `.asm` örneği eklemek istiyorsan:
- İlgili klasöre ekle (örn: `02_Control_Flow/switch_case.asm`)
- Türkçe yorum satırları ekle
- Header block'u şu formatta yaz:

```nasm
; ============================================================
; [dosya_adi].asm - [Açıklama]
; Platform: Linux x86-64
; Derleme: nasm -f elf64 [dosya_adi].asm -o [dosya_adi].o
;           ld [dosya_adi].o -o [dosya_adi]
; ============================================================
```

### 3. Yeni Bölüm Önermek

Hangi bölümün eksik olduğunu belirtmek için Issue açabilirsin. Örnek fikirler:
- `11_Advanced_SIMD/` — AVX-512 ve gelişmiş vektör işlemleri
- `12_Reverse_Engineering/` — Binary analizi temelleri
- `13_ARM64/` — ARM Assembly (Raspberry Pi / Apple Silicon)

## 📋 Kod Standartları

| Kural | Açıklama |
|-------|----------|
| **Platform** | Linux x86-64 NASM (Intel syntax) |
| **Yorumlar** | Türkçe + teknik İngilizce terimler |
| **Girintileme** | 4 boşluk veya 1 tab |
| **Label isimleri** | `snake_case` veya `camelCase` |
| **Hizalama** | Instruction ve operand hizalı görünsün |
| **Section** | `.data` → `.bss` → `.text` sırası |

## 🧪 Test

PR göndermeden önce:

```bash
# Derlendiğini doğrula
nasm -f elf64 dosyam.asm -o dosyam.o
ld dosyam.o -o dosyam
./dosyam
echo "Exit: $?"

# Valgrind ile memory check (eğer yüklüyse)
valgrind --error-exitcode=1 ./dosyam
```

## 💡 Güzel PR Açmak İçin

- Commit mesajları anlamlı olsun: `feat: fibonacci dizisi eklendi`
- Büyük değişiklikler için önce Issue aç
- Bir PR = Bir konu prensibi

## 📖 Kaynaklar

Assembly öğrenmek için faydalı materyal bulduysan [`resources/`](./resources/) klasörüne ekleyebilirsin.

---

Her türlü katkı — hata bildirimi, yazım düzeltmesi, yeni örnek — değerlidir! 💪
