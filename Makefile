AS=asl
P2BIN=p2bin
SRC=sf2hfcps2.s
WOFASRC=wofacps2.s
# Bsplit comes from https://github.com/mikejmoffitt/romtools
BSPLIT=bsplit
CPS1TOFLAT=cps1toflat
REVERSE=reverse

SF2_PRG1=s2tj_23.8f
SF2_PRG2=s2tj_22.7f
SF2_PRG3=s2tj_21.6f

WOFA_PRG1=tk2a_23c.8f
WOFA_PRG2=tk2a_22c.7f

ASFLAGS=-i . -n -U -L

.PHONY: all clean prg.bin ssf2ud

all: prg.bin

prg.orig:
# The original binaries are byteswapped.
	$(BSPLIT) x $(SF2_PRG1) cpu1.bin
	$(BSPLIT) x $(SF2_PRG2) cpu2.bin
	$(BSPLIT) x $(SF2_PRG3) cpu3.bin
	cat cpu1.bin cpu2.bin cpu3.bin > prg.orig
	rm cpu1.bin
	rm cpu2.bin
	rm cpu3.bin

prg.o: prg.orig
	$(AS) $(SRC) $(ASFLAGS) -o prg.o

prg.bin: prg.o
	$(P2BIN) $< $@ -r \$$-0x3FFFFF

ssf2ud: prg.bin
# Flat program
	split prg.bin -b 524288
	$(BSPLIT) x xaa ssfud.03a
	$(BSPLIT) x xab ssfud.04a
	$(BSPLIT) x xac ssfud.05
	$(BSPLIT) x xad ssfud.06
	$(BSPLIT) x xae ssfud.07

# Graphics splicing	

	split -b 262144 s92_01.3a
	$(BSPLIT) c xaa xab gfx_13m_a 2
	split -b 262144 s92_05.7a
	$(BSPLIT) c xaa xab gfx_13m_b 2
	split -b 262144 s2t_10.3c
	$(BSPLIT) c xaa xab gfx_13m_c 2
	
	split -b 262144 s92_02.4a
	$(BSPLIT) c xaa xab gfx_17m_a 2
	split -b 262144 s92_06.8a
	$(BSPLIT) c xaa xab gfx_17m_b 2
	split -b 262144 s2t_12.5c
	$(BSPLIT) c xaa xab gfx_17m_c 2
	
	split -b 262144 s92_03.5a
	$(BSPLIT) c xaa xab gfx_15m_a 2
	split -b 262144 s92_07.9a
	$(BSPLIT) c xaa xab gfx_15m_b 2
	split -b 262144 s2t_11.4c
	$(BSPLIT) c xaa xab gfx_15m_c 2
	
	split -b 262144 s92_04.6a
	$(BSPLIT) c xaa xab gfx_19m_a 2
	split -b 262144 s92_08.10a
	$(BSPLIT) c xaa xab gfx_19m_b 2
	split -b 262144 s2t_13.6c
	$(BSPLIT) c xaa xab gfx_19m_c 2

	cat gfx_13m_a gfx_13m_b gfx_13m_c gfx_13m_c > ssf.13m
	cat gfx_17m_a gfx_17m_b gfx_17m_c gfx_17m_c > ssf.17m # Swap kludge
	cat gfx_15m_a gfx_15m_b gfx_15m_c gfx_15m_c > ssf.15m
	cat gfx_19m_a gfx_19m_b gfx_19m_c gfx_19m_c > ssf.19m

	cat gfx_13m_c gfx_13m_c > ssf.14m
	cat gfx_17m_c gfx_17m_c > ssf.18m
	cat gfx_15m_c gfx_15m_c > ssf.16m
	cat gfx_19m_c gfx_19m_c > ssf.20m

	rm gfx*
	rm xa*

darksoft: ssf2ud
	# Package graphics and program for Darksoft CPS2 kit
	mkdir -p sf2hfjcps2/
	$(BSPLIT) x prg.bin sf2hfjcps2/hs2.02
	cat ssf.13m ssf.14m > sf2hfjcps2/hs2.05
	cat ssf.15m ssf.16m > sf2hfjcps2/hs2.07
	cat ssf.17m ssf.18m > sf2hfjcps2/hs2.09
	cat ssf.19m ssf.20m > sf2hfjcps2/hs2.11
	# Sound ROM and Qsound sample data come from Hyper SF2 Anniversary

