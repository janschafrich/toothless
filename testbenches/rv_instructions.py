
from constants_pkg import *
import numpy as np

"""
Generate RISCV instructions for verification purposes. 

"""

class RVInstr:
    def __init__(self, imm=None, funct7=None, rs2=None, rs1=None, funct3=None, rd=None, type=None):
        self.imm        = imm
        self.funct7     = funct7
        self.rs2        = rs2
        self.rs1        = rs1
        self.funct3     = funct3
        self.rd         = rd
        self.type       = type
        self.length     = 32

class IType(RVInstr):
    """ RISCV I Type Instruction: 12imm + rs1 + func3 + rd + opcode """
        
    def __init__(self, imm12 : int, rs1 : int, funct3 : int, rd : int):
        self.imm12  = np.binary_repr(imm12, 12)
        super().__init__(imm=imm12, rs1=rs1, funct3=funct3, rd=rd, type=I_TYPE )


    def get_binary(self) -> np.int32:
        """ Generate i type machine code instrucion """

        instr_str = self.imm12 \
                    + format(self.rs1, '05b') \
                    + format(self.funct3, '03b') \
                    + format(self.rd, '05b') \
                    + format(self.type, '07b')

        return int(instr_str, 2)



class RType(RVInstr):
    """ RISCV R-Type Instruction: funct7 + rs2 + rs1 + funct3 + rd + opcode """
        
    def __init__(self, rs2 : int, rs1 : int, funct3 : int, rd : int):
        
        funct7 = 1 << 5 if funct3 in [ALU_SUB, ALU_SRA] else 0
        super().__init__(funct7=funct7, rs2=rs2, rs1=rs1, funct3=funct3, rd=rd, type=R_TYPE)


    def get_binary(self) -> np.int32:
        """ Generate r type machine code instruction """

        instr_str = format(self.funct7, '07b') \
                    + format(self.rs2, '05b') \
                    + format(self.rs1, '05b') \
                    + format(self.funct3, '03b') \
                    + format(self.rd, '05b') \
                    + format(self.type, '07b')

        return int(instr_str, 2)
    

class UType(RVInstr):
    """ RISCV U Type Instruction: imm20 + rd + opcode """
        
    def __init__(self, imm : int, rd : int, opcode : int):
        imm20  = np.binary_repr(imm, 20)
        super().__init__(imm=imm20, rd=rd, type=opcode )

    def get_binary(self) -> np.int32:
        """ Generate u type machine code instruction """

        instr_str = self.imm \
                    + format(self.rd, '05b') \
                    + format(self.type, '07b') \

        return int(instr_str, 2)
    

class BType(RVInstr):
    """ RISCV B Type Instruction: imm + rs2 + rs1 + funct3 + imm + opcode """
        
    def __init__(self, offset : int, rs2 : int, rs1 : int, funct3 : int):

        # offset  = np.binary_repr(offset, 13)
        offset = bin(offset)
        self.imm12 = (offset >> 12) & 0b1        # getting bit 12
        self.imm10_5 = (offset >> 5) & 0b11_1111 # getting bits 10:5
        self.imm4_1 = (offset >> 1) & 0b1111     # getting bits 4:1
        self.imm11 = (offset >> 11) & 0b1        # getting bit 11

        imm = format(self.imm12, '01b') + format(self.imm10_5, '06b') 
        + format(self.imm4_1, '04b') + format(self.imm11, '01b')

        super().__init__(imm=imm, rs2=rs2, rs1=rs1, funct3=funct3, type=B_TYPE)


    def get_binary(self) -> np.int32:
        """ Generate u type machine code instruction """

        instr_str = format(self.imm12, '01b') \
                    + format(self.imm10_5, '06b') \
                    + format(self.rs2, '05b') \
                    + format(self.rs1, '05b') \
                    + format(self.funct3, '03b') \
                    + format(self.imm4_1, '04b') \
                    + format(self.imm11, '01b') \
                    + format(self.type, '07b') \

        return int(instr_str, 2)
    

# class JType(RVInstr):
#     """ RISCV J Type Instruction: imm20 + rd + opcode """
#     """ RISCV JALR Type Instruction: imm12 + rs1 + funct3 + rd + opcode """
        
#     def __init__(self, imm : int, rs1 : int, funct3 : int, rd : int, opcode : int):
#         imm12  = np.binary_repr(imm, 12)
#         super().__init__(imm=imm12, rs1=rs1, funct3=funct3, rd=rd, type=opcode)

#     def get_binary(self) -> np.int32:
#         """ Generate u type machine code instruction """

#         instr_str = self.imm \
#                     + format(self.rd, '05b') \
#                     + format(self.type, '07b') \

#         return int(instr_str, 2)
    

# class SType(RVInstr):
#     """ 
#         RISCV I Type Instruction
#         instruction layout
#         imm20 + rd + 7opcode
#     """
        
#     def __init__(self, imm : int, rd : int, id : int):
        
#         self.imm    = imm
#         self.rd     = rd
#         self.id     = id
#         self.type   = U_TYPE

#     def get_binary(self) -> np.int32:
#         """ Generate a machine readable (binary) instrucion """

#         instr_str = format(self.imm, '020b') \
#                     + format(self.rd, '05b') \
#                     + format(self.id, '02b') \
#                     + format(self.type, '05b')

#         return int(instr_str, 2)