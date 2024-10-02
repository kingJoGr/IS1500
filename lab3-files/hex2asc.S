# hexmain.S
  # Written 2015-09-04 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

    .text
    .globl hex2asc, hexasc

hex2asc:
    li    a0, 10        # test number (from 0 to 15)
    
    addi    sp,sp,-4
    sw      ra,0(sp)
    
    jal    hexasc        # call hexasc
    
    li    a7, 11    # write a0 to stdout
    ecall

    lw      ra,0(sp)
    addi    sp,sp,4
    jr      ra    

  # You can write your own code for hexasc here
  #
    
hexasc:
    
    andi t1, a0, 0xF
    li t0, 10
    bge t1, t0, greater
    li t0, 0x30
    add a0, t1, t0
    j end
greater:
    li t2, 0x37
    add a0, t1, t2
end:
    ret

	

	
