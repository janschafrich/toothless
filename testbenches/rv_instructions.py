
from constants_pkg import *
import numpy as np

"""
Generate RISCV instructions for verification purposes. 

"""

class RVInstr:
    def __init__(self, opcode=None):
        self.opcode     = np.uint8(opcode)
        self.length     = np.uint8(32)

class IType(RVInstr):
    """ RISCV I opcode Instruction: 12imm + rs1 + func3 + rd + opcode """
        
    def __init__(self, imm12 : int, rs1 : int, funct3 : int, rd : int, opcode : int = I_TYPE):
        self.imm12  = imm12
        self.rs1    = np.uint8(rs1)
        self.funct3 = np.uint8(funct3)
        self.rd     = np.uint8(rd)
        super().__init__(opcode=opcode)


    def get_binary(self) -> np.int32:
        """ Generate machine code instrucion """

        instr_str = np.binary_repr(self.imm12, 12) \
                    + format(self.rs1, '05b') \
                    + format(self.funct3, '03b') \
                    + format(self.rd, '05b') \
                    + format(self.opcode, '07b')

        return int(instr_str, 2)
    

    def get_formatted_fields(self):
        """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

        table = f"""
            rdx       imm12   rs1  funct3   rd   opcode  
            -------------------------------------------
            0b {np.binary_repr(self.imm12, 12):>12}  {format(self.rs1, '05b'):>5}  {format(self.funct3, '03b'):>3}  {format(self.rd, '05b'):>5}  {format(self.opcode, '07b'):>7}
            0d {self.imm12:>12}  {self.rs1:>5}  {self.funct3:>3}  {self.rd:>5}  {self.opcode:>7}
            0x {self.imm12 & 0xFFF:>12x}  {self.rs1:>5x}  {self.funct3:>3x}  {self.rd:>5x}  {self.opcode:>7x}
        """

        return table



class RType(RVInstr):
    """ RISCV R-opcode Instruction: funct7 + rs2 + rs1 + funct3 + rd + opcode """
        
    def __init__(self, rs2 : int, rs1 : int, funct3 : int, rd : int):
        
        self.funct7 = np.uint8(1 << 5 if funct3 in [ALU_SUB, ALU_SRA] else 0)
        self.rs2    = np.uint8(rs2)
        self.rs1    = np.uint8(rs1)
        self.funct3 = np.uint8(funct3)
        self.rd     = np.uint8(rd)
        super().__init__(opcode=R_TYPE)


    def get_binary(self) -> np.int32:
        """ Generate machine code instruction """

        instr_str = format(self.funct7, '07b') \
                    + format(self.rs2, '05b') \
                    + format(self.rs1, '05b') \
                    + format(self.funct3, '03b') \
                    + format(self.rd, '05b') \
                    + format(self.opcode, '07b')

        return int(instr_str, 2)
    

    def get_formatted_fields(self):
        """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

        table = f"""
            rdx  funct7   rs2   rs1  funct3   rd   opcode  
            ----------------------------------------------
            0b  {format(self.funct7, '07b'):>7}  {format(self.rs2, '05b'):>5}  {format(self.rs1, '05b'):>5}  {format(self.funct3, '03b'):>3}  {format(self.rd, '05b'):>5}  {format(self.opcode, '07b'):>7}
            0d  {self.funct7:>7}  {self.rs2:>5}  {self.rs1:>5}  {self.funct3:>3}  {self.rd:>5}  {self.opcode:>7}
            0x  {self.funct7:>7x}  {self.rs2:>5x}  {self.rs1:>5x}  {self.funct3:>3x}  {self.rd:>5x}  {self.opcode:>7x}
        """

        return table
    

