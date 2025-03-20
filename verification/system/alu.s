.section .text
.global _start

_start:
    li x1, 1       # Load 1 into register x1
    li x2, 2       # Load 2 into register x2
    add x3, x2, x1  # add x1 and x2 = '0011'
    sll x4, x3, x2  # shift left logical x3 by x2 amount -> '1100'
    or x5, x3, x4       # '1111'
    xori x6, x5, 15
    bne x0, x6, fail
    and x7, x5, x3      # '1111' AND '0011' = '0011'
    bne x3, x7, fail
    li x30, 12      # load '1100' into x30
    li x1, 0x10000
    li x2, -1
    li x3, 0xFACE

    j success
    

fail:
    li x31, 0xDEAD
    j end

success:
    li x31, 0xBEEF

end:
    j end
