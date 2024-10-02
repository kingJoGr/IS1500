
	
delay:
#	PUSH t6
#	PUSH t5
#	PUSH t4
#	PUSH t3

	
	li t6, 1000
	li t5, 1

while:
	beqz  t6, klar
	addi t6 , t6, -1
	li t4, 0
loop:	
	addi t4, t4, 1
	beq  t5, t4, klar_loop
	j loop
	
klar_loop:
	j while
	
	
	
klar:	
#	POP t3
#	POP t4
#	POP t5
#	POP t6
	jr ra