class UType(RVInstr):
    """ RISCV U opcode Instruction: imm20 + rd + opcode """
        
    def __init__(self, imm : int, rd : int, opcode : int):
        self.imm20  = imm
        self.rd = np.uint8(rd)
        super().__init__(opcode=opcode)

    def get_binary(self) -> np.int32:
        """ Generate machine code instruction """

        instr_str = np.binary_repr(self.imm20, 20) \
                    + format(self.rd, '05b') \
                    + format(self.opcode, '07b') \

        return int(instr_str, 2)
    
    def get_formatted_fields(self):
        """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

        table = f"""
            rdx               imm20    rd   opcode  
            ---------------------------------------
            0b {np.binary_repr(self.imm20, 20):>20}  {format(self.rd, '05b'):>5}  {format(self.opcode, '07b'):>7}
            0d {self.imm20:>20}  {self.rd:>5}  {self.opcode:>7}
            0x {self.imm20 & 0xFFFFF:>20x}  {self.rd:>5x}  {self.opcode:>7x}
        """

        return table
    

class BType(RVInstr):
    """ RISCV B opcode Instruction: imm + rs2 + rs1 + funct3 + imm + opcode 

        RISCV instructions are either 16 bit or 32 bit and thus 2 Byte of 4 Byte aligned.
        Thus the zeroth bit of the target address is always zero. 
        This bit is not encoded into the instruction, but always appended by the hardware when calculating the offset.
        from the offset bits 12:1 are encoded into the instruction
    
    """

    def __init__(self, offset : int, rs2 : int, rs1 : int, funct3 : int):

        self.offset     = offset
        self.rs2        = np.uint8(rs2)
        self.rs1        = np.uint8(rs1)
        self.funct3     = np.uint8(funct3)
        self.imm12      = (offset >> 12) & 0b1          # getting bit 12
        self.imm10_5    = (offset >> 5) & 0b11_1111     # getting bits 10:5
        self.imm4_1     = (offset >> 1) & 0b1111        # getting bits 4:1
        self.imm11      = (offset >> 11) & 0b1          # getting bit 11
        super().__init__(opcode=B_TYPE)


    def get_binary(self) -> np.int32:
        """ Generate machine code instruction """

        instr_str = format(self.imm12, '01b') \
                    + format(self.imm10_5, '06b') \
                    + format(self.rs2, '05b') \
                    + format(self.rs1, '05b') \
                    + format(self.funct3, '03b') \
                    + format(self.imm4_1, '04b') \
                    + format(self.imm11, '01b') \
                    + format(self.opcode, '07b') \

        return int(instr_str, 2)
    
    def get_formatted_fields(self):
        """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

        table = f"""
            rdx imm[12] imm[10:5] rs2    rs1 funct3 imm[4:1] imm[11] opcode  
            ----------------------------------------------------------------
            0b    {format(self.imm12, '01b'):>1}      {format(self.imm10_5, '06b'):>6}  {format(self.rs2, '05b'):>5}  {format(self.rs1, '05b'):>5}  {format(self.funct3, '03b'):>3}    {format(self.imm4_1, '04b'):>4}     {format(self.imm11, '01b'):>1}     {format(self.opcode, '07b'):>7}
            0d    {self.imm12:>1}      {self.imm10_5:>6}  {self.rs2:>5}  {self.rs2:>5}  {self.funct3:>3}    {self.imm4_1:>4}     {self.imm11:>1}  {self.opcode:>7}
            0x    {self.imm12:>1x}      {self.imm10_5:>6x}  {self.rs2:>5x}  {self.rs2:>5x}  {self.funct3:>3x}    {self.imm4_1:>4x}     {self.imm11:>1x}  {self.opcode:>7x}
        """

        return table
    
    

