@ Author: mvanditc
@ Application: Stopwatch with start, pause, reset, and lap functionalities.
@ Controls:
@	Push Buttons:
@		NOTE: Design to handle 1 active button at a time.
@		0: Start/Unpause Timer
@		1: Pause Timer
@		2: Record Lap
@		3: Reset Timer back to 000000
@	Switches:
@		0: Displays stored lap time if active.
@ Technology:
@	- This program uses the Cortex-A9 Private Timer for measurement.
@	- This program is intended to run on https://cpulator.01xz.net/?sys=arm-de1soc
@	- If you use a program like Intel FPGA Monitor Program, it can work, as long as the addresses are proper and all needed technology is present.
.global _start
 
.equ ADDR_7SEG1, 0xFF200020
.equ ADDR_7SEG2, 0xFF200030
.equ ADDR_PUSHBUTTONS, 0xFF200050@Values=1,2,4,8
.equ ADDR_SWITCH, 0xFF200040 @1 = ON, 0 = OFF
 
.equ SEGVALUEFOR0, 63
.equ SEGVALUEFOR1, 6
.equ SEGVALUEFOR2, 91
.equ SEGVALUEFOR3, 79
.equ SEGVALUEFOR4, 230
.equ SEGVALUEFOR5, 237
.equ SEGVALUEFOR6, 253
.equ SEGVALUEFOR7, 7
.equ SEGVALUEFOR8, 255
.equ SEGVALUEFOR9, 239
 
_start:
	@ldr r0, =0xfffec600 @Timer Address
	@ldr r1, =1666666 @Defined cycle time: 1/0.01 seconds
	@ldr r1, =2000
	@mov r2, #1 @Control Bits: start timer
