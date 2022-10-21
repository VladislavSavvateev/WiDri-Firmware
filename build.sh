wine _exec/ASM68K.exe /o op+ /o os+ /o ow+ /o oz+ /o oaq+ /o osq+ /o omq+ /p /o ae- main.asm, rom.bin, rom.sym, rom.lst
wine _exec/ConvSym.exe rom.sym rom.bin -input asm68k_sym -a