# timetemplate.S
# Written 2015 by F Lundevall
# Ported 2024/06 by W Szczerek (from MIPS to RISC-V)
# Copyright abandonded - this file is in the public domain.

#############################################################
# Choose the macro syntax for RARS or DTEK-V board.         #
# The syntax for RARS is probably due to its MIPS heritage. #
#############################################################
###################
 #Macros for RARS #
###################
#.macro    PUSH (%reg)
#    addi    sp,sp,-4
#    sw    %reg,0(sp)
#.end_macro

#.macro    POP (%reg)
    #lw    %reg,0(sp)
#    addi    sp,sp,4
#.end_macro
###################
# Macros for DTEK #
###################
.macro    PUSH reg
    addi sp,sp,-4
    sw \reg,0(sp)
.endm

.macro    POP reg
    lw    \reg,0(sp)
    addi    sp,sp,4
.endm
############################################################

    .data
    .align 2
mytime:    .word     0x5957
timstr:    .asciz     "text more text lots of text\0"
    .text
    .globl timetemplate, tick, time2string, display_string, delay

# Function for displaying a string with a newline at the end    
display_string:    
    li a7,4
    ecall
    li a0, 10
    li a7,11
    ecall
    jr ra
    
timetemplate:
    la    a0, timstr
    jal     display_string
    
    # wait a little
    li    a0, 980        # ms
    jal    delay
    
    # call tick
    la     a0, mytime
    jal    tick
    
    # call your function time2string
    la    a0, timstr
    la    t0, mytime
    lw    a1, 0(t0)
    jal    time2string
    
    # go back and do it all again
    j    timetemplate

    
# tick: update time pointed to by $a0
tick:    lw    t0, 0(a0)    # get time
    addi    t0, t0, 1    # increase
    andi    t1, t0, 0xf    # check lowest digit
    sltiu    t2, t1, 0xa    # if digit < a, okay
    bnez    t2, tiend
    addi    t0, t0, 0x6    # adjust lowest digit
    
    andi    t1, t0, 0xf0    # check next digit
    sltiu    t2, t1, 0x60    # if digit < 6, okay
    bnez    t2, tiend
    addi    t0, t0, 0xa0    # adjust digit
    
    li    t3, 0xF
    slli    t3, t3, 0x8
    and    t1, t0, t3    # check minute digit
    addi    t3, x0, 0xA
    slli    t3, t3, 0x8
    slt    t2, t1, t3    # if digit < a, okay
    bnez    t2, tiend
    addi    t0, t0, 0x600    # adjust digit - this one's okay, it's lower than 0x7FF
    
    li    t3, 0xF
    slli    t3, t3, 0xC
    and    t1, t0, t3    # check last digit
    addi    t3, x0, 0x6
    slli    t3, t3, 0xC
    slt    t2, t1, t3    # if digit < 6, okay
    bnez    t2, tiend
    
    li    t3, 0xA
    slli    t3, t3, 0xC
    add    t0, t0, t3    # adjust last digit
tiend:    sw    t0,0(a0)    # save updated result
    jr    ra        # return

#########################################################
# Place for your functions: time2string, hex2asc, delay.#
#########################################################

time2string:
    PUSH s0
    PUSH s1
    add s0, a0,zero
    li a0, 0
    add s1, a1, zero
    li a1, 0
    
    andi a0, s1, 0xF       
    PUSH ra          
    jal hexasc
    POP ra            
    PUSH a0
    li a0, 0
    srli s1, s1, 4
    
    andi a0, s1, 0xF       
    PUSH ra             
    jal hexasc
    POP ra           
    PUSH a0
    li a0, 0
    srli s1, s1, 4

    li t2, 0x3a
    PUSH t2

    andi a0, s1, 0xF       
    PUSH ra             
    jal hexasc
    POP ra           
    PUSH a0
    li a0, 0
    srli s1, s1, 4

    andi a0, s1, 0xF       
    PUSH ra             
    jal hexasc
    POP ra            
    PUSH a0
    li a0, 0
    
    POP t1
    sb t1, (s0)
    addi s0, s0, 1
    POP t1
    sb t1, (s0)
    addi s0, s0, 1
    POP t1
    sb t1, (s0)
    addi s0, s0, 1
    POP t1
    sb t1, (s0)
    addi s0, s0, 1
    POP t1
    addi t2, zero, 0x39
    beq t1, t2, nine
    sb t1, (s0)
    addi s0, s0, 1
    j ej
    
    
nine:    
    addi t1,zero,0x4e
    sb t1, (s0)
        addi s0, s0, 1
        
    addi t1,zero,0x49
    sb t1, (s0)
        addi s0, s0, 1    
     
     addi t1,zero,0x4e
    sb t1, (s0)
        addi s0, s0, 1   
    
    
    addi t1,zero,0x45
    sb t1, (s0)
        addi s0, s0, 1    
        
        j nikl
    
ej:
 
    li t1, 0
    sb t1, (s0)
    
    addi s0, s0, -5
    POP s1
    POP s0
    jr ra  
    
nikl:
    li t1, 0
    sb t1, (s0)
    
    addi s0, s0, -8              
    POP s1
    POP s0
    jr ra
delay:
    blez a0, klar
    li t4, 0
    li t5, 10780
    li t6 , -1
    add t3 ,zero, a0
point1:
    beq t4,t5, vidare
    addi t4,t4, 1
    
    j point1
    
vidare:
    li t4, 0
    add t3, t6, t3
    beqz t3, klar
    j point1
    
klar:
    jr ra
