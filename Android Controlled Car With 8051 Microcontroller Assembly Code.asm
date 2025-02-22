ORG 0000H

MAIN:
    MOV TMOD, #20H        ; Timer 1 mode 2 for baud rate generation
    MOV SCON, #50H        ; Serial mode 1, 8-bit data, REN enabled
    MOV TH1, #0FDH        ; Baud rate 9600
    SETB TR1              ; Start Timer 1

MAIN_LOOP:
    ACALL RXDATA          ; Receive a command
    MOV A, SBUF           ; Move received data into A

    ; Check commands
    CJNE A, #'f', CHECK_BWD
    ACALL MOVE_FORWARD
    SJMP MAIN_LOOP

CHECK_BWD:
    CJNE A, #'b', CHECK_RIGHT
    ACALL MOVE_BACKWARD
    SJMP MAIN_LOOP

CHECK_RIGHT:
    CJNE A, #'r', CHECK_LEFT
    ACALL MOVE_RIGHT
    SJMP MAIN_LOOP

CHECK_LEFT:
    CJNE A, #'l', CHECK_STOP
    ACALL MOVE_LEFT
    SJMP MAIN_LOOP

CHECK_STOP:
    CJNE A, #'s', UNRECOGNIZED
    ACALL STOP_MOTORS
    SJMP MAIN_LOOP

UNRECOGNIZED:
    SJMP MAIN_LOOP        ; Go back to main loop
	
; Motor Movement Subroutines
MOVE_FORWARD:
    SETB P2.0             ; Left motor forward
    CLR  P2.1             ; Left motor backward off
    SETB P2.2             ; Right motor forward
    CLR  P2.3             ; Right motor backward off
    RET

MOVE_BACKWARD:
    CLR  P2.0             ; Left motor forward off
    SETB P2.1             ; Left motor backward
    CLR  P2.2             ; Right motor forward off
    SETB P2.3             ; Right motor backward
    RET

MOVE_RIGHT:
    SETB P2.0             ; Left motor forward
    CLR  P2.1             ; Left motor backward
    CLR  P2.2             ; Right motor forward off
    SETB P2.3             ; Right motor backward
    RET

MOVE_LEFT:
    CLR  P2.0             ; Left motor forward off
    SETB P2.1             ; Left motor backward
    SETB P2.2             ; Right motor forward
    CLR  P2.3             ; Right motor backward off
    RET

STOP_MOTORS:
    CLR P2.0              ; Stop Left motor forward
    CLR P2.1              ; Stop Left motor backward
    CLR P2.2              ; Stop Right motor forward
    CLR P2.3              ; Stop Right motor backward
    RET

; Receive Data Subroutine
RXDATA:
    JNB RI, RXDATA        ; Wait until data is received
    CLR RI                ; Clear RI flag
    RET

END