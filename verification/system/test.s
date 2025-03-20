.section .text
.global _start

# test for the load store unit
# https://projectf.io/posts/riscv-load-store/
_start:
    li x1, 4            # write 4 into x1
    li x2, 2            # write 2 into x2
    sw x2, 0(x1)       # store word in x2 at x1 with offest of zero
    sw x2, 0(x0)       # store word in x2 at address zero with offest of zero
    sw x2, 4(x1)       # store word in x2 at x1 with offest of 4
    lw x3, 0(x1)       # load from address x1 with offest of zero, store in x3: load value 2
    lw x4, -4(x1)       # load from address 4 with offest of -4, store in x4: load value 2
    bne x3, x4, fail

    # unsigned byte
    li x1, 4            # write 4 into x1 (to be used as address)
    li x2, 2            # write 2 into x2 (to be used as data)
    sb x2, 0(x1)       # store word in x2 at x1 with offest of zero
    sb x2, 0(x0)       # store word in x2 at address zero with offest of zero
    sb x2, 4(x1)       # store word in x2 at x1 with offest of 4
    lbu x3, 0(x1)       # load from address x1 with offest of zero, store in x3: load value -2
    lbu x4, -4(x1)       # load from address 4 with offest of -4, store in x4: load value -2
    bne x3, x4, fail

    # signed halfword
    li x1, 4            # write 4 into x1 (to be used as address)
    li x2, -2            # write 2 into x2 (to be used as data)
    sh x2, 0(x1)       # store word in x2 at x1 with offest of zero
    sh x2, 0(x0)       # store word in x2 at address zero with offest of zero
    sh x2, 4(x1)       # store word in x2 at x1 with offest of 4
    lh x3, 0(x1)       # load from address x1 with offest of zero, store in x3: load value -2
    lh x4, -4(x1)       # load from address 4 with offest of -4, store in x4: load value -2
    bne x3, x4, fail
    j success
    

fail:
    li x31, 0xDEAD
    j end

success:
    li x31, 0xBEEF

end:
    j end