clean:
	@-rm *prg.orig
	@-rm *prg.bin
	@-rm *prg.o
	@-rm -rf ./sf2hfjcps2/
	@-rm ssf.*
	@-rm wf2.*

mvcud: prg.bin
	split prg.bin -b 524288
	$(BSPLIT) x xaa mvcud.03d
	$(BSPLIT) x xab mvcud.04d
	$(BSPLIT) x xac mvc.05a

ps:
	split -b 262144 ps-1m.3a
	$(BSPLIT) c xaa xab gfx_13m_a 2
	split -b 262144 ps-5m.7a
	$(BSPLIT) c xaa xab gfx_13m_b 2
	
	split -b 262144 ps-2m.4a
	$(BSPLIT) c xaa xab gfx_17m_a 2
	split -b 262144 ps-6m.8a
	$(BSPLIT) c xaa xab gfx_17m_b 2
	
	split -b 262144 ps-3m.5a
	$(BSPLIT) c xaa xab gfx_15m_a 2
	split -b 262144 ps-7m.9a
	$(BSPLIT) c xaa xab gfx_15m_b 2
	
	split -b 262144 ps-4m.6a
	$(BSPLIT) c xaa xab gfx_19m_a 2
	split -b 262144 ps-8m.10a
	$(BSPLIT) c xaa xab gfx_19m_b 2

	cat gfx_13m_a gfx_13m_b > gfx_13m_c
	cat gfx_17m_a gfx_17m_b > gfx_17m_c
	cat gfx_15m_a gfx_15m_b > gfx_15m_c
	cat gfx_19m_a gfx_19m_b > gfx_19m_c
	
	cat gfx_13m_c gfx_13m_c gfx_13m_c gfx_13m_c > psu.13m
	cat gfx_17m_c gfx_17m_c gfx_17m_c gfx_17m_c > psu.17m
	cat gfx_15m_c gfx_15m_c gfx_15m_c gfx_15m_c > psu.15m
	cat gfx_19m_c gfx_19m_c gfx_19m_c gfx_19m_c > psu.19m
	
	rm gfx*
	rm xa*

wofaprg.orig:
	$(BSPLIT) x $(WOFA_PRG1) cpu1.bin
	$(BSPLIT) x $(WOFA_PRG2) cpu2.bin
	cat cpu1.bin cpu2.bin > $@
	rm cpu1.bin
	rm cpu2.bin

wofaprg.o: wofaprg.orig
	$(AS) $(WOFASRC) $(ASFLAGS) -o $@ 

wofaprg.bin: wofaprg.o
	$(P2BIN) $< $@ -r \$$-0x3FFFFF
	
wofaprg: wofaprg.bin
	split wofaprg.bin -b 524288
	$(BSPLIT) x xaa wf2.03
	$(BSPLIT) x xab wf2.04
	$(BSPLIT) x xac wf2.05
	rm xa*

wofagfx:
	split -b 262144 tk2-1m.3a
	$(BSPLIT) c xaa xab gfx_13m_a 2
	split -b 262144 tk2-5m.7a
	$(BSPLIT) c xaa xab gfx_13m_b 2
	
	split -b 262144 tk2-2m.4a
	$(BSPLIT) c xaa xab gfx_17m_a 2
	split -b 262144 tk2-6m.8a
	$(BSPLIT) c xaa xab gfx_17m_b 2
	
	split -b 262144 tk2-3m.5a
	$(BSPLIT) c xaa xab gfx_15m_a 2
	split -b 262144 tk2-7m.9a
	$(BSPLIT) c xaa xab gfx_15m_b 2
	
	split -b 262144 tk2-4m.6a
	$(BSPLIT) c xaa xab gfx_19m_a 2
	split -b 262144 tk2-8m.10a
	$(BSPLIT) c xaa xab gfx_19m_b 2

	cat gfx_13m_a gfx_13m_b > gfx_13m_c
	cat gfx_17m_a gfx_17m_b > gfx_17m_c
	cat gfx_15m_a gfx_15m_b > gfx_15m_c
	cat gfx_19m_a gfx_19m_b > gfx_19m_c
	
	cat gfx_13m_c gfx_13m_c gfx_13m_c gfx_13m_c > wf2.13m
	cat gfx_17m_c gfx_17m_c gfx_17m_c gfx_17m_c > wf2.17m
	cat gfx_15m_c gfx_15m_c gfx_15m_c gfx_15m_c > wf2.15m
	cat gfx_19m_c gfx_19m_c gfx_19m_c gfx_19m_c > wf2.19m
	
	rm gfx*
	rm xa*