# constants defined in toothless_pkg.sv


# opcodes
R_TYPE = int('011_0011', 2)
I_TYPE = int('001_0011', 2)
S_TYPE = int('010_0011', 2)
B_TYPE = int('110_0011', 2)

LUI     = int('011_0111', 2)
AUIPC   = int('001_0111', 2)

JAL     = int('110_1111', 2)
JALR    = int('110_0111', 2)

# funct3 field
F3_ADD_SUB  = int('000', 2)
F3_SLL      = int('001', 2)

F3_BEQ      = int('000', 2) 
F3_BNE      = int('001', 2)
F3_BLT      = int('100', 2)
F3_BGE      = int('101', 2)
F3_BLTU     = int('110', 2)
F3_BGEU     = int('111', 2)


# ALU operations
# arithmetic operations
ALU_ADD     = int('0_0000', 2)
ALU_SUB     = int('0_0001', 2)
ALU_ADDU    = int('0_0010', 2)
ALU_SUBU    = int('0_0011', 2)

# logical 
ALU_AND     = int('0_0100', 2)
ALU_OR      = int('0_0101', 2)
ALU_XOR     = int('0_0110', 2)

# # shifts
ALU_SRL     = int('0_1000', 2)
ALU_SRA     = int('0_1001', 2)
ALU_SLL     = int('0_1010', 2)

# # comparisons
ALU_SLT     = int('1_0000', 2)
ALU_SLTU    = int('1_0001', 2)
ALU_LES     = int('1_0010', 2)
ALU_LEU     = int('1_0011', 2)
ALU_GTS     = int('1_0100', 2)
ALU_GTU     = int('1_0101', 2)
ALU_GES     = int('1_0110', 2)
ALU_GEU     = int('1_0111', 2)
ALU_EQ      = int('1_1001', 2)
ALU_NE      = int('1_1010', 2)



OP_A_REG      = int('00', 2)
OP_A_CURPC    = int('01', 2)
OP_A_IMM      = int('10', 2)

OP_B_REG      = int('00', 2)
OP_B_IMM      = int('10', 2)