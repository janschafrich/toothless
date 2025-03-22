.section .text
.global _start

_start:
    li x3, 5            # expected final counter value
    j j1


j1:
    addi x1, x1, 1      # jump counter
    beq x1, x3, success
    j j2

j2: addi x1, x1, 1
    j j3


j3: 
    addi x1, x1, 1
    j j4

j4:
    addi x1, x1, 1
    j j1
    

fail:
    li x31, 0xDEAD
    j end

success:
    li x31, 0xBEEF

end:
    j end
