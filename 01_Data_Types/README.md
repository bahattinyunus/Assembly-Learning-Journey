# 01 - Veri Tipleri (Data Types)

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`integers.asm`](./integers.asm) | DB/DW/DD/DQ ile integer tanımı |
| [`strings.asm`](./strings.asm) | String tanımı ve manipülasyonu |

## Veri Tanımlama Direktifleri

| Direktif | Boyut | Aralık (işaretsiz) |
|----------|-------|--------------------|
| `DB` (Define Byte) | 1 byte | 0 - 255 |
| `DW` (Define Word) | 2 byte | 0 - 65,535 |
| `DD` (Define Doubleword) | 4 byte | 0 - 4,294,967,295 |
| `DQ` (Define Quadword) | 8 byte | 0 - 18,446,744,073,709,551,615 |

```nasm
section .data
    byte_val    db  42          ; 1 byte
    str         db  "Merhaba", 0x0A, 0  ; string + newline + null
    array       db  1, 2, 3, 4, 5  ; dizi

section .bss
    buffer      resb 256        ; 256 byte rezerve et (başlangıç değersiz)
```

## İşaretli vs İşaretsiz

| Instruction | Açıklama |
|-------------|----------|
| `movzx` | Zero-extend (işaretsiz genişletme) |
| `movsx` | Sign-extend (işaretli genişletme) |
| `imul`  | İşaretli çarpma |
| `mul`   | İşaretsiz çarpma |
| `idiv`  | İşaretli bölme |
| `div`   | İşaretsiz bölme |

## İki'ye Tümleyen (Two's Complement)

Negatif sayılar ikiye tümleyen sistemde saklanır:
```
 1 = 0x0000000000000001
-1 = 0xFFFFFFFFFFFFFFFF  (tüm bitler 1)
-2 = 0xFFFFFFFFFFFFFFFE
```

## String Notları

- ASCII değerleri: `'A'` = 65, `'a'` = 97, `'0'` = 48
- Büyük→Küçük: `OR al, 0x20` (bit 5'i set et)
- Küçük→Büyük: `AND al, 0xDF` (bit 5'i temizle)
- Null terminator: string sonuna `0` ekle
