# 05 - Sistem Çağrıları (System Calls)

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`linux_syscalls.asm`](./linux_syscalls.asm) | write, read, getpid, exit örnekleri |

## Linux x86-64 Syscall ABI

```
RAX  = Syscall numarası
RDI  = 1. Parametre
RSI  = 2. Parametre
RDX  = 3. Parametre
R10  = 4. Parametre  (NOT: RCX değil!)
R8   = 5. Parametre
R9   = 6. Parametre
```

**Dönüş:** `RAX` = sonuç veya `-errno` (negatif hata kodu)

## Önemli Syscall'lar

| No | İsim | Parametreler | Dönüş |
|----|------|--------------|-------|
| 0 | `read` | rdi=fd, rsi=buf, rdx=count | okunan byte |
| 1 | `write` | rdi=fd, rsi=buf, rdx=count | yazılan byte |
| 2 | `open` | rdi=path, rsi=flags, rdx=mode | fd |
| 3 | `close` | rdi=fd | 0 |
| 9 | `mmap` | ... | adres |
| 39 | `getpid` | — | PID |
| 57 | `fork` | — | 0/PID |
| 60 | `exit` | rdi=code | — |
| 231 | `exit_group` | rdi=code | — |

## Temel Yapı

```nasm
; write(1, "merhaba\n", 8)
mov rax, 1          ; syscall: write
mov rdi, 1          ; fd: stdout
mov rsi, msg        ; buffer adresi
mov rdx, 8          ; byte sayısı
syscall

; exit(0)
mov rax, 60         ; syscall: exit
mov rdi, 0          ; exit code
syscall
```

## open() Flags

```nasm
O_RDONLY = 0     ; salt okuma
O_WRONLY = 1     ; salt yazma
O_RDWR   = 2     ; okuma+yazma
O_CREAT  = 0x40  ; dosya yoksa oluştur (mode parametresi gerekir)
O_TRUNC  = 0x200 ; varolan dosyayı sıfırla
O_APPEND = 0x400 ; sona ekle
```

## Hata Kontrolü

```nasm
syscall
test rax, rax
js   .error          ; RAX < 0 ise hata
; RAX = -ERRNO (örneğin: -13 = -EACCES, -2 = -ENOENT)
```

## File Descriptor'lar

| FD | Anlamı |
|----|--------|
| 0 | stdin  |
| 1 | stdout |
| 2 | stderr |
