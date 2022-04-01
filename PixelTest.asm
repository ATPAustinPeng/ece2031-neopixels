; Simple test for the NeoPixel peripheral

ORG 0
LOOP:
    LOADI  0
    OUT    PXL_A
    LOAD   BLUECOLOR
    OUT    PXL_D
	LOADI  1
    OUT    PXL_A
    LOAD   BLUECOLOR
    OUT    PXL_D

	
	LOADI  6
    OUT    PXL_A
    LOAD   REDCOLOR
    OUT    PXL_D
	LOADI  7
    OUT    PXL_A
    LOAD   GREENCOLOR
    OUT    PXL_D
	
    JUMP   LOOP

REDCOLOR: DW &B1111100000000000
BLUECOLOR: DW &B0000000000011111
GREENCOLOR: DW &B0000011111100000

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1