# Makefile - Assembly Learning Journey
# Tüm bölümleri tek komutla derlemek için
#
# Kullanım:
#   make all      - Tüm programları derle
#   make clean    - Derleme çıktılarını sil
#   make hello    - Sadece hello_world derle
#   make run      - hello_world çalıştır

NASM    := nasm
LD      := ld
CC      := gcc
NASMFLAGS := -f elf64 -g -F dwarf
LDFLAGS :=

# Bölümler ve kaynak dosyalar
SRCS_00 := 00_Basics/hello_world.asm 00_Basics/registers.asm
SRCS_01 := 01_Data_Types/integers.asm 01_Data_Types/strings.asm
SRCS_02 := 02_Control_Flow/conditionals.asm 02_Control_Flow/loops.asm
SRCS_03 := 03_Procedures/functions.asm 03_Procedures/stack.asm
SRCS_04 := 04_Memory/memory_addressing.asm
SRCS_05 := 05_System_Calls/linux_syscalls.asm
SRCS_06 := 06_Optimization/loop_unrolling.asm 06_Optimization/branch_opt.asm
SRCS_07 := 07_Projects/calculator.asm 07_Projects/string_utils.asm 07_Projects/number_printer.asm 07_Projects/xor_cipher.asm
SRCS_08 := 08_FPU_SIMD/fpu_basics.asm 08_FPU_SIMD/simd_ops.asm
SRCS_09 := 09_Inline_Asm/inline.c
SRCS_10 := 10_OS_Dev/boot.asm

ALL_SRCS := $(SRCS_00) $(SRCS_01) $(SRCS_02) $(SRCS_03) $(SRCS_04) $(SRCS_05) $(SRCS_06) $(SRCS_07) $(SRCS_08)
ASM_ONLY := $(filter %.asm, $(ALL_SRCS) $(SRCS_10))

# Her .asm -> bin/ klasöründe binary
BINS := $(patsubst %.asm, bin/%, $(ALL_SRCS))

.PHONY: all clean hello run check dirs

all: dirs $(BINS) bin/09_Inline_Asm/inline bin/10_OS_Dev/boot
	@echo ""
	@echo "✅ Tüm programlar başarıyla derlendi!"
	@echo "   Binaries: bin/ dizininde"

dirs:
	@mkdir -p bin/00_Basics bin/01_Data_Types bin/02_Control_Flow \
	           bin/03_Procedures bin/04_Memory bin/05_System_Calls \
	           bin/06_Optimization bin/07_Projects bin/08_FPU_SIMD \
	           bin/09_Inline_Asm bin/10_OS_Dev

# Genel kural: .asm -> .o -> binary
bin/%: %.asm
	@echo "  [ASM] $<"
	@if [ "$*" = "10_OS_Dev/boot" ]; then \
		$(NASM) -f bin $< -o $@; \
	else \
		$(NASM) $(NASMFLAGS) $< -o $@.o; \
		$(LD) $(LDFLAGS) $@.o -o $@; \
		rm -f $@.o; \
	fi
	@echo "  [OK ] $@"

# C + Inline Asm kuralı
bin/09_Inline_Asm/inline: 09_Inline_Asm/inline.c
	@echo "  [CC ] $<"
	@$(CC) $< -o $@
	@echo "  [OK ] $@"

# Hızlı hedefler
hello: bin/00_Basics/hello_world
	@echo "Derlendi: bin/00_Basics/hello_world"

run: hello
	@echo "--- Çıktı ---"
	@./bin/00_Basics/hello_world

# Sadece syntax kontrolü (linksiz)
check:
	@echo "Syntax kontrol ediliyor..."
	@for f in $(ASM_ONLY); do \
		$(NASM) -f elf64 $$f -o /dev/null 2>&1 && echo "  OK: $$f" || echo "  FAIL: $$f"; \
	done

clean:
	@rm -rf bin/
	@find . -name "*.o" -delete
	@echo "🧹 Temizlendi!"

# İstatistik
stats:
	@echo "📊 Repo İstatistikleri"
	@echo "   .asm dosyası: $$(find . -name '*.asm' | wc -l)"
	@echo "   Toplam satır: $$(find . -name '*.asm' | xargs wc -l 2>/dev/null | tail -1 | awk '{print $$1}')"
	@echo "   .md dosyası:  $$(find . -name '*.md' | wc -l)"

help:
	@echo "Assembly Learning Journey - Makefile"
	@echo ""
	@echo "Hedefler:"
	@echo "  make all    - Tüm programları derle"
	@echo "  make hello  - Hello World derle"
	@echo "  make run    - Hello World çalıştır"
	@echo "  make check  - Syntax kontrolü yap"
	@echo "  make clean  - Derlenleri sil"
	@echo "  make stats  - Repo istatistiklerini göster"