class JalInstr(RVInstr):
    """ RISCV JAL opcode Instruction: imm20 + rd + opcode """
        
    def __init__(self, offset : int, dest : int):

        self.offset     = offset
        self.imm20      = (offset >> 20) & 0b1          # getting bit 20
        self.imm10_1    = (offset >> 1) & 0b11_1111_1111# getting bits 10:1
        self.imm11      = (offset >> 11) & 0b1          # getting bit 11
        self.imm19_12   = (offset >> 12) & 0b1111_1111  # getting bits 19:12
        self.rd         = dest
        super().__init__(opcode=OPC_JAL)


    def get_binary(self) -> np.int32:
        """ Generate machine code instruction """

        instr_str = format(self.imm20, '01b') \
                    + format(self.imm10_1, '010b') \
                    + format(self.imm11, '01b') \
                    + format(self.imm19_12, '08b') \
                    + format(self.rd, '05b') \
                    + format(self.opcode, '07b') \

        return int(instr_str, 2)
    
    def get_formatted_fields(self):
        """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

        table = f"""
            rdx imm[20] imm[10:1] imm[11] imm[19:12] rd    opcode  
            ------------------------------------------------------
            0b    {format(self.imm20, '01b'):>1}    {format(self.imm10_1, '010b'):>6}   {format(self.imm11, '01b'):>1}     {format(self.imm19_12, '08b'):>8}  {format(self.rd, '05b'):>5}  {format(self.opcode, '07b'):>7}
            0d    {self.imm20:>1}    {self.imm10_1:>10}   {self.imm11:>1}  {self.imm19_12:>8}   {self.rd:>5}    {self.opcode:>7}
            0x    {self.imm20:>1x}    {self.imm10_1:>10x}   {self.imm11:>1x}  {self.imm19_12:>8x}   {self.rd:>5x}    {self.opcode:>7x}
        """

        return table


class JalrInstr(IType):
    """ RISCV JALR opcode Instruction: imm + rs1 + funct3 + rd + opcode """

    def __init__(self, offset : int, base_r : int, dest_r : int):
        super().__init__(imm12=offset, rs1=base_r, funct3=0, rd=dest_r, opcode=OPC_JALR)



class LoadInstr(IType):

    def __init__(self, offset : int, base_r, width : int, dest_r : int):
        super().__init__(imm12=offset, rs1=base_r, funct3=width, rd=dest_r, opcode=OPC_LOAD)



class SType(RVInstr):
    """ 
        RISCV I opcode Instruction
        instruction layout
        imm20 + rd + 7opcode
    """
        
    def __init__(self, offset : int, rs2 : int, rs1 : int, funct3 : int):
        
        self.imm11_5 = (offset >> 5) & 0b111_1111
        self.imm4_0  = offset & 0b1_1111
        self.rs2    = rs2
        self.rs1    = rs1
        self.funct3 = funct3
        super().__init__(opcode=S_TYPE)

    def get_binary(self) -> np.int32:
        """ Generate a machine readable (binary) instrucion """

        instr_str = format(self.imm11_5, '07b') \
                    + format(self.rs2, '05b') \
                    + format(self.rs1, '05b') \
                    + format(self.funct3, '03b') \
                    + format(self.imm4_0, '05b') \
                    + format(self.opcode, '05b')

        return int(instr_str, 2)
    

    def get_formatted_fields(self):
        """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

        table = f"""
            rdx  imm[11:5]  rs2   rs1  funct3  imm[4:0]  opcode  
            ---------------------------------------------------
            0b  {format(self.imm11_5, '07b'):>7}    {format(self.rs2, '05b'):>5}  {format(self.rs1, '05b'):>5}  {format(self.funct3, '03b'):>3}    {format(self.imm4_0, '05b'):>5}  {format(self.opcode, '07b'):>7}
            0d  {self.imm11_5:>7}  {self.rs2:>5}  {self.rs1:>5}   {self.funct3:>3}   {self.imm4_0:>5}  {self.opcode:>7}
            0x  {self.imm11_5:>7x}  {self.rs2:>5x}  {self.rs1:>5x}   {self.funct3:>3x}   {self.imm4_0:>5x}  {self.opcode:>7x}
        """

        return table


