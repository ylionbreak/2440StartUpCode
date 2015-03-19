;*********************************
;*********************************
;**С���¤μ���������+��һ����**
;**          2015/1/16          **
;**        ƽ̨: mini2440       **
;**       Ϊ�˸����õ�����      **
;**           bitmen            **
;**      ���Ź���ʼ��	  !!	**
;**      ʱ�ӳ�ʼ��		  !!	**
;**      �洢��������ʼ�� !!	**
;**       GPIO�ڳ�ʼ��	  XX	**
;**			  �ж�����			
;**     �����ջ��ʼ������
;**    ��ת��C�ļ���main����ִ��
;**û���ж� ��ջ���� SDRAM�����**
;*********************************
;*********************************

;*************************** define ***************************

;ϵͳʱ�Ӻ궨��
LOCKTIME_Val    EQU     0x0FFF0FFF
MPLLCON_Val     EQU     0x00043011
UPLLCON_Val     EQU     0x00038021
CLKCON_Val      EQU     0x00006010
CLKSLOW_Val     EQU     0x00000004
CLKDIVN_Val     EQU     0x0000000F
CLKCON          EQU     0x4C00000C
;PLL��ַ
CLOCK_BASE      EQU     0x4C000000     
LOCKTIME_OFS    EQU     0x00            
MPLLCON_OFS     EQU     0x04           
UPLLCON_OFS     EQU     0x08           
CLKCON_OFS      EQU     0x0C         
CLKSLOW_OFS     EQU     0x10         
CLKDIVN_OFS     EQU     0x14   


;�ڴ����궨��
;�ڴ������ֵ
MC_SETUP        EQU     1
BWSCON_Val      EQU     0x22000000;bank7 32λ  bank6 32λ  bank6,7 ������ͬ��С	 bank1-5����8λ
BANKCON0_Val    EQU     0x00000700;��������		14��ʱ��
BANKCON1_Val    EQU     0x00000700
BANKCON2_Val    EQU     0x00000700
BANKCON3_Val    EQU     0x00000700
BANKCON4_Val    EQU     0x00000700
BANKCON5_Val    EQU     0x00000700
BANKCON6_Val    EQU     0x00018005
BANKCON7_Val    EQU     0x00018005
REFRESH_Val     EQU     0x008404F3;ˢ��ʹ�� 6��ʱ�� ˢ�¼���ֵ
BANKSIZE_Val    EQU     0x00000002
MRSRB6_Val      EQU     0x00000020;����ʱ��
MRSRB7_Val      EQU     0x00000020;����ʱ��
;�ڴ�����ַ
MC_BASE         EQU     0x48000000      ; Memory Controller Base Address
BWSCON_OFS      EQU     0x00            ; Bus Width and Wait Status Ctrl Offset
BANKCON0_OFS    EQU     0x04            ; Bank 0 Control Register        Offset
BANKCON1_OFS    EQU     0x08            ; Bank 1 Control Register        Offset
BANKCON2_OFS    EQU     0x0C            ; Bank 2 Control Register        Offset
BANKCON3_OFS    EQU     0x10            ; Bank 3 Control Register        Offset
BANKCON4_OFS    EQU     0x14            ; Bank 4 Control Register        Offset
BANKCON5_OFS    EQU     0x18            ; Bank 5 Control Register        Offset
BANKCON6_OFS    EQU     0x1C            ; Bank 6 Control Register        Offset
BANKCON7_OFS    EQU     0x20            ; Bank 7 Control Register        Offset
REFRESH_OFS     EQU     0x24            ; SDRAM Refresh Control Register Offset
BANKSIZE_OFS    EQU     0x28            ; Flexible Bank Size Register    Offset
MRSRB6_OFS      EQU     0x2C            ; Bank 6 Mode Register           Offset
MRSRB7_OFS      EQU     0x30            ; Bank 7 Mode Register           Offset


;��ջģʽ����
Mode_USR        EQU     0x10   ;�û�ģʽ
Mode_FIQ        EQU     0x11     ;���ж�ģʽ
Mode_IRQ        EQU     0x12    ;�ж�ģʽ
Mode_SVC        EQU     0x13   ;����ģʽ
Mode_ABT        EQU     0x17   ;���ݷ�����ֹģʽ
Mode_UND        EQU     0x1B  ;δ����ָ����ֹģʽ
Mode_SYS        EQU     0x1F   ;ϵͳģʽ
I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled
;����ջ�ռ�
UND_Stack_Size  EQU     0x00000000  ;δ����ģʽ
SVC_Stack_Size  EQU     0x00000008  ;����ģʽջ����
ABT_Stack_Size  EQU     0x00000000  ;���ݷ�����ֹģʽջ����
FIQ_Stack_Size  EQU     0x00000000   ;���ж�ģʽջ����
IRQ_Stack_Size  EQU     0x00000080  ;�ж�ģʽջ����
USR_Stack_Size  EQU     0x00000400 ;�û�ģʽջ����
ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + FIQ_Stack_Size + IRQ_Stack_Size)      ;���еĶ�ջ��С������ӣ��õ��ܶ�ջ��С
     
	 AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size	;SPACEָ�����ڷ���һ���ڴ浥Ԫ������ֱ�Ϊ������ջ�����Ӧ
