# constants defined in toothless_pkg.sv

R_TYPE = '011_0011'
I_TYPE = '001_0011'
S_TYPE = '010_0011'
B_TYPE = '110_0011'
U_TYPE = '1_0111'


# funct3 field
F3_ADD_SUB = "000"
F3_SLL = "001"


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