# Linux x86-64 Sistem Çağrıları (Syscall) Tam Tablosu

Linux x86-64 ortamında programların işletim sistemiyle iletişim kurmasını sağlayan sistem çağrılarının en çok kullanılanları aşağıda listelenmiştir.

> **ABI Kuralı:** Syscall numarasını `RAX` içine koyun, parametreleri `RDI, RSI, RDX, R10, R8, R9` sırasıyla geçin ve `syscall` komutunu çağırın. Dönüş değeri `RAX` içinde olur. Hata durumunda `-ERRNO` (negatif) döner.

## Çok Kullanılan Sistem Çağrıları

| RAX | İsim | RDI (Arg 1) | RSI (Arg 2) | RDX (Arg 3) | R10 (Arg 4) | R8 (Arg 5) | R9 (Arg 6) |
|-----|------|-------------|-------------|-------------|-------------|------------|------------|
| 0 | `read` | unsigned int fd | char *buf | size_t count | | | |
| 1 | `write` | unsigned int fd | const char *buf | size_t count | | | |
| 2 | `open` | const char *filename | int flags | umode_t mode | | | |
| 3 | `close` | unsigned int fd | | | | | |
| 4 | `stat` | const char *filename | struct stat *statbuf | | | | |
| 5 | `fstat` | unsigned int fd | struct stat *statbuf | | | | |
| 8 | `lseek` | unsigned int fd | off_t offset | unsigned int origin | | | |
| 9 | `mmap` | unsigned long addr | unsigned long len | unsigned long prot | unsigned long flags | unsigned long fd | unsigned long pgoff |
| 10 | `mprotect` | unsigned long start | size_t len | unsigned long prot | | | |
| 11 | `munmap` | unsigned long addr | size_t len | | | | |
| 12 | `brk` | unsigned long brk | | | | | |
| 32 | `dup` | unsigned int fildes | | | | | |
| 33 | `dup2` | unsigned int oldfd | unsigned int newfd | | | | |
| 39 | `getpid` | | | | | | |
| 41 | `socket` | int family | int type | int protocol | | | |
| 42 | `connect` | int fd | struct sockaddr *uservaddr | int addrlen | | | |
| 43 | `accept` | int fd | struct sockaddr *upeer_sockaddr | int *upeer_addrlen | | | |
| 49 | `bind` | int fd | struct sockaddr *umyaddr | int addrlen | | | |
| 50 | `listen` | int fd | int backlog | | | | |
| 57 | `fork` | | | | | | |
| 59 | `execve` | const char *filename | const char *const *argv | const char *const *envp | | | |
| 60 | `exit` | int error_code | | | | | |
| 61 | `wait4` | pid_t pid | int *stat_addr | int options | struct rusage *ru | | |
| 62 | `kill` | pid_t pid | int sig | | | | |
| 231| `exit_group` | int error_code | | | | | |

## Hata Kodları (Errno) Örnekleri

| Sayı | İsim | Açıklama |
|------|------|----------|
| 1 | `EPERM` | İşlem izin verilmedi |
| 2 | `ENOENT` | Dosya veya dizin yok |
| 9 | `EBADF` | Geçersiz dosya tanımlayıcı (fd) |
| 11 | `EAGAIN` | Kaynak geçici olarak kullanılamıyor |
| 12 | `ENOMEM` | Yetersiz bellek |
| 13 | `EACCES` | Erişim reddedildi (Permission denied) |
| 14 | `EFAULT` | Bozuk adres |

*Not: Hata kontrolü için `test rax, rax` ve ardından `js` (Jump if Sign) kullanarak RAX'ın negatif olup olmadığını kontrol edebilirsiniz.*

**Tam referans için:** `/usr/include/asm/unistd_64.h` dosyasına veya [Linux Syscall Table(x86_64)](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/) sayfasına bakabilirsiniz.
