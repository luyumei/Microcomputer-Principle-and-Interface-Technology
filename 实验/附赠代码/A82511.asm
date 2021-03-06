;==========================================================
; 文件名: A82511.ASM
; 功能描述: 研究了解串行传输的数据格式
;==========================================================

IOY0         	EQU  0600H        ;IOY0起始地址
IOY1         	EQU  0640H        ;IOY1起始地址
M8251_DATA	EQU IOY0+00H*2
M8251_CON	EQU IOY0+01H*2
M8254_2		EQU IOY1+02H*2
M8254_CON	EQU IOY1+03H*2

SSTACK	SEGMENT STACK
		DW 64 DUP(?)
SSTACK	ENDS
CODE	SEGMENT
		ASSUME CS:CODE
START:	CALL INIT
A1:		CALL SEND
		MOV CX, 0001H
A2:		MOV AX, 0F00H
A3:		DEC AX
		JNZ A3
		LOOP A2
		JMP A1		
INIT:	MOV AL, 0B6H			; 8254, 设置通讯时钟
		MOV DX, M8254_CON
		OUT DX, AL
		MOV AL, 1BH
		MOV DX, M8254_2
		OUT DX, AL
		MOV AL, 3AH
		OUT DX, AL
		CALL RESET				; 对8251进行初始化
		CALL DALLY
		MOV AL, 7EH
		MOV DX, M8251_CON		; 写8251方式字
		OUT DX, AL
		CALL DALLY
		MOV AL, 34H
		OUT DX, AL				; 写8251控制字
		CALL DALLY
		RET
RESET:	MOV AL, 00H				; 初始化8251子程序
		MOV DX, M8251_CON		; 控制寄存器
		OUT DX, AL
		CALL DALLY
		OUT DX, AL
		CALL DALLY
		OUT DX, AL
		CALL DALLY
		MOV AL, 40H
		OUT DX, AL
		RET
DALLY:	PUSH CX
		MOV CX, 5000H
A4:		PUSH AX
		POP AX
		LOOP A4
		POP CX
		RET
SEND:	PUSH AX
		PUSH DX
		MOV AL, 31H
		MOV DX, M8251_CON
		OUT DX, AL
		MOV AL, 55H
		MOV DX, M8251_DATA			; 发送数据55H
		OUT DX, AL
		POP DX
		POP AX
		RET
CODE	ENDS
		END START
