; Simple test for the NeoPixel peripheral

ORG 0
LOOP:
	;LOADI 10
	;OUT PXL_ALL
	
	LOAD REDCOLOR
	OUT PXL_ALL
	
	JUMP END
	
	
	
	
	LOADI 10
	OUT PXL_24BITCOLOR
	OUT PXL_A
	
	
	LOADI &B11111111
	OUT PXL_24_RED
	
	LOADI &B11111111
	OUT PXL_24_GREEN
	
	LOADI &B00000000
	OUT PXL_24_BLUE

	JUMP END
	
	;ignore the 256 pixel test for now
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
	LOADI  190
    OUT    PXL_A
    LOAD   GREENCOLOR
    OUT    PXL_D
	
    JUMP   LOOP

END:


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
PXL_ALL:   EQU &H0B2
PXL_24BITCOLOR:   EQU &H0B3
PXL_24_RED: EQU &H0B4
PXL_24_GREEN: EQU &H0B5
PXL_24_BLUE: EQU &HB6