__initial_sp    SPACE   ISR_Stack_Size	;���ȵ��ڴ�ռ�
Stack_Top

Heap_Size       EQU     0x00000000

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit

;*************************** code ***************************
				   PRESERVE8
				   AREA    RESET, CODE, READONLY
                   ARM
				   ENTRY



;�ر�watching dog
 ldr r0, =0x53000000                    
 mov r1, #0                                      
 str r1, [r0]



;�ر�ȫ���ж�
;��Ҫ�ж�
 ldr r0, =0x4A000008  
 ldr r1, =0xffffffff
 str r1, [r0]
;�μ��ж�		
 ldr r0, =0x4A00001C
 ldr r1, =0x7fff
 str r1, [r0]



;�������໷PPL
;����ʱ��
 ldr r0, =CLOCK_BASE
 ldr r1, =LOCKTIME_Val
 str r1, [r0, #LOCKTIME_OFS]
;��Ƶ����
 mov r1, #CLKDIVN_Val  						 
 str r1, [r0, #CLKDIVN_OFS]
;��Ƶ����
 ldr r1, =MPLLCON_Val
 str r1, [r0, #MPLLCON_OFS]
 ldr r1, =UPLLCON_Val
 str r1, [r0, #UPLLCON_OFS]
;����ʱ��
 mov r1, #CLKSLOW_Val
 str r1, [r0, #CLKSLOW_OFS]
;ʱ�ӿ��ƼĴ���
 ldr r1, =CLKCON_Val
 str r1, [r0, #CLKCON_OFS]



;�������
;���ػ���ַ
 ldr     r0,      =MC_BASE
;bank1-7дλ���ҽ�ֹ�ȴ�
 ldr     r1,      =BWSCON_Val
 str     r1, [r0, #BWSCON_OFS]
;����bank0-7�Ĵ���
 ldr     r1,      =BANKCON0_Val
 str     r1, [r0, #BANKCON0_OFS]
 ldr     r1,      =BANKCON1_Val
 str     r1, [r0, #BANKCON1_OFS]
 ldr     r1,      =BANKCON2_Val
 str     r1, [r0, #BANKCON2_OFS]
 ldr     r1,      =BANKCON3_Val
 str     r1, [r0, #BANKCON3_OFS]
 ldr     r1,      =BANKCON4_Val
 str     r1, [r0, #BANKCON4_OFS]
 ldr     r1,      =BANKCON5_Val
 str     r1, [r0, #BANKCON5_OFS]
 ldr     r1,      =BANKCON6_Val
 str     r1, [r0, #BANKCON6_OFS]
 ldr     r1,      =BANKCON7_Val
 str     r1, [r0, #BANKCON7_OFS]
;���������ļĴ���
 ldr     r1,      =REFRESH_Val
 str     r1, [r0, #REFRESH_OFS]
 mov     r1,      #BANKSIZE_Val
 str     r1, [r0, #BANKSIZE_OFS]
 mov     r1,      #MRSRB6_Val
 str     r1, [r0, #MRSRB6_OFS]
 mov     r1,      #MRSRB7_Val
 str     r1, [r0, #MRSRB7_OFS]



;�����
;����һ��GPIO								 
 ldr     r0, =0x56000010
 ldr     r1, =0x155555
 str     r1, [r0]
;������������
 ldr     r0, =0x56000014
 ldr     r1, =0x80
 str     r1, [r0]



;��ջ
                LDR     R0, =Stack_Top        ;����ջ��ָ���ַ����ǰ���Ѿ�����

;����δ����ģʽ�����趨��ջָ�룬��(Mode_UND | I_Bit | F_Bit)��ֵ��CPSR_c��CPSR_c��CPSR[7:0]
                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
                MOV     SP, R0                     ;ջ��ָ�븳ֵ��SPָ��
                SUB     R0, R0, #UND_Stack_Size     ;ջ��ָ���ȥδ����ջ�Ĵ�С�͵�����һ��ģʽ��SPָ��λ��
;���������쳣�ж�ģʽ�����趨��ջָ��
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size
;����FIQ�ж�ģʽ�����趨��ջָ��
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size
;����IRQ�ж�ģʽ�����趨��ջָ��
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size
;�������ģʽ�����趨��ջָ��
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size
;�����û�ģʽ�����趨��ջָ��
                MSR     CPSR_c, #Mode_USR
                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size
;�����û�ģʽ
                MSR     CPSR_c, #Mode_USR
                IF      :DEF:__MICROLIB     ;���������__MICROLIB
                EXPORT __initial_sp           ;��ô������__initial_sp
                ELSE
                MOV     SP, R0                    ;������趨�û�ģʽջָ��
                SUB     SL, SP, #USR_Stack_Size
                ENDIF


;C���Կ�ʼ			  
				IMPORT  __main
                LDR     R0, =__main
                BX      R0

                IF      :DEF:__MICROLIB

                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE
; User Initial Stack & Heap
                AREA    |.text|, CODE, READONLY

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap
__user_initial_stackheap

                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + USR_Stack_Size)
                LDR     R2, = (Heap_Mem +      Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR
                ENDIF




 END


             







               





