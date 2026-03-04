# 10 - İşletim Sistemi Geliştirme (OS Dev) Temelleri

## İçerik

| Dosya | Açıklama |
|-------|----------|
| [`boot.asm`](./boot.asm) | 16-bit Basit BIOS Bootloader (MBR) Örneği |

## OS Dev (İşletim Sistemi Geliştirme) Nedir?

Gündelik bilgisayar programları (kullanıcı alanı / user space) işletim sistemine (ve kernel'e) bağımlıdır. Bir program ekran kartına yazı yazdırmak istediğinde işletim sisteminden yardım ister (sistem çağrıları, syscall'lar).

İşletim sistemi geliştirmek demek; her şeyin en temeline inmek, işlemciyi doğrudan kontrol etmek, belleği kendimiz haritalamak (Paging) ve donanım sürücülerini yazmak demektir.

## Bootloader (Önyükleyici) Kavramı

Bir bilgisayarın güç düğmesine bastığınızda:

1. **POST (Power-On Self-Test):** Donanımı test eder.
2. **BIOS/UEFI:** Anakartta gömülü kod çalışır, bağlı diskleri tarar.
3. Diskler üzerinde sihirli `0xAA55` imzasına sahip olan 512 Byte büyüklüğünde bir sektör arar (Master Boot Record - MBR).
4. Bu 512 byte'lık küçük kod parçasını bellek adresinde `0x7C00` konumuna yükleyip işlemciye "Hadi çalıştır" komutu verir.

Bizim `boot.asm` kodumuz tam olarak bu 512 byte boyutundaki minik işletim sistemidir!

## Derleme ve Çalıştırma

Bir bootloader Linux syscall'larını veya C standart kütüphanelerini kullanamaz. O yüzden **"Bare Metal"** (Çıplak Donanım) çalışır. Bu yüzden programımız bir Linux çalıştırılabilir dosyası (ELF) değil, saf `binary` (bin) olmak zorundadır.

**Derlemek için:**
```bash
nasm -f bin boot.asm -o boot.bin
```

Bunu gerçek bir bilgisayarda denemek için bir USB belleğe `dd` komutuyla yazdırıp bilgisayarı başlatabilirsiniz. Ancak tehlikeli olmaması ve pratik olması adına bir **sanal makine veya emülatör (QEMU, Bochs, VirtualBox vb.)** üzerinden deneriz.

**QEMU ile çalıştırmak için:**

```bash
# Ubuntu/Debian'da QEMU kurmak:
sudo apt install qemu-system-x86

# Bootloader'ımızı bilgisayar takılmış bir disk gibi çalıştır:
qemu-system-x86_64 -drive format=raw,file=boot.bin
```

## Önemli Kod Notları

- `[BITS 16]`: Modern işlemciler 64-bit bile olsa geriye dönük uyumluluk nedeniyle ilk açılışta 16-bit eski Intel 8086 modunda çalışırlar (Buna **Real Mode** denir). 64-bit moda geçmek için GDT ve Paging ayarları yapılmalıdır.
- `int 0x10`: BIOS Video kesintisidir (Interrupt). Ekran kartına karakter basmak, ekran modunu ayarlamak için doğrudan ROM'daki BIOS'tan yardım ister. İşletim sistemi devreye girene kadar en pratik görüntü alma yöntemidir.

İleri seviye bir MBR ile kernel (örneğin C, C++ veya Rust ile yazılmış) diske yüklenir, 32-bit Korumalı Moda (Protected Mode) ve nihayet 64-bit Uzun Moda (Long Mode) geçilir. OS Development uzun bir yolculuktur!
