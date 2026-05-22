;
; ahmedwaqar_alimajid.asm
;
; Created: 12/31/2024 11:04:41 AM
; Author : hp
;


; Replace with your application code
start:
   ;flow of code
;initialize stuff
;store lookup table into data memory for ease
;
;main:
;insert 5 prayers
;want to add more days or not
;select desired day's number to display
;disp_prayers
;insert current_time
;call comparer to find next_prayer
;call time_left (till next prayer)
;current_time_incrementer loop running 
;  display curr_time, next_prayer, time_left
;  equal_checker to alert and update 
;  decrement time_left
;  call delay
;loop


 .INCLUDE  "M32DEF.INC"

.EQU  KEY_PORT  =  PORTC  ;keypad
.EQU  KEY_PIN  =  PINC
.EQU  KEY_DDR  =  DDRC

.EQU  LCD_DPRT  =  PORTA   ;lcd
.EQU  LCD_DDDR  =  DDRA
.EQU  LCD_DPIN  =  PINA
.EQU  LCD_CPRT  =  PORTB
.EQU  LCD_CDDR  =  DDRB
.EQU  LCD_CPIN  =  PINB
.EQU  LCD_RS  =  0
.EQU  LCD_RW  =  1
.EQU  LCD_EN  =  2

.org  0x00
LDI  R16,  HIGH  (RAMEND)  ;stack
 OUT  SPH,R16
LDI  R16,  LOW  (RAMEND)
 OUT  SPL,R16
LDI  R16,  0b11101111 
OUT  DDRA,R16
LDI  R16,  0xF0  
OUT  KEY_DDR,  R16

GroundAllColumns:
LDI  R16,  0x0F  
OUT  KEY_PORT,  R16

LDI  R16,0xFF;
OUT  LCD_DDDR,  R16   
 OUT  LCD_CDDR,  R16 
  CBI  LCD_CPRT,LCD_EN

CALL  DELAY_2ms 
LDI  R16,0x38  
CALL  CMNDWRT   
CALL  DELAY_2ms 
LDI  R16,0x0E  
 CALL  CMNDWRT  
 LDI  R16,0x01  
CALL CMNDWRT
 CALL DELAY_2ms
LDI  R16,0x06  
 CALL CMNDWRT

 ;code starts from here
 ;_________________________________________________________________________
 ldi YL, 0x00
 ldi YH, 0x3
 ldi ZL, low(mydata<<1)  ;loading lookup table
 ldi ZH, high(mydata<<1)
 ldi r18, 140

 temp_loop:  ;to store lookup table into memory for ease
 lpm r16, Z+
 st Y, r16
 inc YL
 dec r18
 brne temp_loop  ;now 0x300s has lookup table
 ;initialization done
 ;_______________________________________

main:

ldi r18, 0  ;to store 5 prayers
insert_pray:
ldi r16, 0x01    
call cmndwrt
call DELAY_2ms
ldi r16, 0x80    
call cmndwrt
call DELAY_2ms   

ldi r16, 'e'     ; 'e' for enter
call datawrt
ldi r16, 'p'      ;'p' for prayer
call datawrt
ldi r16, ':'    
call datawrt
call KPD_ISR   ;tens_hour
st Y, r20   
call DELAY_2ms
ldi r16, 0xC0  ;2nd line
call cmndwrt
call DELAY_2ms 

ld r16, Y+    ;tens_hour 
call datawrt
call KPD_ISR
st Y, r20    
ld r16, Y+    ;ones_hours   
call datawrt
call KPD_ISR
st Y, r20    
ld r16, Y+    ;tens_min
call datawrt
call KPD_ISR
st Y, r20    
ld r16, Y+     ;ones_min
call datawrt
call DELAY
inc r18       ; prayer counter
cpi r18, 5   
brne insert_pray


