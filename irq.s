.global _start
.text
_start:
    b _Reset                        @ Posição 0x00 - Reset
    ldr pc, _undefined_instruction  @ Posição 0x04 - Intrução não-definida
    ldr pc, _software_interrupt     @ Posição 0x08 - Interrupção de Software
    ldr pc, _prefetch_abort         @ Posição 0x0C - Prefetch Abort
    ldr pc, _data_abort             @ Posição 0x10 - Data Abort
    ldr pc, _not_used               @ Posição 0x14 - Não utilizado
    ldr pc, _irq                    @ Posição 0x18 - Interrupção (IRQ)
    ldr pc, _fiq                    @ Posição 0x1C - Interrupção(FIQ)
_Reset:
    ldr sp, =stack_top
	MRS r0, cpsr    				@ salvando o modo corrente em R0
	MSR cpsr_ctl, #0b11010011 		@ alterando o modo para SUPERVISOR - o SP eh automaticamente chaveado ao chavear o modo 
    LDR sp, =pilhaSUPERVISOR		@ a pilha de SUPERVISOR eh setada 
	MSR cpsr, r0 					@ volta para o modo anterior 
	MRS r0, cpsr    				@ salvando o modo corrente em R0
	MSR	cpsr_ctl, #0b11010010		@ alterando o modo para INTERRUPT
    LDR	sp, =pilhaINTERRUPT			@ a pilha de INTERRUPT eh setada
	MSR	cpsr, r0					@ volta para o modo anterior
    bl  main
    b .
undefined_instruction:
    b .
software_interrupt:
    b do_software_interrupt @ Vai para o handler de interrupções de software
prefetch_abort:
    b .
data_abort:
    b .
not_used:
    b .
irq:
    b do_irq_interrupt @ Vai para o handler de interrupções IRQ
fiq:
    b .
do_software_interrupt:
    add r1, r2, r3 @ r1 = r2 + r3
    mov pc, lr @ Volta p/ o endereço armazenado em lr
do_irq_interrupt:
    NOP
    STMFD   sp!, {r0-r12} @salva r0-r12 na pilhaINTERRUPT
    SUB     lr, lr, #4
    LDR     r0, =nproc
    LDR     r0, [r0] @armazena nproc em r0
    CMP     r0, #0  @estou no A, bora chavear B
    BEQ     chaveiaB
    CMP     r0, #1  @estou no B, bora chavear A
    BEQ     chaveiaA
chaveiaB:
    LDMFD   sp!, {r0-r12} @recupera r0-r12 na pilhaINTERRUPT
    STMFD   sp!, {lr}   @armazena pc do A na pilhaINTERRUPT
a:
    LDR     lr, =linhaA
    STMIA   lr, {r0 - r12} @ BOTA NO LINHAA os registradores padrao
    LDR     r2, =linhaA
