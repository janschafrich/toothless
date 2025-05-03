.section .text
.global _start

_start:
    li x1, 3         # operand A
    li x2, 6         # operand B
    li x3, 3         # operator: add: 1, sub: 2, mul: 3, div: 4
    li x4, 0         # result register
    li x21, 1        # compare add
    li x22, 2        # compare sub
    li x23, 3        # compare mul
    li x24, 4        # compare div
    beq x3, x21, add_op
    beq x3, x22, sub_op
    beq x3, x23, mul_op
    beq x3, x24, div_op

add_op:
    add x4, x1, x2
    j success

sub_op: 
    sub x4, x1, x2
    j success

mul_op:
    li x5, 0                    # init counter to zero
    .accumulate:
        add x4, x4, x2          # accumulate result
        addi x5, x5, 1          # increment counter
        blt x5, x1, .accumulate  # as long as counter < multiplicand
        j success

div_op:
    li x5, 0                    # init counter to zero
    .count_n:
        sub x1, x1, x2          # divide x1 / x2 (integer div)
        addi x5, x5, 1
        ble x2, x1, .count_n     # x2 <= x1 there is at least one multiple left
        j success





success:
    li x31, 0xBEEF