ldi r16, 0x01     ;clear
call cmndwrt
call DELAY_2ms
ldi r16, 0x80    
call cmndwrt
call DELAY_2ms
ldi r16, 'a'    ;want to add more days?
call datawrt
ldi r16, 'd'
call datawrt
ldi r16, 'd'
call datawrt
ldi r16, '?'
call datawrt
ldi r16, ' '
call datawrt
ldi r16, '1'
call datawrt   ;press 1 if you want to enter more days
ldi r16, '/'   ;otherwise press any thing
call datawrt
ldi r16, 'y'
call datawrt
ldi r16, ':'
call datawrt
call KPD_ISR

ldi r16, '1'
cp r16, r20   ;if entered 1 for adding more days
breq jump_to_insert_pray  ;go back to entering more prayers
brne skip_insert_pray     ;skip ahead to selecting day number

jump_to_insert_pray:  ;goes back to entering more prayer times
ldi r18, 0
rjmp insert_pray

skip_insert_pray: 

;------------------------------------------

select_day:
ldi r16, 0x01     ;clear
call cmndwrt
call DELAY_2ms
ldi r16, 0x80    ;1st line
call cmndwrt
call DELAY_2ms
ldi r16, 'd'
call datawrt
ldi r16, 'a'
call datawrt
ldi r16, 'y'
call datawrt
ldi r16, ' '
call datawrt
ldi r16, 'n'
call datawrt
ldi r16, 'u'
call datawrt
ldi r16, 'm'
call datawrt
ldi r16, '?'
call datawrt
ldi r16, ':'
call datawrt
call KPD_ISR   ;input for day number
mov r18, r20   ;r18 has day_number
subi r18, '0'
cpi r18, 1
breq skip_dayselectloop
dec r18
ldi r16, 5
mul r18,r16
mov r18,r0

ldi YL, 0x00  ;lookup table's data
ldi YH, 0x3

day_select_loop:  ;to find the desired day number 1~8+
inc YL            ;objective is to point Y to the desired day's start
inc YL
inc YL
inc YL
dec r18
cpi r18, 0
brne day_select_loop

skip_dayselectloop:
 
;at this point, Y is pointing at the desired day's start
 ldi XL, 0x00
ldi XH, 0x2   
ldi r18, 200
data_transfer:
ld  r16, Y
inc YL
st X,r16
inc XL
dec r18
cpi r18, 0
brne data_transfer 

ldi YL, 0x00
ldi YH, 0x2      ;200s should contain all desired day's entries
ldi r22,0
;__________________________
disp_prayers:   
ldi r16, 0x01
call cmndwrt
call delay
ldi r16, 0x80
call cmndwrt
call delay
ldi r16, 'p'    ;p
call datawrt
ldi r16, ':'
call datawrt
ld r16, Y     ;tens_hours
call datawrt
inc YL
ld r16, Y     ;ones_hours
call datawrt
ldi r16, ':'
inc YL  
call datawrt
ld r16, Y      ;tens mins
call datawrt
inc YL
ld r16, Y     ;ones mins
call datawrt
inc YL
call delay_1s
inc r22
cpi r22, 5
brne disp_prayers
;_________________________________

insert_curr:    ;will store curr_time in 0x400-403
call DELAY      ;then copy it to 0x700-703
call DELAY
ldi r16, 0x01
call cmndwrt
call DELAY
ldi r16, 0x80
call cmndwrt
ldi r16, 'e'    ;'e' for enter
call datawrt
ldi r16, 'c'    ;'c' for current
call datawrt
ldi r16, ':'
call datawrt
call KPD_ISR
sts 0x400, r20    ;tens hour
mov r16, r20
call datawrt
call KPD_ISR
sts 0x401, r20    ;ones hour
mov r16, r20
call datawrt
call KPD_ISR
sts 0x402, r20    ;tens min
mov r16, r20
call datawrt
call KPD_ISR
sts 0x403, r20    ;ones min
mov r16, r20
call datawrt
call delay