b:  
    MRS     r0, SPSR @armazena spsr em r0
    STR     r0, [r2, #64] @salva cpsr em linhaA
    MRS     r1 , cpsr @salvando o modo corrente em r1
    ORR     r0, r0, #0xC0 @ garanto que os bits 6 e 7 - I & F sao 11
    MSR     cpsr, r0
    STR     sp, [r2, #52] @ BOTA NO LINHAA sp
    STR     lr, [r2, #56]@ BOTA NO LINHAA lr
    MSR     cpsr, r1   @ volta pro modo IRQ
    LDMFD   sp!, {lr} @ desempilho o pc da pilhaINTERRUPT
    STR     lr, [r2, #60] @salva pc em linhaA
c:
    LDR     r0, INTPND @ Carrega o registrador de status de interrupção
    LDR     r0, [r0]
    TST     r0, #0x0010 @ Cerifica se é uma interupção de timer
    BLNE    handler_timer @ Vai para o rotina de tratamento da interupção de timer
    LDR     lr, =linhaB
    LDR     r0, [lr, #60] @recupera pc de linhaB
    STMFD   sp!, {r0}   @coloca pc na pilha IRQ
    LDMIA   lr, {r0 - r12}  @recupera r0-r12 de linhaB
    STMFD   sp!, {r0 - r12} @coloca r0-12 na pilha IRQ
    MRS     r0, cpsr    				@ salvando o modo corrente em R0
	MSR     cpsr_ctl, #0b11010011 		@ alterando o modo para SUPERVISOR - o SP eh automaticamente chaveado ao chavear o modo
    LDR     r5, =linhaB
	LDR     sp, [r5, #52]
    LDR     lr, [r5, #56] 
	MSR     cpsr, r0 					@ volta para o modo anterior 
    LDR     r0, =nproc
    LDR     r1, =0x1    @modifica nproc
    STR     r1, [r0]
    LDR     r0, =linhaB
    LDR     r1, [r0, #64] @recupera cpsr de linhaB
    MSR     spsr , r1 @escreve cpsr no spsr
    LDMFD   sp!, {r0 - r12, pc}^ @ Retorna
chaveiaA:
    LDMFD   sp!, {r0-r12} @recupera r0-r12 na pilhaINTERRUPT
    STMFD   sp!, {lr}   @armazena pc do A na pilhaINTERRUPT
aa:
    LDR     lr, =linhaB
    STMIA   lr, {r0 - r12} @ BOTA NO LINHAA os registradores padrao
    LDR     r2, =linhaB
bb:  
    MRS     r0, SPSR @armazena spsr em r0
    STR     r0, [r2, #64] @salva cpsr em linhaA
    MRS     r1 , cpsr @salvando o modo corrente em r1
    ORR     r0, r0, #0xC0 @ garanto que os bits 6 e 7 - I & F sao 11
    MSR     cpsr, r0
    STR     sp, [r2, #52] @ BOTA NO LINHAB sp
    STR     lr, [r2, #56]@ BOTA NO LINHAB lr
    MSR     cpsr , r1   @ volta pro modo IRQ
    LDMFD   sp!, {lr} @ desempilho o pc da pilhaINTERRUPT
    STR     lr, [r2, #60] @salva pc em linhaA
cc:
    LDR     r0, INTPND @ Carrega o registrador de status de interrupção
    LDR     r0, [r0]
    TST     r0, #0x0010 @ Cerifica se é uma interupção de timer
    BLNE    handler_timer @ Vai para o rotina de tratamento da interupção de timer
    LDR     lr, =linhaA
    LDR     r0, [lr, #60] @recupera pc de linhaB
    STMFD   sp!, {r0}   @coloca pc na pilhaB
    LDMIA   lr, {r0 - r12}  @recupera r0-r12 de linhaB
    STMFD   sp!, {r0 - r12} @coloca r0-12 na pilha IRQ
    MRS     r0, cpsr    				@ salvando o modo corrente em R0
	MSR     cpsr_ctl, #0b11010011 		@ alterando o modo para SUPERVISOR - o SP eh automaticamente chaveado ao chavear o modo
    LDR     r5, =linhaA
	LDR     sp, [r5, #52]
    LDR     lr, [r5, #56] 
	MSR     cpsr, r0 					@ volta para o modo anterior 
    LDR     r0, =nproc
    LDR     r1, =0x0       @modifica nproc
    STR     r1, [r0]
    LDR     r0, =linhaA
    LDR     r1, [r0, #64] @recupera cpsr de linhaB
    MSR     spsr , r1 @escreve cpsr no spsr
    LDMFD   sp!, {r0 - r12, pc}^ @ Retorna
timer_init: nop
    ldr r0, INTEN
    ldr r1, =0x10 @bit 4 for timer 0 interrupt enable
    str r1, [r0]
    ldr r0, TIMER0L
    ldr r1, =0xfff @setting timer value
    str r1,[r0]
    ldr r0, TIMER0C
    mov r1, #0xE0 @enable timer module
    str r1, [r0]
    mrs r0, cpsr
    bic r0, r0, #0x80
    msr cpsr_c, r0 @enabling interrupts in the cpsr
    mov pc, lr
main:
    BL timer_init @ Initialize interrupts and timer 0
    BL initB
    LDR sp, =pilhaA
    BL taskA
initB:
    LDR r0, =pilhaB
    LDR r1, =linhaB
    LDR r2, =taskB
    MRS r3, cpsr
    BIC r3, #0x80
    STR r0, [r1, #52] @escreve sp pilhaB em linhaB
    STR r2, [r1, #60] @escreve pc taskB em linhaB
    STR r3, [r1, #64] @escreve cpsr em linhaB
    MOV pc, lr
_undefined_instruction: .word undefined_instruction
_software_interrupt: .word software_interrupt
_prefetch_abort: .word prefetch_abort
_data_abort: .word data_abort
_not_used: .word not_used
_irq: .word irq
_fiq: .word fiq
INTPND: .word 0x10140000    @ Interrupt status register
INTSEL: .word 0x1014000C    @ Interrupt select register( 0 = irq, 1 = fiq)
INTEN: .word 0x10140010     @ Interrupt enable register
TIMER0L: .word 0x101E2000   @ Timer 0 load register
TIMER0V: .word 0x101E2004   @ Timer 0 value registers
TIMER0C: .word 0x101E2008   @ Timer 0 control register
TIMER0X: .word 0x101E200c   @ Timer 0 interrupt clear register
linhaA: .space 68
linhaB: .space 68
nproc:  .word 0
