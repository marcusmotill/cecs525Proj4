*-----------------------------------------------------------
************ Assumptions being made:
*               number has at least one digit to the left and right of decimal
*               number contains a decimal
*               number is greater than 1 (extra work required to have negative exp)
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
    
CR       EQU      $0D               Carriage_return 

    
START:                  ; first instruction of program

AtoBCD	EQU	*
        MOVE.B  #'7', $4100
        MOVE.B  #'.', $4101
        MOVE.B  #'1', $4102
        MOVE.B  #'2', $4103
        MOVE.B  #'5', $4104
        MOVE.B  CR,   $4105
		LEA.L	$4000,A0
		CLR.L	(A0)+		  Clear $4000 to $400B
		CLR.L	(A0)+
		CLR.L	(A0)
		CLR.L	D0              incoming ASCII (working register)
		CLR.L	D1              stores threshold for finding right side 1's
		CLR.L   D2              left of decimal (base 10) then entire mantissa
		CLR.L   D3              right of decimal (base 10)
		CLR.L   D4              counter (for size of decimal, looping)
		CLR.L   D5              completed FP number
		CLR.L   D6              keep track of number of shifts to left register
		CLR.L   D7              holds final exponent number
		LEA.L   $4100,A0     A0 points to line buffer  
		MOVE.B  (A0)+,D0          Read ASCII character from line buffer
		CMP.B	#'-',D0	  	  Is the first character in the FP string a minus?
		BNE	    DECI		  if not a minus then skip adding in minus bit
		MOVE.l	#$80000000,D5    make msb high in D5.L indicating negative 
DECI    CMP.B   #'.',D0         Is the first character a decimal?
        BNE     FIRST            If it is not than convert left side to decimal
        BRA     RIGHT            Else jump to right side conversion process
        
LOOP1   MOVE.B  (A0)+,D0        When looping receive next char        
        CMP.B   #'.',D0         Is the next char a decimal?
        BEQ     EXP            If so then left side is done go to right
        MULS    #10,D2          else multiply current left by 10 (to make room)
FIRST   SUB.L   #48,D0          ascii to integer
        ADD.L   D0,D2           add next decimal digit to left reg.
        BRA     LOOP1           keep looping until decimal is reached
        
EXP     CLR.L   D0              clear working register
	    MOVE.L  D2,D0           move into working register
LOOP3   ADD.L   #1,D4           add 1 to counter register
        LSL.L   #1,D0           rotate bits left to find msb that is set
        BCS     SKIP1           MSB found need to skip
        BRA     LOOP3           keep rotating until found
SKIP1   MOVE.L  #32,D7
        SUB     D4,D7           find 32-count = location of msb set.
        CLR.L   D0
        MOVE.B  #1,D1           move initial bit into D1
        LSL.L   D7,D1           rotate bit left D7 times
        SUB     D1,D2           remove msb set
        CLR.L   D4
        ADD     #127,D7
        CLR.L   D1
        CLR.L   D0
        
RIGHT   MOVE.B  (A0)+,D0        When looping receive next char        
        CMP.B   CR,D0          Is the next char a carriage return?
        BEQ     THRESH          If so then right side is done go to finding threshold
        SUB     #48,D0          Convert to integer
        MULS    #10,D3          else multiply current right by 10 (to make room)
        ADD.L   D0,D3           add next decimal digit to right reg.
        ADD.L   #1,D4           Keep track of number of digits to the right
        BRA     RIGHT           keep looping until Carriage Return is reached

THRESH  MOVE.L  #1,D1           To start move 1 into D1
LOOP4   MULS    #10,D1          Increase threshold by 10 times
        SUB     #1,D4           decrease counter
        CMP.B   #0,D4           check if counter has reached 0
        BEQ     CONV            done multiplying to acheive threshold value
        BRA     LOOP4           Keep going until threshold found

CONV    LSL.L   #1,D3           Multiply right number by 2
        CMP.L   D3,D1           check if threshold is less than D3
        BLS     SKIP2           skip adding a shift if it is and go to inserting 1
        ADD.B   #1,D6           increment number of shifts before 1 is added
        BRA     CONV            continue converting

SKIP2   ADD.B   #1,D6           make room for the 1 after 0's
        LSL.L   D6,D2           shift left of the decimal place numbers correct # of times
        OR.L    #$1,D2          make lsb 1
        CLR.L   D6              reset shift counter
        SUB.L   D1,D3           subtract off threshold amount
        CMP.L   #0,D3           if 0 is reached than completed combining left and right side
        BEQ     COMB            
        BRA     CONV            or continue converting
        
COMB  	LSL.L   #8,D7
        LSL.L   #8,D7
        LSL.L   #7,D7
        OR.L    D7,D5
        MOVE.L  #0,D3
SHIFT   LSL.L   #1,D2           rotate bits left to find msb that is set
        BCS     MANT           MSB found need to skip
        ADD.L   #1,D3
        BRA     SHIFT
MANT 	LSR.L   #8,D2
        LSR.L   #2,D2
        SUB.L   #5,D3
        MOVE.L  #1,D4
        LSL.L   D3,D4
        OR.L    D4,D2
        OR.L    D2,D5

EXIT    SIMHALT             ; halt simulator

CR       EQU      $0D               Carriage_return 

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