lds r16, 0x400
sts 0x700, r16
lds r16, 0x401
sts 0x701, r16
lds r16, 0x402
sts 0x702, r16
lds r16, 0x403
sts 0x703, r16
;-
; time processing starts from here

call comparer  ;to find next prayer
call time_left

lds r22, 0x400    ;tens hour
lds r23, 0x401    ;ones hour
lds r24, 0x402    ;tens min
lds r25, 0x403    ;ones min


curr_incrementer:
    
    inc r25              ; Increment ones of minutes
    cpi r25, ':'    ; if ascii exceeds '9'
    brlo check_tens_mins  
    ldi r25, '0'             ; Reset ones of minutes
    inc r24               ;increment tens of minutes

check_tens_mins:
    cpi r24, '6'          ; check if tens of minutes = '6'
    brlo check_ones_hour  
    ldi r24, '0'            ; Reset tens of minutes
    inc r23                ; Increment ones of hours

check_ones_hour:
    cpi r23, ':'      ; check if ones of hours exceeds '9'
    brlo check_tens_hour  
    ldi r23, '0'          ; Reset ones of hours
    inc r22                ; Increment tens of hours

check_tens_hour:
    cpi r22, '2'            ; Check if tens of hours = '2'
    brne delay_and_continue 
    cpi r23, '4'          ; Check if ones of hours = '4' (24-hour clock)
    brne delay_and_continue 

    ; Reset clock to 00:00
    ldi r22, '0'          
    ldi r23, '0'          
    ldi r24, '0'          
    ldi r25, '0'          

delay_and_continue:
    sts 0x700, r22   ;storing curr in 0x700-703
	sts 0x701, r23
	sts 0x702, r24
	sts 0x703, r25

    call displayer    ;displays curr_time, next_time, time_left	
	call equal_checker    ;for alerting
 	call time_left_decrementer    
    call delay_1s         
    rjmp curr_incrementer 

rjmp main

;-
;functions start from here

displayer:
    call delay
    ldi r16, 0x01
    call cmndwrt
    call delay
    ldi r16, 0x80
    call cmndwrt
    ldi r16, 'c'      ;current_time 
    call datawrt
    ldi r16, ':'
    call datawrt      
    lds r16, 0x700         ;tens hour
    call datawrt
    lds r16, 0x701         ; ones hour
    call datawrt
	ldi r16 ,':'
	call datawrt
    lds r16, 0x702         ;tens min
    call datawrt
    lds r16, 0x703        ; ones min
    call datawrt
	ldi r16, 0xC0
	call cmndwrt
	ldi r16, 'n'         	;next prayer
	call datawrt
	ldi r16, ':'
	call datawrt
	lds r16, 0x404     ;n is at 0x404 to 0x407
	call datawrt
	lds r16, 0x405
	call datawrt
	ldi r16, ':'
	call datawrt
    lds r16, 0x406
	call datawrt
	lds r16, 0x407
	call datawrt
	ldi r16, ' '      ;time left
	call datawrt
	ldi r16, ' '
	call datawrt
	ldi r16, 'L'
	call datawrt
	ldi r16, ':'
	call datawrt

	lds r16, 0x800  ;time_left updating real time
	call datawrt
	lds r16, 0x801
	call datawrt
	ldi r16, ':'
	call datawrt
	lds r16, 0x802
	call datawrt
	lds r16, 0x803
	call datawrt

    ret



	;-----------------------------------------------------------------------------------------



comparer:
ldi ZL, 0x00   ;contains current time
ldi ZH, 0x4

    ; Load current time into temporary registers
    ld r24, Z+    ; tens hour of current time
    mov r16, r24
    call ascii_todec   ; Convert ASCII to decimal
    mov r20, r16       ; r20 holds tens_hour (decimal)
	ldi r16, 10
	mul r20, r16
	mov r20, r0
	clr r0

    ld r25, Z+    ; ones hour
    mov r16, r25
    call ascii_todec
    add r20, r16       ; r20 now holds total hours (decimal)

    ld r26, Z+    ; tens minute
    mov r16, r26
    call ascii_todec
    mov r21, r16       ; r21 holds tens_minute (decimal)
	ldi r16, 10
	mul r21, r16
	mov r21, r0

    ld r27, Z+    ; ones minute
    mov r16, r27
    call ascii_todec
    add r21, r16       ; r21 now holds total minutes (decimal)

    ldi YL, 0x00    ;loading prayer time
    ldi YH, 0x2

