;*********************************
;*********************************
;**小月月の简化启动代码+点一个灯**
;**          2015/1/16          **
;**        平台: mini2440       **
;**       为了更美好的明天      **
;**           bitmen            **
;**      看门狗初始化	  !!	**
;**      时钟初始化		  !!	**
;**      存储控制器初始化 !!	**
;**       GPIO口初始化	  XX	**
;**			  中断配置			
;**     必须堆栈初始化必须
;**    跳转到C文件的main函数执行
;**没有中断 堆栈不懂 SDRAM不清楚**
;*********************************
;*********************************

;*************************** define ***************************

;系统时钟宏定义
LOCKTIME_Val    EQU     0x0FFF0FFF
MPLLCON_Val     EQU     0x00043011
UPLLCON_Val     EQU     0x00038021
CLKCON_Val      EQU     0x00006010
CLKSLOW_Val     EQU     0x00000004
CLKDIVN_Val     EQU     0x0000000F
CLKCON          EQU     0x4C00000C
;PLL地址
CLOCK_BASE      EQU     0x4C000000     
LOCKTIME_OFS    EQU     0x00            
MPLLCON_OFS     EQU     0x04           
UPLLCON_OFS     EQU     0x08           
CLKCON_OFS      EQU     0x0C         
CLKSLOW_OFS     EQU     0x10         
CLKDIVN_OFS     EQU     0x14   


;内存管理宏定义
;内存管理数值
MC_SETUP        EQU     1
BWSCON_Val      EQU     0x22000000;bank7 32位  bank6 32位  bank6,7 必须相同大小	 bank1-5都是8位
BANKCON0_Val    EQU     0x00000700;访问周期		14个时钟
BANKCON1_Val    EQU     0x00000700
BANKCON2_Val    EQU     0x00000700
BANKCON3_Val    EQU     0x00000700
BANKCON4_Val    EQU     0x00000700
BANKCON5_Val    EQU     0x00000700
BANKCON6_Val    EQU     0x00018005
BANKCON7_Val    EQU     0x00018005
REFRESH_Val     EQU     0x008404F3;刷新使能 6个时钟 刷新计数值
BANKSIZE_Val    EQU     0x00000002
MRSRB6_Val      EQU     0x00000020;两个时钟
MRSRB7_Val      EQU     0x00000020;两个时钟
;内存管理地址
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


;堆栈模式设置
Mode_USR        EQU     0x10   ;用户模式
Mode_FIQ        EQU     0x11     ;快中断模式
Mode_IRQ        EQU     0x12    ;中断模式
Mode_SVC        EQU     0x13   ;管理模式
Mode_ABT        EQU     0x17   ;数据访问中止模式
Mode_UND        EQU     0x1B  ;未定义指令中止模式
Mode_SYS        EQU     0x1F   ;系统模式
I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled
;设置栈空间
UND_Stack_Size  EQU     0x00000000  ;未定义模式
SVC_Stack_Size  EQU     0x00000008  ;管理模式栈长度
ABT_Stack_Size  EQU     0x00000000  ;数据访问中止模式栈长度
FIQ_Stack_Size  EQU     0x00000000   ;快中断模式栈长度
IRQ_Stack_Size  EQU     0x00000080  ;中断模式栈长度
USR_Stack_Size  EQU     0x00000400 ;用户模式栈长度
ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + FIQ_Stack_Size + IRQ_Stack_Size)      ;所有的堆栈大小进行相加，得到总堆栈大小
     
	 AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size	;SPACE指令用于分配一块内存单元。这里分别为这两个栈分配对应
__initial_sp    SPACE   ISR_Stack_Size	;长度的内存空间
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



;关闭watching dog
 ldr r0, =0x53000000                    
 mov r1, #0                                      
 str r1, [r0]



;关闭全部中断
;主要中断
 ldr r0, =0x4A000008  
 ldr r1, =0xffffffff
 str r1, [r0]
;次级中断		
 ldr r0, =0x4A00001C
 ldr r1, =0x7fff
 str r1, [r0]



;设置锁相环PPL
;锁定时钟
 ldr r0, =CLOCK_BASE
 ldr r1, =LOCKTIME_Val
 str r1, [r0, #LOCKTIME_OFS]
;分频设置
 mov r1, #CLKDIVN_Val  						 
 str r1, [r0, #CLKDIVN_OFS]
;主频设置
 ldr r1, =MPLLCON_Val
 str r1, [r0, #MPLLCON_OFS]
 ldr r1, =UPLLCON_Val
 str r1, [r0, #UPLLCON_OFS]
;慢速时钟
 mov r1, #CLKSLOW_Val
 str r1, [r0, #CLKSLOW_OFS]
;时钟控制寄存器
 ldr r1, =CLKCON_Val
 str r1, [r0, #CLKCON_OFS]



;储存控制
;加载基地址
 ldr     r0,      =MC_BASE
;bank1-7写位宽并且禁止等待
 ldr     r1,      =BWSCON_Val
 str     r1, [r0, #BWSCON_OFS]
;配置bank0-7寄存器
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
;配置其他的寄存器
 ldr     r1,      =REFRESH_Val
 str     r1, [r0, #REFRESH_OFS]
 mov     r1,      #BANKSIZE_Val
 str     r1, [r0, #BANKSIZE_OFS]
 mov     r1,      #MRSRB6_Val
 str     r1, [r0, #MRSRB6_OFS]
 mov     r1,      #MRSRB7_Val
 str     r1, [r0, #MRSRB7_OFS]



;裸板点灯
;配置一个GPIO								 
 ldr     r0, =0x56000010
 ldr     r1, =0x155555
 str     r1, [r0]
;点亮第三个灯
 ldr     r0, =0x56000014
 ldr     r1, =0x80
 str     r1, [r0]



;堆栈
                LDR     R0, =Stack_Top        ;加载栈顶指针地址，在前边已经定义

;进入未定义模式，并设定其栈指针，将(Mode_UND | I_Bit | F_Bit)赋值给CPSR_c即CPSR_c即CPSR[7:0]
                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
                MOV     SP, R0                     ;栈顶指针赋值给SP指针
                SUB     R0, R0, #UND_Stack_Size     ;栈顶指针减去未定义栈的大小就等于下一个模式的SP指针位置
;进入数据异常中断模式，并设定其栈指针
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size
;进入FIQ中断模式，并设定其栈指针
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size
;进入IRQ中断模式，并设定其栈指针
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size
;进入管理模式，并设定其栈指针
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size
;进入用户模式，并设定其栈指针
                MSR     CPSR_c, #Mode_USR
                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size
;进入用户模式
                MSR     CPSR_c, #Mode_USR
                IF      :DEF:__MICROLIB     ;如果定义了__MICROLIB
                EXPORT __initial_sp           ;那么就声明__initial_sp
                ELSE
                MOV     SP, R0                    ;否则就设定用户模式栈指针
                SUB     SL, SP, #USR_Stack_Size
                ENDIF


;C语言开始			  
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


             







               





