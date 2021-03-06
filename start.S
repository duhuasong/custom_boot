.global _start

_start:
	bl	reset
	ldr	pc, =reserve
	ldr	pc, =reserve
	ldr	pc, =reserve
	ldr	pc, =reserve
	ldr	pc, =reserve
	ldr	pc, _irq
	ldr	pc, =reserve

_irq:
	.word	vector_irq

vector_irq:	
	ldr	sp, =0x54000000
	sub	lr, lr, #4
	stmdb	sp!, {r0-r12, lr}
	bl	do_irq
	ldmia	sp!, {r0-r12, pc}^
		
reset:
	/*peripheral port setup*/
	ldr	r0, =0x70000000
	orr	r0, r0, #0x13
	mcr	p15, 0, r0, c15, c2, 4

	/*disable watchdog*/
	ldr	r0, =0x7E004000 
	mov	r1, #0x0
	str	r1, [r0]

	/*lowlevel init*/
	ldr	sp, =8*1024
	bl	clock_init
	bl	ddr_init
	
	/*copy code to ram*/
	adr	r0, _start
	ldr	r1, =_start
	ldr	r2, =bss_start
	sub	r2, r2, r1
	
	bl	nand2ddr

clean_bss:
	ldr	r0, =bss_start
	ldr	r1, =bss_end
	mov	r2, #0x0
bss_loop:
	str	r2, [r0], #4
	cmp	r0, r1
	ble	bss_loop

after_copy:
	ldr	pc, =do_bootm_linux

reserve:
	b	reserve