compare_loop:
    ld r22, Y+        ; tens hour of prayer time
    mov r16, r22
    call ascii_todec
    mov r22, r16       ; r22 holds tens_hour (decimal)
	clr r0
	ldi r16, 10
	mul r22, r16
	mov r22, r0
	clr r0

    ld r23, Y+        ; ones hour
    mov r16, r23
    call ascii_todec
    add r22, r16       ; r22 now holds total prayer hours (decimal)

    ld r24, Y+        ; tens minute
    mov r16, r24
    call ascii_todec
    mov r23, r16       ; r23 holds tens_minute (decimal)
	ldi r16, 10
	mul r23, r16
	mov r23, r0
	clr r0

    ld r25, Y+        ; ones minute
    mov r16, r25
    call ascii_todec
    add r23, r16       ; r23 now holds total prayer minutes (decimal)

    ; Compare hours first
    cp r20, r22       ; compare current hours with prayer hours 
    brlo check_next_prayer ; current time < prayer time, break the loop
    breq compare_minutes  ; if hours are equal, compare minutes
    rjmp compare_loop      ; otherwise, continue to the next prayer time

compare_minutes:
    cp r21, r23       ; compare current_minutes with prayer_minutes
    brlo check_next_prayer ; if current minutes < prayer minutes, break the loop
	rjmp compare_loop      ; if both hours and minutes are greater, move to the next prayer
                   
				
check_next_prayer:
    ; Store nearest prayer time in SRAM
    mov r16, r22       ; Prayer tens_hour
    call seperator     ; Convert to ASCII
    sts 0x404, r20     ; Store ASCII tens_hour
    sts 0x405, r21     ; Store ASCII ones_hour

    mov r16, r23       ; Prayer tens_minute
    call seperator     ; Convert to ascii
    sts 0x406, r20     ; Store ascii tens_minute
    sts 0x407, r21     ; Store ascii ones_minute 
	 ret

	combine_values:
    ; Multiply R16 (tens place) by 10
    LDI R18, 10           ; Load 10 into R18
    MUL R20, R18         ; tens_hours
    MOV R20, R0           
    ADD R20, R21          ; add ones_hours   R20 = hours
	mov r16, r20

    CLR R1                ; Clearing registers after multiplication
    CLR R0

	MUL r22, r18         ;tens_mins
	MOV R22, R0
	ADD r22, r23          ;add ones_mins   r22 = mins
	mov r21, r22
	mov r18, r21
	CLR r1
	CLR R0
     RET 

; Input: R16 (decimal number, 0~99)
; Output: R20 (tens digit in ascii), R21 (units digit in ascii)
seperator:
    LDI R17, 10          ; Load divisor (10) into R22
    CLR R20              ; Clear R20 (Tens digit counter)
    
division_loop:
    CP R16, R17          ; Compare R16 with 10
    BRLO calculate_units ; If R16 < 10, move to calculate units
    SUB R16, R17        ; Subtract 10 from R16
    INC R20              ; Increment tens counter
    RJMP division_loop   ; Repeat the loop

