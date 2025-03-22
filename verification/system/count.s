.section .text
.global main

main:
    li x1, 64
    .loop:
        addi x1, x1, -1
        bnez x1, .loop
        
    j success

success:
    li x31, 0xBEEF