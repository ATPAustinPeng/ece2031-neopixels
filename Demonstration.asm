 ;Need to figure out how to return to the reset state/state when board is programed.
 ;As of right now, code will break if you try to test multiple things without reprogramming.
 ;Make sure all switches are down before testing.
 ;Switch 7,8,9 changes all pixels to Red, Green, Blue respectively; can turn switch on and off and they'll work.
 ;Demonstration.asm
 
 ; 0 - set 0,6,190 to 16 bit BRG  ----- ok
 ; 1 - set 1, 6 to 24 bit yellow ----- works-ish
 ; 2 - 
 ; 3 - comparison between 16 bit and 24 bit --- does not work
 ; 4 - auto increment 5 times from 0 with Green ----- ok
 ; 5 - rainbow
 ; 6 - single color ---- does not work
 ; 7 - all blue --- together prb
 ; 8 - all green ---- togther prb
 ; 9 - all red  ------ together prb
 
 ; In the demo, pxl_all has bugs demo it in the end
 ; Rainbow pattern does not clear completely, so demo it towards the end
 ; In demo, dont demo pxl_all repeatedly and dont do anything too quickly 
 
 ; Possible order for switches: 1, 2, 4, 6, 5, 7/8/9
 ; order: 16 bit for 255 pxls, 24 bit color, autoincrement, single color pattern, rainbow color pattern, pxl_all

ORG 0
 
Start:
	;Switch 0 
	IN		Switches
	AND		Bit0
	JPOS 	ControlPixels
	
	;Switch 1
	IN		Switches
	AND		Bit1
	JPOS 	Color24Bit
	
	;Switch 2
	IN		Switches
	AND		Bit2
	JPOS 	Change16Bit

	;Switch 3
	IN		Switches
	AND		Bit3
	JPOS 	Comp
	
	;Switch 4
	IN 		Switches
	AND		Bit4
	JPOS	AutoIn
	
	;Switch 5
	IN		Switches
	AND		Bit5
	JPOS	RainBow	
	LOAD zero
	
	;Switch 6
	IN 		Switches
	AND		Bit6
	JPOS	OneColorPattern
	
	;Switch 7
	IN 		Switches
	AND		Bit7
	JPOS	ChangeAllBlue
	
	
	;Switch 8
	IN 		Switches
	AND		Bit8
	JPOS	ChangeAllGreen
	
	;Switchh 9
	IN 		Switches
	AND		Bit9
	JPOS	ChangeAllRED
	
	
	JUMP 	Start
	
Comp:
	IN 		Switches
	AND 	BIT3
	JZERO 	START
	
	LOADI 0
	OUT PXL_A
	LOAD BLUECOLOR
	OUT PXL_D
	
	OUT    PXL_24BITCOLOR
	LOADI  &B00000000
	OUT    PXL_24_RED
	LOADI  &B00000000
	OUT    PXL_24_GREEN
	LOADI  &B11111111
	OUT    PXL_24_BLUE
	
	JUMP   Start
	
	


ControlPixels:
	IN 		Switches
	AND 	BIT0
	JZERO 	START
	
	LOADI  0 
	OUT	   PXL_A
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
	
	JUMP   Start
	

Color24Bit:
	IN 	   Switches 
	AND	   BIT1
	JZERO  START 
	
	LOADI  1
	OUT PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
	OUT    PXL_24_RED
	LOADI  &B11111111
	OUT    PXL_24_GREEN
	LOADI  &B00000000
	OUT    PXL_24_BLUE


	
	LOADI  6
	OUT PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
	OUT    PXL_24_RED
	LOADI  &B11111111
	OUT    PXL_24_GREEN
	LOADI  &B00000000
	OUT    PXL_24_BLUE
	
	JUMP   Start


Change16Bit:
	IN	   Switches
	AND	   BIT2
	JZERO  START
	
	
	JUMP   START
	
AutoIn:
	IN	   Switches
	AND	   BIT4
	JZERO  START
	
	LoadI  0
	OUT    PXL_A
	LOAD   GREENCOLOR
	OUT    PXL_D
	OUT    PXL_D
	OUT    PXL_D
	OUT    PXL_D
	OUT    PXL_D
	
	JUMP   Start
	
RainBow:
	IN	   Switches
	AND	   BIT5
	JZERO  START
	LOADI 2
	OUT PATTERN_NUMBER_EN 
	JUMP   Start

OneColorPattern:
	IN	   Switches
	AND	   BIT6
	JZERO  START
	LOAD REDCOLOR
	OUT PXL_D
	LOADI 0
	OUT PATTERN_NUMBER_EN 
	JUMP   Start

ChangeAllRed:
	IN	  Switches
	AND	  Bit9
	JZERO START
	
	LOAD REDCOLOR
	OUT  PXL_ALL
	
	JUMP   Start

	
ChangeAllGreen:
	IN	   Switches
	AND	   BIT8
	JZERO  START
	
	LOAD   GREENCOLOR
	OUT    PXL_ALL
	
	JUMP   Start

ChangeAllBlue:
	IN	   Switches
	AND	   BIT7
	JZERO  START
	
	LOAD   BLUECOLOR
	OUT    PXL_ALL
	
	JUMP   Start


	


DelayAC:
	STORE  DelayTime   ; Save the desired delay
	OUT    Timer       ; Reset the timer
WaitingLoop:
	IN     Timer       ; Get the current timer value
	SUB    DelayTime
	JNEG   WaitingLoop ; Repeat until timer = delay value
	RETURN
DelayTime: DW 0
WAIT_FOR_RAINBOW: DW 20


REDCOLOR:   DW &B1111100000000000
BLUECOLOR:  DW &B0000000000011111
GREENCOLOR: DW &B0000011111100000
WHITECOLOR: DW &B1111111111111111
BitReset:	DW &B0000000000000000
Bit0:	    DW &B0000000000000001
Bit1:	    DW &B0000000000000010
Bit2:	    DW &B0000000000000100
Bit3:	    DW &B0000000000001000
Bit4:	    DW &B0000000000010000
Bit5:	    DW &B0000000000100000
Bit6:	    DW &B0000000001000000
Bit7:	    DW &B0000000010000000
Bit8:	    DW &B0000000100000000
Bit9:	    DW &B0000001000000000
zero:       DW &B0000000000000000

; IO address constants
Switches:          EQU 000
LEDs:              EQU 001
Timer:             EQU 002
Hex0:              EQU 004
Hex1:              EQU 005
PXL_A:             EQU &H0B0
PXL_D:             EQU &H0B1
PXL_ALL:           EQU &H0B2
PXL_24BITCOLOR:    EQU &H0B3
PXL_24_RED:        EQU &H0B4
PXL_24_GREEN:      EQU &H0B5
PXL_24_BLUE:       EQU &H0B6
PATTERN_NUMBER_EN: EQU &H0B7