calculate_units:
    MOV R21, R16         ; R16 now holds the remainder (units digit)
    
    ; Convert tens digit to ASCII
    LDI R18, '0'         ; ASCII offset for '0'
    ADD R20, R18         ; tens digits + ascii

    ADD R21, R18         ; ones digits + ascii
    RET

    ascii_todec:
    SUBI R16, '0'          ; Subtract ASCII code for '0' 
    RET   

	dec_toascii:
	ldi r27, '0'
	add r16, r27
	ret


	;---------------------------------------------------------------------------

	equal_checker:

	lds r22, 0x700   ;curr time
	lds r23, 0x701
	lds r24, 0x702
	lds r25, 0x703

	lds r16, 0x404  
	cp r22, r16     ;compare current time with the "next prayer time"
	brne temp_returner
	lds r16, 0x405
	cp r23, r16
	brne temp_returner
	lds r16, 0x406
	cp r24, r16
	brne temp_returner
	lds r16, 0x407
	cp r25, r16
	brne temp_returner

	ldi r16, 0x01
	call cmndwrt
	call DELAY_2ms
	ldi r16, 0x80
	call cmndwrt
	ldi r16, 'A'        ;if found equal then alert
	call datawrt
	ldi r16, 'L'
	call datawrt
	ldi r16, 'E'
	call datawrt
	ldi r16, 'R'
	call datawrt
	ldi r16, 'T'
	call datawrt
	call delay_1s
	call delay_1s

	;inc YL           ;the next prayer time should load data from 0x200s(next prayer) 
	ld r16, Y+ 
	sts 0x404, r16
	ld r16, Y+
	sts 0x405, r16
	ld r16, Y+
	sts 0x406, r16
	ld r16, Y+
	sts 0x407, r16
	call time_left

	temp_returner:
	RET
   
   ;________________________________________________________________________________


time_left:
   
   ldi ZL, 0x00   ;contains current time
   ldi ZH, 0x7

   ; Load current time into temporary registers
   ld r16, Z+    ; tens hour of current time
   call ascii_todec   ; Convert ASCII to decimal
   mov r20, r16       ; r20 holds tens_hour (decimal)
   ldi r16, 10
   mul r20, r16
   mov r20, r0
   clr r0

    ld r16, Z+    ; ones hour
    call ascii_todec
    add r20, r16       ; r20 now holds total hours (decimal)

    ld r16, Z+    ; tens minute
    call ascii_todec
    mov r21, r16       ; r21 holds tens_minute (decimal)
	ldi r16, 10
	mul r21, r16
	mov r21, r0

    ld r16, Z+    ; ones minute
    call ascii_todec
    add r21, r16       ; r21 now holds total minutes (decimal)
	;r20 and r21 have the current time

	;retrieving "next time" 
	lds r16, 0x404     ;tens_hours of next
	call ascii_todec
	mov r22, r16
	ldi r16, 10
    mul r22, r16
    mov r22, r0      ;r22 has tens_hours*10
    clr r0

	lds r16, 0x405        ; ones_hours
    call ascii_todec
    add r22, r16       ; r22 now holds total prayer hours (decimal)

    lds r16, 0x406        ; tens minute
    call ascii_todec
    mov r23, r16       ; r23 holds tens_minute (decimal)
	ldi r16, 10
	mul r23, r16
	mov r23, r0
	clr r0

    lds r16, 0x407        ; ones minute
    call ascii_todec
    add r23, r16            ;r23 holds total minutes
	;r22 and r23 have the next time

	sub r22, r20            ;r22 has hours difference
	cp r23, r21             ;r23 has minutes difference
	brlo neg_minutes         ;if r23 is negative
	sub r23, r21
	rjmp feed_difftime

	neg_minutes:
	sub r21, r23
	ldi r16, 60
	sub r16, r21
	mov r23, r16   ;minutes
	subi r22, 1


	feed_difftime:
	mov r16, r22
	call seperator
	sts 0x800, r20       ;storing tens_hours
	sts 0x801, r21       ;storing ones_hours
	
	mov r16, r23
	call seperator
	sts 0x802, r20      ;storing tens_mins
	sts 0x803, r21       ;storing ones_mins

	RET


	;_-----------------------------------------------------------
 

	time_left_decrementer:
	clr r30
	clr r31
	lds r22, 0x800   ;loads diff_time
	lds r23, 0x801
	lds r24, 0x802
	lds r25, 0x803

    ; Decrement the ones of minutes
    subi r25, 1        ; decrement the ones of minutes
    cpi r25, '0'    ; check if it is less than '0'
    brge check_tens_minutes
    ldi r25, '9'       ; reset to '9' if <0
    subi r24, 1        ; decrement the tens of minutes

