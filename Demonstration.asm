 ;Need to figure out how to return to the reset state/state when board is programed.
 ;As of right now, code will break if you try to test multiple things without reprogramming.
 ;Make sure all switches are down before testing.
 ;Switch 7,8,9 changes all pixels to Red, Green, Blue respectively; can turn switch on and off and they'll work.
 ;Demonstration.asm
 
 ; 0 - set 0,6,190 to 16 bit BRG  ----- ok
 ; 1 - set 1, 6 to 24 bit yellow ----- works-ish
 ; 2 - ece 2031 using 16 bits
 ; 3 - comparison between 16 bit and 24 bit --- does not work
 ; 4 - auto increment 5 times from 0 with Green ----- ok
 ; 5 - rainbow  ------ ok 
 ; 6 - single color ---- ok
 ; 7 - all blue --- together prb
 ; 8 - all green ---- togther prb
 ; 9 - all red  ------ together prb
 
 ; In the demo, pxl_all has bugs demo it in the end
 ; Rainbow pattern does not clear completely, so demo it towards the end
 ; In demo, dont demo pxl_all repeatedly and dont do anything too quickly 
 
 ; Possible order for switches: 0, 1, 4, 6, 5, 7/8/9
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
	
	LOADI  17
	OUT    PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
	OUT    PXL_24_RED
	LOADI  &B00000000
	OUT    PXL_24_GREEN
	LOADI  &B11111111
	OUT    PXL_24_BLUE
	
	LOADI  45
	OUT    PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
	OUT    PXL_24_RED
	LOADI  &B00000000
	OUT    PXL_24_GREEN
	LOADI  &B11111111
	OUT    PXL_24_BLUE
	
	LOADI  47
	OUT    PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
	OUT    PXL_24_RED
	LOADI  &B00000000
	OUT    PXL_24_GREEN
	LOADI  &B11111111
	OUT    PXL_24_BLUE
	
	LOADI  79
	OUT    PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
	OUT    PXL_24_RED
	LOADI  &B00000000
	OUT    PXL_24_GREEN
	LOADI  &B11111111
	OUT    PXL_24_BLUE
	
	LOADI  83
	OUT    PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
	OUT    PXL_24_RED
	LOADI  &B00000000
	OUT    PXL_24_GREEN
	LOADI  &B11111111
	OUT    PXL_24_BLUE
	
	LOADI  173
	OUT    PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
	OUT    PXL_24_RED
	LOADI  &B00000000
	OUT    PXL_24_GREEN
	LOADI  &B11111111
	OUT    PXL_24_BLUE
	
	LOADI  175
	OUT    PXL_A
	OUT    PXL_24BITCOLOR
	LOADI  &B11111111
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
	OUT    PXL_A
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
	
	LOADI  0 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	
	LOADI  2
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  3
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  4 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  6 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  7
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  8 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  10 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  11
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  12 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  21 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  22 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  23
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  25
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  26 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  27 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  29
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  30 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  31 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  32
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  36
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  40
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  51 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  55
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  57
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  62
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  63
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  64
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  66
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  70
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  72
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  76
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  87
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  91
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  95
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  96
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  97 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  98
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  100 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  104
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  105
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  106
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  115
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  116
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  117
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  119
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  121
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  123
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  124
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  125
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  127
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  128
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  130
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  134
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  136
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  138
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  151
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  155
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  159
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  160
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  161
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  162
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  164
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  165
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  166
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  168
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  169
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  170
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  179
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
	LOADI  180 
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  181
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  183
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  184
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  185
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  187
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  188
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  189
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	LOADI  191
	OUT	   PXL_A
	LOAD   BLUECOLOR
	OUT    PXL_D
	
	
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
	
	LOAD   zero
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