waitToStart:
	ldr r3, =0xFF200050
	ldr r0, [r3]
	cmp r0, #1
	bne waitToStart
 
	ldr r3, =0xFF200020 @7Seg Address
	ldr r4, =1061109567 @Value to Show 1
 
	mov r5, #0 @Clock Centiseconds Counter 1
	mov r6, #0 @Clock Centiseconds Counter 2
	mov r7, #0 @Clock Seconds Counter 1
	mov r8, #0 @Clock Seconds Counter 2
	mov r9, #0 @Clock Minutes Counter 1
	mov r10, #0 @Clock Minutes Counter 2
 
	str r4, [r3] @Set 7Seg to --0000
	str r4, [r3, #16] @Set 7Seg to 000000
 
	b setCountPeriod
 
setCountPeriod:
	ldr r2, =1666666 @Defined cycle time: 1/0.01 seconds
	@ldr r2, =5000
	ldr r0, =0xfffec600 @Timer Address
 
	str r2, [r0] @Store clock period in timer
	ldr r2, =1 @Control Bits: start timer
	str r2, [r0, #8] @Store/Apply Control Bits
	b checkCurrentCount
 
handleTime: @ This branch increments the time for all registers used to store time.
	add r5, r5, #1
 
	cmp r5, #10
	beq add10Centisecond
	b doneTimeHandle
 
add10Centisecond:
	sub r5, r5, #10
	add r6, r6, #1
	cmp r6, #10
	beq add1Second
	b doneTimeHandle
add1Second:
	sub r6, r6, #10
	add r7, r7, #1
	cmp r7, #10
	beq add10Second
	b doneTimeHandle
add10Second:
	sub r7, r7, #10
	add r8, r8, #1
	cmp r8, #6
	beq add1Minute
	b doneTimeHandle
add1Minute:
	sub r8, r8, #6
	add r9, r9, #1
	cmp r9, #10
	beq add10Minute
	b doneTimeHandle
add10Minute:
	sub r9, r9, #10
	add r10, r10, #1
	b doneTimeHandle
 
doneTimeHandle:
	push {r2, r3}
	ldr r3, =0xFF200040
	ldr r2, [r3]
	cmp r2, #1
	beq displayLapTime
 
	pop {r2, r3}
 
	b set7Seg1
 
displayLapTime:
	pop {r2, r3}
	push {r2, r11}
 
	ldr r11, =0xff200020
 
	ldr r2, [r1]
	str r2, [r11]
	ldr r2, [r1, #16]
	str r2, [r11, #16]
 
	pop {r2, r11}
	cmp r10, #6
	bhs _end
 
	b setCountPeriod
 
 
 
set7Seg1:
	cmp r5, #0
	beq set7Seg1_0
	cmp r5, #1
	beq set7Seg1_1
	cmp r5, #2
	beq set7Seg1_2
	cmp r5, #3
	beq set7Seg1_3
	cmp r5, #4
	beq set7Seg1_4
	cmp r5, #5
	beq set7Seg1_5
	cmp r5, #6
	beq set7Seg1_6
	cmp r5, #7
	beq set7Seg1_7
	cmp r5, #8
	beq set7Seg1_8
	cmp r5, #9
	beq set7Seg1_9
 
	b set7Seg2
set7Seg1_0:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR0
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_1:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR1
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_2:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR2
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_3:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR3
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_4:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR4
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_5:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR5
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_6:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR6
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_7:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR7
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_8:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR8
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg1_9:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR9
	orr r11, r11, r4
	str r11, [r3]
	pop {r4}
 
	b set7Seg2
set7Seg2:
	cmp r6, #0
	beq set7Seg2_0
	cmp r6, #1
	beq set7Seg2_1
	cmp r6, #2
	beq set7Seg2_2
	cmp r6, #3
	beq set7Seg2_3
	cmp r6, #4
	beq set7Seg2_4
	cmp r6, #5
	beq set7Seg2_5
	cmp r6, #6
	beq set7Seg2_6
	cmp r6, #7
	beq set7Seg2_7
	cmp r6, #8
	beq set7Seg2_8
	cmp r6, #9
	beq set7Seg2_9
 
	b set7Seg3
set7Seg2_0:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR0
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_1:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR1
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_2:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR2
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_3:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR3
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_4:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR4
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_5:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR5
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_6:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR6
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_7:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR7
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_8:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR8
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg2_9:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR9
	orr r11, r11, r4, LSL #8
	str r11, [r3]
	pop {r4}
 
	b set7Seg3
set7Seg3:
	cmp r7, #0
	beq set7Seg3_0
	cmp r7, #1
	beq set7Seg3_1
	cmp r7, #2
	beq set7Seg3_2
	cmp r7, #3
	beq set7Seg3_3
	cmp r7, #4
	beq set7Seg3_4
	cmp r7, #5
	beq set7Seg3_5
	cmp r7, #6
	beq set7Seg3_6
	cmp r7, #7
	beq set7Seg3_7
	cmp r7, #8
	beq set7Seg3_8
	cmp r7, #9
	beq set7Seg3_9
 
	b set7Seg4
set7Seg3_0:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR0
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_1:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR1
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_2:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR2
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_3:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR3
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_4:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR4
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_5:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR5
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_6:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR6
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_7:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR7
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_8:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR8
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg3_9:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0xFF00FFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR9
	orr r11, r11, r4, LSL #16
	str r11, [r3]
	pop {r4}
 
	b set7Seg4
set7Seg4:
	cmp r8, #0
	beq set7Seg4_0
	cmp r8, #1
	beq set7Seg4_1
	cmp r8, #2
	beq set7Seg4_2
	cmp r8, #3
	beq set7Seg4_3
	cmp r8, #4
	beq set7Seg4_4
	cmp r8, #5
	beq set7Seg4_5
	cmp r8, #6
	beq set7Seg4_6
 
	b set7Seg4
set7Seg4_0:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0x00FFFFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR0
	orr r11, r11, r4, LSL #24
	str r11, [r3]
	pop {r4}
 
	b set7Seg5
set7Seg4_1:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0x00FFFFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR1
	orr r11, r11, r4, LSL #24
	str r11, [r3]
	pop {r4}
 
	b set7Seg5
set7Seg4_2:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0x00FFFFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR2
	orr r11, r11, r4, LSL #24
	str r11, [r3]
	pop {r4}
 
	b set7Seg5
set7Seg4_3:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0x00FFFFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR3
	orr r11, r11, r4, LSL #24
	str r11, [r3]
	pop {r4}
 
	b set7Seg5
set7Seg4_4:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0x00FFFFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR4
	orr r11, r11, r4, LSL #24
	str r11, [r3]
	pop {r4}
 
	b set7Seg5
set7Seg4_5:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0x00FFFFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR5
	orr r11, r11, r4, LSL #24
	str r11, [r3]
	pop {r4}
 
	b set7Seg5
set7Seg4_6:
	ldr r11, [r3] @Get current value in 7Seg
	and r11, r11, #0x00FFFFFF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR6
	orr r11, r11, r4, LSL #24
	str r11, [r3]
	pop {r4}
 
	b set7Seg5
 
set7Seg5:
	cmp r9, #0
	beq set7Seg5_0
	cmp r9, #1
	beq set7Seg5_1
	cmp r9, #2
	beq set7Seg5_2
	cmp r9, #3
	beq set7Seg5_3
	cmp r9, #4
	beq set7Seg5_4
	cmp r9, #5
	beq set7Seg5_5
	cmp r9, #6
	beq set7Seg5_6
	cmp r9, #7
	beq set7Seg5_7
	cmp r9, #8
	beq set7Seg5_8
	cmp r9, #9
	beq set7Seg5_9
 
	b set7Seg6
set7Seg5_0:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR0
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
 
set7Seg5_1:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR1
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
set7Seg5_2:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR2
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
set7Seg5_3:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR3
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
set7Seg5_4:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR4
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
set7Seg5_5:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR5
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
set7Seg5_6:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR6
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
set7Seg5_7:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR7
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
set7Seg5_8:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR8
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
set7Seg5_9:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFFFF00 @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR9
	orr r11, r11, r4
	str r11, [r3, #16]
	pop {r4}
 
	b set7Seg6
 
set7Seg6:
	cmp r10, #0
	beq set7Seg6_0
	cmp r10, #1
	beq set7Seg6_1
	cmp r10, #2
	beq set7Seg6_2
	cmp r10, #3
	beq set7Seg6_3
	cmp r10, #4
	beq set7Seg6_4
	cmp r10, #5
	beq set7Seg6_5
	cmp r10, #6
	beq set7Seg6_6
 
	b setCountPeriod
set7Seg6_0:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR0
	orr r11, r11, r4, LSL #8
	str r11, [r3, #16]
	pop {r4}
 
	b setCountPeriod
set7Seg6_1:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR1
	orr r11, r11, r4, LSL #8
	str r11, [r3, #16]
	pop {r4}
 
	b setCountPeriod
set7Seg6_2:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR2
	orr r11, r11, r4, LSL #8
	str r11, [r3, #16]
	pop {r4}
 
	b setCountPeriod
set7Seg6_3:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR3
	orr r11, r11, r4, LSL #8
	str r11, [r3, #16]
	pop {r4}
 
	b setCountPeriod
set7Seg6_4:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR4
	orr r11, r11, r4, LSL #8
	str r11, [r3, #16]
	pop {r4}
 
	b setCountPeriod
set7Seg6_5:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR5
	orr r11, r11, r4, LSL #8
	str r11, [r3, #16]
	pop {r4}
 
	b setCountPeriod
set7Seg6_6:
	ldr r11, [r3, #16] @Get current value in 7Seg
	and r11, r11, #0xFFFF00FF @ Mask out bits to change
 
	push {r4}
	mov r4, #SEGVALUEFOR6
	orr r11, r11, r4, LSL #8
	str r11, [r3, #16]
	pop {r4}
 
	b _end @ If segment 6 is being set to 6, it means the timer is maxed out.
 
resetWhilePaused:
	ldr r5, =0
	ldr r6, =0
	ldr r7, =0
	ldr r8, =0
	ldr r9, =0
	ldr r10, =0
	
	push {r1, r4}
	ldr r1, =1061109567 @Value to Show 1
	ldr r4, =ADDR_7SEG1 @Value to Show 1
	str r1, [r4] @Set 7Seg to --0000
	str r1, [r4, #16] @Set 7Seg to 000000
	pop {r1, r4}
	b pauseTimer
 
pauseTimer:
	ldr r2, [r3]
	cmp r2, #1
	beq buttonsChecked
	cmp r2, #8
	beq resetWhilePaused
 
	b pauseTimer
 
resetTimer:
	ldr r5, =0
	ldr r6, =0
	ldr r7, =0
	ldr r8, =0
	ldr r9, =0
	ldr r10, =0
 
	b buttonsChecked
 
recordLap:
	push {r0}
	ldr r1, =0xFFFFF000
	ldr r0, =ADDR_7SEG1
	ldr r11, [r0]
	str r11, [r1]
	ldr r0, =ADDR_7SEG2
	ldr r11, [r0]
	str r11, [r1, #16]
	pop {r0}
 
	b buttonsChecked
 
checkButtonStatus:
	ldr r3, =0xFF200050
	ldr r2, [r3]
	cmp r2, #2
	beq pauseTimer
	cmp r2, #4
	beq recordLap
	cmp r2, #8
	beq resetTimer
 
	b buttonsChecked
 
checkCurrentCount:
	ldr r12, [r0, #4]
	push {r2, r3}
	b checkButtonStatus
buttonsChecked:
	pop {r2, r3}
	cmp r12, #0
	beq handleTime @If counter is zero, restart timer to start new clock cycle
	b checkCurrentCount