check_tens_minutes:
    cpi r24, '0'    ; check if underflow (less than '0')
    brge check_ones_hours
    ldi r24, '5'       ; reset to '5' if underflow
    subi r23, 1        ; decrement the ones of hours

check_ones_hours:
    cpi r23, '0'    ; Check if underflow (less than '0')
    brge check_tens_hours
    ldi r23, '9'       ; Reset to '9' if underflow
    subi r22, 1        ; Decrement the tens of hours

check_tens_hours:
    cpi r22, '0'    ; Check if underflow (less than '0')
    brge store_time_left
    ldi r22, '2'       ; Reset to '2' for 24-hour format
    ldi r23, '3'       ; Reset to '3' (last valid hour in 24-hour format)
    ldi r24, '5'       ; Reset to '5' (max tens of minutes)
    ldi r25, '9'       ; Reset to '9' (max ones of minutes)

store_time_left:
    ; Store the decremented time back in SRAM
    sts 0x800, r22    ; Store tens of hours
    sts 0x801, r23    ; Store ones of hours
    sts 0x802, r24    ; Store tens of minutes
    sts 0x803, r25    ; Store ones of minutes

	lds r22, 0x700
	lds r23, 0x701
	lds r24, 0x702
	lds r25, 0x703

    ret



;___________________



KPD_ISR: 
LDI  R21,  0b01111111
OUT  KEY_PORT,R21
NOP
IN  R21,KEY_PIN

ANDI  R21,0x0F
 CPI  R21,0x0F
 BRNE COL1

LDI  R21,  0b10111111
 OUT  KEY_PORT,  R21
  NOP
IN  R21,  KEY_PIN
 ANDI  R21,0x0F
  CPI  R21,0x0F
   BRNE COL2

LDI  R21,  0b11011111
OUT  KEY_PORT,  R21
NOP
IN  R21,  KEY_PIN
 ANDI  R21,0x0F
  CPI  R21,0x0F
   BRNE COL3

 rjmp KPD_ISR
COL1:
LDI  R30,  LOW(KCODE0<<1)
LDI  R31,  HIGH(KCODE0<<1)
RJMP  Find
 COL2:
LDI  R30,  LOW(KCODE1<<1)
 LDI  R31,  HIGH(KCODE1<<1)
RJMP  Find
 COL3:
LDI  R30,  LOW(KCODE2<<1)
 LDI  R31,  HIGH(KCODE2<<1)
RJMP  Find

Find:
LSR R21
BRCC  Match
 LPM  R20,  Z+
RJMP  Find MATCH:
LPM  R20,  Z

ldi  r17,0x0f
 in  r16,pinc
 andi  r16,0x0f
 cp  r16,r17
  breq  kpd_isr

OUT  PORTA,  R20
call BDELAY 
RET


.ORG  0x3000
KCODE0: .DB  '7',  '4',  '1',  'c'  //col1
KCODE1: .DB  '8',  '5',  '2',  '0'
KCODE2: .DB  '9',  '6',  '3',  '='


CMNDWRT:
OUT  LCD_DPRT,  R16
CBI  LCD_CPRT,LCD_RS
CBI  LCD_CPRT,LCD_RW
SBI  LCD_CPRT,LCD_EN
CALL SDELAY
CBI  LCD_CPRT,LCD_EN
CALL DELAY_100us
RET

DATAWRT:
OUT  LCD_DPRT,R16
SBI  LCD_CPRT,LCD_RS
CBI  LCD_CPRT,LCD_RW
SBI  LCD_CPRT,LCD_EN
CALL SDELAY
CBI  LCD_CPRT,LCD_EN
CALL DELAY_100us
RET


