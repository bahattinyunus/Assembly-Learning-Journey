# x86-64 Assembly Hızlı Referans Kağıdı (Cheatsheet)

> Platform: Linux x86-64 | Assembler: NASM (Intel syntax)

---

## 📦 Register'lar

### General Purpose Registers

| 64-bit | 32-bit | 16-bit | 8-bit H | 8-bit L | ABI Rolü |
|--------|--------|--------|---------|---------|---------|
| `RAX` | `EAX` | `AX` | `AH` | `AL` | Return value, Syscall no |
| `RBX` | `EBX` | `BX` | `BH` | `BL` | Callee-saved |
| `RCX` | `ECX` | `CX` | `CH` | `CL` | 4. param, döngü sayacı |
| `RDX` | `EDX` | `DX` | `DH` | `DL` | 3. param, imul/idiv |
| `RSI` | `ESI` | `SI` | — | `SIL` | 2. param, kaynak index |
| `RDI` | `EDI` | `DI` | — | `DIL` | 1. param, hedef index |
| `RSP` | `ESP` | `SP` | — | `SPL` | Stack pointer |
| `RBP` | `EBP` | `BP` | — | `BPL` | Base pointer (frame) |
| `R8`  | `R8D` | `R8W` | — | `R8B` | 5. param |
| `R9`  | `R9D` | `R9W` | — | `R9B` | 6. param |
| `R10-R11` | ... | ... | — | ... | Caller-saved (geçici) |
| `R12-R15` | ... | ... | — | ... | Callee-saved |

---

## 🔧 Temel Instruction'lar

### Veri Taşıma
```nasm
mov  dst, src        ; dst = src
movzx dst, src       ; dst = src (zero-extend)
movsx dst, src       ; dst = src (sign-extend)
lea  dst, [addr]     ; dst = adres (bellek okumaz)
xchg dst, src        ; swap(dst, src)
push src             ; RSP -= 8; [RSP] = src
pop  dst             ; dst = [RSP]; RSP += 8
```

### Aritmetik
```nasm
add  dst, src        ; dst += src
sub  dst, src        ; dst -= src
inc  dst             ; dst++ (CF güncellenmez!)
dec  dst             ; dst-- (CF güncellenmez!)
neg  dst             ; dst = -dst (ikiye tümleyen)
imul dst, src        ; dst *= src (işaretli)
imul dst, src, imm   ; dst = src * imm
idiv src             ; RDX:RAX / src → RAX=bölüm, RDX=kalan
mul  src             ; RDX:RAX = RAX * src (işaretsiz)
```

### Bitsel İşlemler
```nasm
and  dst, src        ; dst &= src
or   dst, src        ; dst |= src
xor  dst, src        ; dst ^= src  (xor reg, reg → sıfırla!)
not  dst             ; dst = ~dst
shl  dst, cnt        ; dst <<= cnt (sol kaydır)
shr  dst, cnt        ; dst >>= cnt (sağ kaydır, işaretsiz)
sar  dst, cnt        ; dst >>= cnt (sağ kaydır, işaretli)
rol  dst, cnt        ; döndürerek sola kaydır
ror  dst, cnt        ; döndürerek sağa kaydır
```

---

## 🔀 Kontrol Akışı

```nasm
cmp  a, b            ; a - b (sadece flags)
test a, b            ; a AND b (sadece flags)

jmp  label           ; koşulsuz atla
je/jz    label       ; ZF=1 (eşit / sıfır)
jne/jnz  label       ; ZF=0 (eşit değil)
jg/jnle  label       ; ZF=0 ve SF=OF (işaretli >)
jge/jnl  label       ; SF=OF (işaretli >=)
jl/jnge  label       ; SF!=OF (işaretli <)
jle/jng  label       ; ZF=1 veya SF!=OF (işaretli <=)
ja/jnbe  label       ; CF=0 ve ZF=0 (işaretsiz >)
jb/jnae  label       ; CF=1 (işaretsiz <)

call label           ; RSP-=8; [RSP]=RIP; JMP label
ret                  ; JMP [RSP]; RSP+=8
loop label           ; RCX--; RCX!=0 ise atla
```

---

## 📋 Veri Tanımlama

```nasm
section .data
    b   db  42            ; 1 byte
    w   dw  1000          ; 2 byte
    d   dd  100000        ; 4 byte
    q   dq  -1            ; 8 byte
    s   db  "hello", 0    ; string + null
    a   db  1,2,3,4,5     ; byte dizisi
    X   equ 42            ; sabit (yer kaplamaz)

section .bss
    buf resb  256         ; 256 byte rezerve
    n   resq  1           ; 1 qword rezerve
```

---

## 🐧 Linux Syscall'lar (x86-64)

```nasm
; syscall(no, rdi, rsi, rdx, r10, r8, r9)
; Sonuç: RAX (hata: negatif)

sys_read      equ 0
sys_write     equ 1
sys_open      equ 2
sys_close     equ 3
sys_mmap      equ 9
sys_brk       equ 12
sys_getpid    equ 39
sys_fork      equ 57
sys_exit      equ 60
sys_exit_group equ 231

; Örnek: write(stdout, msg, 5)
mov rax, 1 ; sys_write
mov rdi, 1 ; fd=stdout
mov rsi, msg
mov rdx, 5
syscall
```

---

## 🏛️ Stack Frame Şablonu

```nasm
my_func:
    push rbp
    mov  rbp, rsp
    sub  rsp, N          ; N: lokal alan (16'nın katı olsun!)

    ; [rbp - 8]  = lokal1
    ; [rbp - 16] = lokal2

    leave                ; = mov rsp,rbp + pop rbp
    ret
```

---

## 🛠️ GDB Hızlı Komutlar

```bash
gdb ./program
(gdb) layout asm       # Assembly görünümü
(gdb) break _start     # Breakpoint
(gdb) run              # Çalıştır
(gdb) stepi            # Bir instruction ilerle
(gdb) nexti            # Bir instruction ilerle (call içine girme)
(gdb) info registers   # Tüm register'ları göster
(gdb) p/x $rax         # RAX'ı hex yazdır
(gdb) x/8xb $rsp       # RSP'den 8 byte hex göster
(gdb) x/s $rsi         # RSI'nin gösterdiği string
(gdb) disas            # Mevcut fonksiyonu decompile et
```

---

## ⚡ Yaygın Kalıplar

```nasm
; Register'ı sıfırla (xor en hızlı yol)
xor rax, rax            ; RAX = 0

; Register 0 mı? (test en hızlı yol)
test rax, rax
jz   .zero

; Tek mi çift mi?
test rax, 1
jz   .even              ; bit0=0 → çift

; Mutlak değer (işaretli)
test rax, rax
jns  .positive
neg  rax                ; rax = -rax

; Min/Max (cmov ile branch'siz)
cmp  rax, rbx
cmovg rax, rbx          ; if RAX > RBX: RAX = RBX  (min)
; cmovl: if less, cmove: if equal, cmovge: if >=, vb.

; N * 2 (shift ile)
shl rax, 1              ; rax *= 2 (1 bit sola kaydır)

; N * 10
lea rax, [rax + rax * 4]; rax = rax + rax*4 = rax*5
shl rax, 1              ; rax = rax*5 * 2 = rax*10
```
