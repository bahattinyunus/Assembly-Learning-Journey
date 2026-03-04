# 08 - FPU ve SIMD

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`fpu_basics.asm`](./fpu_basics.asm) | SSE2 double, packed single, int↔float dönüşüm |

## Floating Point Mimarisi

```
x87 FPU    → 80-bit extended, ST(0)-ST(7) stack
SSE/SSE2   → 128-bit XMM0-XMM15 (x86-64'te 16 adet)
AVX/AVX2   → 256-bit YMM0-YMM15
AVX-512    → 512-bit ZMM0-ZMM31
```

## SSE2 Instruction Adlandırma Kuralı

```
[op][s/d][s/p]
│    │    └─ s=scalar (tek değer), p=packed (SIMD, çok değer)
│    └────── s=single (32-bit float), d=double (64-bit float)
└─────────── işlem: add, sub, mul, div, sqrt, max, min...

movsd  → move scalar double
addps  → add packed single (4 float aynı anda)
mulpd  → multiply packed double (2 double aynı anda)
sqrtsd → square root scalar double
```

## XMM Registerları - Veri Düzeni

```
XMM (128-bit):
┌──────────┬──────────┬──────────┬──────────┐
│  float3  │  float2  │  float1  │  float0  │  ← 4x32-bit float (packed single)
├──────────────────┬──────────────────────────┤
│     double1      │         double0          │  ← 2x64-bit double (packed double)
└──────────────────────────────────────────────┘
```

## Temel SSE2 Komutları

```nasm
; Yükleme / Kaydetme
movsd  xmm0, [mem]       ; 64-bit double yükle
movss  xmm0, [mem]       ; 32-bit float yükle
movaps xmm0, [mem]       ; 128-bit hizalı yükle (aligned)
movups xmm0, [mem]       ; 128-bit hizasız yükle (unaligned)

; Aritmetik (scalar)
addsd / subsd / mulsd / divsd
addss / subss / mulss / divss
sqrtsd xmm0, xmm1

; Aritmetik (packed)
addps xmm0, xmm1   ; 4 float aynı anda topla
mulpd xmm0, xmm1   ; 2 double aynı anda çarp

; Dönüşüm
cvtsi2sd xmm0, rax  ; int64 → double
cvtsi2ss xmm0, rax  ; int64 → float
cvttsd2si rax, xmm0 ; double → int64 (truncate)

; Karşılaştırma
ucomisd xmm0, xmm1  ; unordered compare (NaN güvenli)
```

## ABI - Float Parametreler

```
Fonksiyon çağrısında float/double parametreler:
XMM0 = 1. float/double
XMM1 = 2. float/double
...
XMM7 = 8. float/double

Return: XMM0
```
