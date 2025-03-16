.section .text
.global _start

_start:
    li x1, 42       # Load 42 into register x1
    li x2, 10       # Load 10 into register x2
    add x3, x1, x2  # x3 = x1 + x2
    beq x3, x1, fail
    j success

fail:
    li x4, 0xDEAD
    j end

success:
    li x4, 0xBEEF

end:
    j end
