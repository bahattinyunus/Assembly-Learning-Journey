# 04 - Bellek Yönetimi (Memory)

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`memory_addressing.asm`](./memory_addressing.asm) | Tüm adresleme modları ve LEA |

## x86-64 Adresleme Modları

Genel format: `[base + index * scale + displacement]`

| Bileşen | Değerler |
|---------|---------|
| `base` | Herhangi bir register |
| `index` | RSP hariç herhangi bir register |
| `scale` | 1, 2, 4 veya 8 |
| `displacement` | 8, 16 veya 32-bit signed sabit |

### Örnekler

```nasm
mov rax, [rbx]              ; base only
mov rax, [rbx + 8]          ; base + displacement
mov rax, [rbx + rcx]        ; base + index
mov rax, [rbx + rcx * 4]    ; base + index * scale
mov rax, [rbx + rcx * 8 + 16]  ; full form
```

## LEA - Load Effective Address

`LEA` belleği okumaz, sadece **adresi** hesaplar:

```nasm
lea rax, [rsi + 8]          ; RAX = &array[1]
lea rax, [rcx * 4]          ; RAX = rcx * 4  (hızlı çarpma!)
lea rax, [rcx + rcx * 2]    ; RAX = rcx * 3
lea rax, [rcx + rcx * 8]    ; RAX = rcx * 9
```

## Bellek Bölümleri (Sections)

```
section .text   → Çalıştırılabilir kod (read-only, execute)
section .data   → Başlangıç değerli değişkenler (read-write)
section .bss    → Başlangıç değersiz değişkenler (read-write, "zero-initialized")
section .rodata → Salt okunur veri (string literals vb.)
```

## Bellek Büyüklük Belirteçleri

```nasm
mov byte  [addr], 1    ; 1 byte  yaz
mov word  [addr], 1    ; 2 byte  yaz
mov dword [addr], 1    ; 4 byte  yaz
mov qword [addr], 1    ; 8 byte  yaz
```

## Stack vs Heap

| | Stack | Heap |
|--|-------|------|
| Yönetim | Otomatik (RSP ile) | Manuel (syscall ile) |
| Boyut | Sınırlı (~8MB) | RAM sınırına kadar |
| Hız | Çok hızlı | Daha yavaş |
| Syscall | `mmap` / `brk` | — |
