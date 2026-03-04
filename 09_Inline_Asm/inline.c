// ============================================================
// inline.c - C/C++ içinde Inline Assembly (GCC Extended Asm)
// Platform: Linux x86-64
// Derleme: gcc inline.c -o inline_app
// ============================================================

#include <stdio.h>
#include <stdint.h>

// 1. Basit Assembly (Sadece CPU instruction çalıştırma)
void no_op_example() {
    // "asm" veya "__asm__" kullanılabilir
    __asm__("nop"); // No Operation (Hiçbir şey yapma, 1 cycle bekler)

    // CPUID'yi çağırmak gibi kısıtlı komutlar
    // Bu kod x86'ya özgü CPU kimlik doğrulama komutunu çağırır.
}

// 2. C Değişkenlerini Kullanarak Toplama (Extended Asm)
// GCC AT&T syntax'ına mecbur kalmadan (intel) direktifi ile yazabiliriz.
int add_asm(int a, int b) {
    int result;
    
    // GCC tarzı Extended Asm: (şablon : çıkışlar : girişler : değişen_registerlar)
    __asm__ (
        "add %0, %1"     // Komut
        : "+r" (a)       // Çıkış (a hem okundu hem yazıldı)
        : "r" (b)        // Giriş (b sadece okundu)
    );
    
    result = a;
    return result;
}

// 3. Değerleri Değiştirme (Swap) - CMOV ve XOR kullanımına örnek
void swap_asm(int *a, int *b) {
    // "m" memory referansıdır. Register yerine direkt hafızaya müdahale edilebilir.
    __asm__ (
        "mov eax, [%0]\n\t"
        "mov ebx, [%1]\n\t"
        "xchg eax, ebx\n\t"
        "mov [%0], eax\n\t"
        "mov [%1], ebx"
        : // Çıkış yok, pointer değerini değiştiriyoruz
        : "r" (a), "r" (b)
        : "eax", "ebx", "memory" // Register ve hafıza kullanımını derleyiciye bildir
    );
}

// 4. CPU Döngü Sayacı (RDTSC) Okuma
// x86'da Time Stamp Counter, CPU başladığından beri geçen cycle sayısını tutar.
uint64_t rdtsc_read() {
    uint32_t lo, hi;
    __asm__ __volatile__ (
        "rdtsc"
        : "=a" (lo), "=d" (hi) // 'rdtsc' -> EAX=low, EDX=high
    );
    return ((uint64_t)hi << 32) | lo;
}

int main() {
    printf("=== GCC Inline Assembly Testi ===\n\n");

    // Test 1
    int x = 15, y = 27;
    int sum = add_asm(x, y);
    printf("[1] Toplama: %d + %d = %d\n", x, y, sum);

    // Test 2
    int val1 = 100, val2 = 500;
    printf("[2] Swap oncesi: val1=%d, val2=%d\n", val1, val2);
    swap_asm(&val1, &val2);
    printf("    Swap sonrasi: val1=%d, val2=%d\n", val1, val2);

    // Test 3
    uint64_t start = rdtsc_read();
    for(volatile int i=0; i<1000000; i++) {} // Zaman geçirme (volatile: optimizasyon silmesin diye)
    uint64_t end = rdtsc_read();
    
    printf("[3] Gecen CPU Cycle (RDTSC): %lu\n", (end - start));

    return 0;
}
