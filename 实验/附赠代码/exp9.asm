IOY0			EQU 0600H
MY8254_COUNT0	EQU IOY0+00H*2   		;8254计数器0端口地址
MY8254_COUNT1	EQU IOY0+01H*2   		;8254计数器1端口地址
MY8254_COUNT2	EQU IOY0+02H*2   		;8254计数器2端口地址
MY8254_MODE		EQU IOY0+03H*2   		;8254控制寄存器端口地址

STACK1	SEGMENT STACK
		DW 256 DUP(?)
STACK1	ENDS

DATA	SEGMENT 
FREQ_LIST		DW  262,294,330,262,262,294,330,262,330       		;频率表
			DW  350,393,330,350,393,393,441,393,350
			DW  330,262,393,441,393,350,330,262,294,196
			DW  262,294,196,262,262,294,330,262,262,294
			DW  330,262,330,350,393,330,350,393,393,441
			DW  393,350,330,262,393,441,393,350,330,262,0
			
TIME_LIST		DB    4,   4,  4,   4,  4,  4,   4,  4,  4       	;时间表
			DB    4,   8,  4,   4, 8,  2,  2,   2,  2
			DB    4,   4,  2,   2,  2,  2,  4,   4,  4,  4
			DB    8,   4,  4,   8,  4,  4,  4,   4,  4,  4
			DB    4,   4,  4,   4, 8,  4,  4,   8,  2,  2
			DB    2,   2,  4,   4,  2,  2,  2,   2,  4, 4
DATA		ENDS

CODE	SEGMENT
		ASSUME  CS:CODE, DS:DATA

START:		MOV AX, DATA
		MOV DS, AX

		MOV DX, MY8254_MODE			;初始化8254工作方式
		MOV AL, 36H					;定时器0、方式3
		OUT DX, AL

BEGIN:		MOV SI,OFFSET FREQ_LIST		;装入频率表起始地址
		MOV DI,OFFSET TIME_LIST		;装入时间表起始地址

PLAY:		MOV DX,0FH					;输入时钟为1MHz，1M = 0F4240H  
		MOV AX,4240H 

		DIV WORD PTR [SI]			;取出频率值计算计数初值，0F4240H / 输出频率

		MOV DX,MY8254_COUNT0
		OUT DX,AL					;装入计数初值

		MOV AL,AH
		OUT DX,AL

		MOV DL,[DI]					;取出演奏相对时间，调用延时子程序
 
		CALL DALLY

		ADD SI,2
		INC DI

		CMP WORD PTR [SI],0			;判断是否到曲末？
		JE  BEGIN
		JMP  PLAY

DALLY	PROC						;延时子程序
D0:		MOV CX,0010H
D1:		MOV AX,0F00H
D2:		DEC AX
		JNZ D2
		LOOP D1
		DEC DL
		JNZ D0
		RET
DALLY	ENDP

CODE	ENDS
		END START

