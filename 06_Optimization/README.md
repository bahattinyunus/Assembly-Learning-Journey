# 06 - Optimizasyon (Optimization)

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`loop_unrolling.asm`](./loop_unrolling.asm) | Döngü açma teknikleri ve paralel accumulator |
| [`branch_opt.asm`](./branch_opt.asm) | Branchless kod, CMOV, bit manipulation |

## Neden Optimizasyon?

Modern CPU'ların iç dünyasında birkaç kritik kavram:

| Kavram | Açıklama |
|--------|----------|
| **Pipeline** | Instruction'lar sırayla aşamalarda yürütülür |
| **Branch Prediction** | CPU şarta göre hangi kolu seçeceğini TAHMİN eder |
| **Out-of-Order Execution** | CPU instruction'ları sırasız çalıştırabilir |
| **ILP** (Instruction Level Parallelism) | Bağımsız instruction'lar aynı anda çalışır |

## Loop Unrolling

```nasm
; Sıradan döngü: N kez branch
.loop:
    add rax, [rsi + rcx * 8]
    inc rcx
    cmp rcx, N
    jl  .loop

; 4x Unroll: N/4 kez branch (4x daha az overhead)
.loop:
    add rax, [rsi + rcx * 8]
    add rax, [rsi + rcx * 8 + 8]
    add rax, [rsi + rcx * 8 + 16]
    add rax, [rsi + rcx * 8 + 24]
    add rcx, 4
    cmp rcx, N
    jl  .loop
```

## Branchless Programlama

### CMOV (Conditional Move)

```nasm
; Branch'li min():
cmp rdi, rsi
jle .a_smaller
mov rax, rsi
jmp .done
.a_smaller:
mov rax, rdi

; Branchless min() - TEK INSTRUCTION:
mov rax, rdi
cmp rdi, rsi
cmovg rax, rsi   ; if rdi > rsi: rax = rsi
```

### Branchless Absolute Value (SAR+XOR Trick)

```nasm
mov rdx, rdi
sar rdx, 63      ; negatifse: 0xFFFF... pozitifse: 0x0000...
xor rax, rdx
sub rax, rdx     ; = abs(rdi)
```

## Faydalı Bit Tricks

```nasm
x & (x-1)    ; en düşük set biti sıfırla
x & (-x)     ; en düşük set biti izole et
x | (x-1)    ; en düşük sıfır biti set et
!(x & (x-1)) ; 2'nin kuvveti mi?
~x & (x+1)   ; sonraki bit sıfırdan 1'e geçiş
```

## Kaynaklar
- [Agner Fog Optimization Manuals](https://www.agner.org/optimize/)
- [Intel Intrinsics Guide](https://www.intel.com/content/www/us/en/docs/intrinsics-guide/)
