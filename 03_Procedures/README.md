# 03 - Prosedürler (Procedures)

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`functions.asm`](./functions.asm) | Fonksiyon tanımı, calling convention, rekürsiyon |
| [`stack.asm`](./stack.asm) | Stack frame yapısı, lokal değişkenler |

## System V AMD64 ABI (Linux Calling Convention)

### Parametre Geçişi

```
1. Parametre → RDI
2. Parametre → RSI
3. Parametre → RDX
4. Parametre → RCX
5. Parametre → R8
6. Parametre → R9
7+ Parametre → Stack (sağdan sola)
```

### Return Value
- 64-bit: `RAX`
- 128-bit: `RAX:RDX`
- Float: `XMM0`

### Register Sorumlulukları

| Kategori | Register'lar |
|----------|-------------|
| **Caller-saved** (çağıran korur) | RAX, RCX, RDX, RSI, RDI, R8, R9, R10, R11 |
| **Callee-saved** (çağrılan korur) | RBX, RBP, R12, R13, R14, R15 |

> **Callee-saved register'ları kullanmadan önce PUSH, dönerken POP yap!**

## Stack Frame Şablonu

```nasm
my_function:
    push rbp            ; eski base pointer'ı kaydet
    mov  rbp, rsp       ; yeni frame kur
    sub  rsp, 32        ; lokal değişken alanı (16-byte hizalı!)

    ; Lokal değişkenler:
    ; [rbp - 8]  → lokal1
    ; [rbp - 16] → lokal2

    ; ... fonksiyon gövdesi ...

    leave               ; mov rsp, rbp + pop rbp kısaltması
    ret                 ; dön
```

## Stack Belleği Düzeni

```
Yüksek adres ↑
┌─────────────────┐
│  7+ parametre   │ ← [rbp + 16]
├─────────────────┤
│  return address │ ← [rbp + 8]  (CALL tarafından push'landı)
├─────────────────┤
│  eski RBP       │ ← [rbp + 0]  (push rbp tarafından)
├─────────────────┤
│  lokal1         │ ← [rbp - 8]
├─────────────────┤
│  lokal2         │ ← [rbp - 16]
├─────────────────┤
│  ...            │
└─────────────────┘
Düşük adres  ↓  (stack bu yöne büyür)
RSP → stack tepesi
```

## Önemli Kural: 16-byte Hizalama

`CALL` instruction'ından önce `RSP` 16-byte'a hizalı olmalı. Aksi takdirde segfault oluşabilir (özellikle SSE/AVX kullanan kütüphane fonksiyonlarıyla).