DELAY:
PUSH R17
 LDI R17,20
 LDR1:
CALL DELAY_2ms
 DEC R17
PUSH R17
 LDI R17,20
 LDR5:
CALL DELAY_2ms
 DEC R17
BRNE LDR5
 POP R17
 BRNE LDR1
  POP R17
RET

DELAY_2ms:
PUSH R17
LDI R17,20
 LDR0:
CALL DELAY_100us
 DEC R17
BRNE LDR0
 POP R17
 RET

DELAY_100us:
PUSH R17
  LDI R17,60
   DR0:
     CALL SDELAY
DEC R17
 BRNE DR0
  POP R17
   RET

   BDELAY:
ldi  r19,  8
la:call  delay
 dec r19
 brne la
ret

SDELAY:
NOP
NOP
RET

DELAY_1s:
ldi r17,high(31250-1) 
out OCR1AH,r20
ldi r17, low(31250-1)
out OCR1AL,R17
ldi r17, 0 
out TCNT1H,r17
out TCNT1L,r17
ldi r17,0x0
out TCCR1A,r17
ldi r17,0x4 
out TCCR1B,r17
AGAIN:
IN R17,TIFR
SBRS R17,OCF1A
RJMP AGAIN
LDI R17,1<<OCF1A
OUT TIFR,R17 
LDI R18, 0
OUT TCCR1B,R18 
OUT TCCR1A,R18
RET



.org 0x1000

;Monday (25-3-2024)   day 1 week 12  2+2+1+7 = 12
mydata: 
 .db '0','4','1','1' ;Fajr (04:11)
 .db '1','1','4','4' ;Dhur (11:44)
 .db '1','5','1','4' ;Asr (15:14)
 .db '1','7','5','7' ;Maghrib (17:57)
 .db '1','9','1','7' ;Isha (19:17)

;Tuesday (26-3-2024)   day 2
 .db '0','4','1','0' ;Fajr (04:10)
 .db '1','1','4','3' ;Dhur (11:43)
 .db '1','5','1','4' ;Asr (15:14)
 .db '1','7','5','8' ;Maghrib (17:58)
 .db '1','9','1','8' ;Isha (19:18)

;Wednesday (27-3-2024)  day 3 
 .db '0','4','0','8' ;Fajr (04:08)
 .db '1','1','4','3' ;Dhur (11:43)
 .db '1','5','1','4' ;Asr (15:14)
 .db '1','7','5','9' ;Maghrib (17:59)
 .db '1','9','1','9' ;Isha (19:19)

;Thursday (28-3-2024)   day 4
 .db '0','4','0','7' ;Fajr (04:07)
 .db '1','1','4','3' ;Dhur (11:43)
 .db '1','5','1','4' ;Asr (15:14)
 .db '1','7','5','9' ;Maghrib (17:59)
 .db '1','9','2','0' ;Isha (19:20)

;Friday (29-3-2024)    day 5 
 .db '0','4','0','5' ;Fajr (04:05)
 .db '1','1','4','2' ;Dhur (11:42)
 .db '1','5','1','4' ;Asr (15:14)
 .db '1','8','0','0' ;Maghrib (18:00)
 .db '1','9','2','1' ;Isha (19:21)

;Saturday (30-3-2024) day 6
 .db '0','4','0','4' ;Fajr (04:04)
 .db '1','1','4','2' ;Dhur (11:42)
 .db '1','5','1','5' ;Asr (15:15)
 .db '1','8','0','1' ;Maghrib (18:01)
 .db '1','9','2','1' ;Isha (19:21)

;Sunday (31-3-2024)   day 7
 .db '0','4','0','2' ;Fajr (04:02)
 .db '1','1','4','1' ;Dhur (11:41)
 .db '1','5','1','5' ;Asr (15:15)
 .db '1','8','0','2' ;Maghrib (18:02)
 .db '1','9','2','2' ;Isha (19:22)
