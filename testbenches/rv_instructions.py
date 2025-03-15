
from constants_pkg import *
import numpy as np

"""
Generate RISCV instructions for verification purposes. 

"""

class RVInstr:
    def __init__(self, mnemonic=None, opcode=None):
        self.opcode     = np.uint8(opcode)
        # self.length     = np.uint8(32)
        self.mnemonic   = mnemonic


    def get_binary_string(self, with_spaces=False):
        """ Generic binary representation method.
        
        Tries to dynamically construct the binary representation based on available fields.
        If `with_spaces` is True, binary fields are separated by '_'.
        """

        fields = []

        # Check for fields dynamically (subclasses may have different attributes)
        
        if hasattr(self, 'funct7'):
            fields.append(format(self.funct7, '07b'))  #
        if hasattr(self, 'imm20'):
            fields.append(format(self.imm20 & 0xFFFFF, '020b'))  # 12-bit immediate (sign-extended)
        if hasattr(self, 'imm12'):
            fields.append(format(self.imm12 & 0xFFF, '012b'))  # 12-bit immediate (sign-extended)
        if hasattr(self, 'imm_higher'):
            fields.append(format(self.imm_higher & 0x7F, '07b'))  # 7-bit immediate S, B
        if hasattr(self, 'rs2'):
            fields.append(format(self.rs2, '05b'))  # 5-bit rs2   
        if hasattr(self, 'rs1'):
            fields.append(format(self.rs1, '05b'))  # 5-bit rs1
        if hasattr(self, 'funct3'):
            fields.append(format(self.funct3, '03b'))  # 3-bit funct3
        if hasattr(self, 'rd'):
            fields.append(format(self.rd, '05b'))  # 5-bit rd
        if hasattr(self, 'imm_lower'):
            fields.append(format(self.imm_lower & 0x1F, '05b'))  # 5-bit immediate S, B    
        if hasattr(self, 'opcode'):
            fields.append(format(self.opcode, '07b'))  # 7-bit opcode

        # Construct the final binary string
        binary_str = "_".join(fields) if with_spaces else "".join(fields)

        return binary_str if with_spaces else int(binary_str, 2)


    def get_asm(self):
        """ Generic assembly format method. """
        rd   = getattr(self, 'rd', None)
        rs1  = getattr(self, 'rs1', None)
        rs2  = getattr(self, 'rs2', None)
        imm  = getattr(self, 'imm12', None)

        if self.mnemonic is None:
            return "UNKNOWN_INSTR"

        asm_parts = [self.mnemonic]

        if rd is not None:
            asm_parts.append(f"x{rd}")
        if rs1 is not None:
            asm_parts.append(f"x{rs1}")
        if rs2 is not None:
            asm_parts.append(f"x{rs2}")
        if imm is not None:
            asm_parts.append(str(imm))

        return " ".join(asm_parts)
    


class IType(RVInstr):
    """ RISCV I opcode Instruction: 12imm + rs1 + func3 + rd + opcode """
        
    def __init__(self, imm12 : int, rs1 : int, funct3 : int, rd : int, opcode : int = I_TYPE, mnemonic : str = None):
        self.imm12  = imm12
        self.rs1    = np.uint8(rs1)
        self.funct3 = np.uint8(funct3)
        self.rd     = np.uint8(rd)
        super().__init__(mnemonic=mnemonic, opcode=opcode)
    

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
        
    def __init__(self, rs2 : int, rs1 : int, funct3 : int, rd : int, mnemonic : str = None):
        
        self.funct7 = np.uint8(1 << 5 if funct3 in [ALU_SUB, ALU_SRA] else 0)
        self.rs2    = np.uint8(rs2)
        self.rs1    = np.uint8(rs1)
        self.funct3 = np.uint8(funct3)
        self.rd     = np.uint8(rd)
        super().__init__(opcode=R_TYPE, mnemonic=mnemonic)
    

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

    def __init__(self, offset : int, rs2 : int, rs1 : int, funct3 : int, mnemonic : str = None):

        self.offset     = offset
        self.rs2        = np.uint8(rs2)
        self.rs1        = np.uint8(rs1)
        self.funct3     = np.uint8(funct3)

        imm12           = ( (offset & (0b1 << 12) ) >> 6)           # extract bit 12 and move to pos 6
        imm10_5         = ( (offset & ( 0b11_1111 << 5 ) ) >> 5 )   # getting bits 10:5 and moving them to pos 5:0
        self.imm_higher = imm12 + imm10_5
        
        imm4_1          = (offset & ( 0b1111 << 1))             # extracting bits 4:1
        imm11           = (offset >> 11) & 0b1                      # getting bit 11 and moving it to position 0
        self.imm_lower  = imm4_1 + imm11
        super().__init__(opcode=B_TYPE, mnemonic=mnemonic)

    
    # def get_formatted_fields(self):
    #     """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

    #     table = f"""
    #         rdx imm[12] imm[10:5] rs2    rs1 funct3 imm[4:1] imm[11] opcode  
    #         ----------------------------------------------------------------
    #         0b    {format(self.imm12, '01b'):>1}      {format(self.imm10_5, '06b'):>6}  {format(self.rs2, '05b'):>5}  {format(self.rs1, '05b'):>5}  {format(self.funct3, '03b'):>3}    {format(self.imm4_1, '04b'):>4}     {format(self.imm11, '01b'):>1}     {format(self.opcode, '07b'):>7}
    #         0d    {self.imm12:>1}      {self.imm10_5:>6}  {self.rs2:>5}  {self.rs2:>5}  {self.funct3:>3}    {self.imm4_1:>4}     {self.imm11:>1}  {self.opcode:>7}
    #         0x    {self.imm12:>1x}      {self.imm10_5:>6x}  {self.rs2:>5x}  {self.rs2:>5x}  {self.funct3:>3x}    {self.imm4_1:>4x}     {self.imm11:>1x}  {self.opcode:>7x}
    #     """

    #     return table

class BeqInstr(BType):
    """ Instruction instantiation """
    def __init__(self, rs1 : int, rs2 : int, imm : int):
        super().__init__(offset=imm, rs1=rs1, rs2=rs2, funct3=F3_BEQ, mnemonic='BEQ')
    
    








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
        
        self.higher = (offset >> 5) & 0b111_1111
        self.lower  = offset & 0b1_1111
        self.rs2    = rs2
        self.rs1    = rs1
        self.funct3 = funct3
        super().__init__(opcode=S_TYPE)

    # def get_binary_string(self) -> np.int32:
    #     """ Generate a machine readable (binary) instrucion """

    #     instr_str = format(self.higher, '07b') \
    #                 + format(self.rs2, '05b') \
    #                 + format(self.rs1, '05b') \
    #                 + format(self.funct3, '03b') \
    #                 + format(self.lower, '05b') \
    #                 + format(self.opcode, '07b')

    #     return int(instr_str, 2)
    

    def get_formatted_fields(self):
        """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

        table = f"""
            rdx  imm[11:5]  rs2   rs1  funct3  imm[4:0]  opcode  
            ---------------------------------------------------
            0b  {format(self.higher, '07b'):>7}    {format(self.rs2, '05b'):>5}  {format(self.rs1, '05b'):>5}  {format(self.funct3, '03b'):>3}    {format(self.lower, '05b'):>5}  {format(self.opcode, '07b'):>7}
            0d  {self.higher:>7}  {self.rs2:>5}  {self.rs1:>5}   {self.funct3:>3}   {self.lower:>5}  {self.opcode:>7}
            0x  {self.higher:>7x}  {self.rs2:>5x}  {self.rs1:>5x}   {self.funct3:>3x}   {self.lower:>5x}  {self.opcode:>7x}
        """

        return table
    

###########################################################################
#### Instruction Listing
##########################################################################


#### I Types

class AddiInstr(IType):
    """ RISCV ADDI opcode Instruction: imm + rs1 + funct3 + rd + opcode """

    def __init__(self, rd : int, rs1 : int, imm12 : int):
        super().__init__(mnemonic='ADDI', imm12=imm12, rs1=rs1, funct3=F3_ADD_SUB, rd=rd, opcode=I_TYPE)


class SltiInstr(IType):
    """ RISCV instruction definition """

    def __init__(self, rd : int, rs1 : int, imm12 : int):
        super().__init__(imm12=imm12, rs1=rs1, funct3=F3_SLT, rd=rd, opcode=I_TYPE,mnemonic='SLTI')


class SltiuInstr(IType):
    """ RISCV instruction definition """

    def __init__(self, rd : int, rs1 : int, imm12 : int):
        super().__init__(imm12=imm12, rs1=rs1, funct3=F3_SLTU, rd=rd, opcode=I_TYPE,mnemonic='SLTIU')

class AndiInstr(IType):
    """ RISCV ADDI opcode Instruction: imm + rs1 + funct3 + rd + opcode """

    def __init__(self, rd : int, rs1 : int, imm12 : int):
        super().__init__(mnemonic='ANDI', imm12=imm12, rs1=rs1, funct3=F3_AND, rd=rd, opcode=I_TYPE)


class XoriInstr(IType):
    """ RISCV instruction field definition """

    def __init__(self, rd : int, rs1 : int, imm12 : int):
        super().__init__(mnemonic='XORI', imm12=imm12, rs1=rs1, funct3=F3_XOR, rd=rd, opcode=I_TYPE)


class OriInstr(IType):
    """ RISCV instruction field definition """

    def __init__(self, rd : int, rs1 : int, imm12 : int):
        super().__init__(mnemonic='ORI', imm12=imm12, rs1=rs1, funct3=F3_OR, rd=rd, opcode=I_TYPE)


class SlliInstr(IType):
    """ RISCV instruction field definition """

    def __init__(self, rd : int, rs1 : int, shamt : int):
        super().__init__(mnemonic='SLLI', imm12=shamt, rs1=rs1, funct3=F3_SLL, rd=rd, opcode=I_TYPE)


class SrliInstr(IType):
    """ RISCV instruction field definition """

    def __init__(self, rd : int, rs1 : int, shamt : int):
        super().__init__(mnemonic='SRLI', imm12=shamt, rs1=rs1, funct3=F3_SRL_SRA, rd=rd, opcode=I_TYPE)


#### R Types

class AddInstr(RType):
    """ RISCV instruction field definition """

    def __init__(self, rd : int, rs1 : int, rs2 : int):
        super().__init__(rs2=rs2, rs1=rs1, funct3=F3_ADD_SUB, rd=rd, mnemonic='ADD')


class SllInstr(RType):
    """ RISCV instruction field definition"""

    def __init__(self, rd : int, rs1 : int, rs2 : int):
        super().__init__(rs2=rs2, rs1=rs1, funct3=F3_SLL, rd=rd, mnemonic='SLL')


class AndInstr(RType):
    """ RISCV instruction field definition"""

    def __init__(self, rd : int, rs1 : int, rs2 : int):
        super().__init__(rs2=rs2, rs1=rs1, funct3=F3_AND, rd=rd, mnemonic='AND')


class OrInstr(RType):
    """ RISCV instruction field definition"""

    def __init__(self, rd : int, rs1 : int, rs2 : int):
        super().__init__(rs2=rs2, rs1=rs1, funct3=F3_OR, rd=rd, mnemonic='OR')


class XorInstr(RType):
    """ RISCV instruction field definition"""

    def __init__(self, rd : int, rs1 : int, rs2 : int):
        super().__init__(rs2=rs2, rs1=rs1, funct3=F3_XOR, rd=rd, mnemonic='XOR')


## J Type

class JalrInstr(IType):
    """ RISCV JALR opcode Instruction: imm + rs1 + funct3 + rd + opcode """

    def __init__(self, rd : int, rs1 : int, offset : int):
        super().__init__(imm12=offset, rs1=rs1, funct3=0, rd=rd, opcode=OPC_JALR, mnemonic="JALR")


class JalInstr(RVInstr):
    """ RISCV JAL opcode Instruction: imm20 + rd + opcode """
        
    def __init__(self, rd : int, offset : int, ):

        self.offset     = offset
        imm20      = (offset >> 20) & 0b1          # getting bit 20
        imm10_1    = (offset >> 1) & 0b11_1111_1111# getting bits 10:1
        imm11      = (offset >> 11) & 0b1          # getting bit 11
        imm19_12   = (offset >> 12) & 0b1111_1111  # getting bits 19:12

        imm     = format(imm20, '01b') \
                + format(imm10_1, '010b') \
                + format(imm11, '01b') \
                + format(imm19_12, '08b') \
                        
        self.imm20      = int(imm, 2)
        self.rd         = rd
        super().__init__(mnemonic="JAL", opcode=OPC_JAL)

    
    # def get_formatted_fields(self):
    #     """ Print instruction fields for debugging purposes in a human-readable, table-like format with right-aligned columns. """

    #     table = f"""
    #         rdx imm[20] imm[10:1] imm[11] imm[19:12] rd    opcode  
    #         ------------------------------------------------------
    #         0b    {format(self.imm20, '01b'):>1}    {format(self.imm10_1, '010b'):>6}   {format(self.imm11, '01b'):>1}     {format(self.imm19_12, '08b'):>8}  {format(self.rd, '05b'):>5}  {format(self.opcode, '07b'):>7}
    #         0d    {self.imm20:>1}    {self.imm10_1:>10}   {self.imm11:>1}  {self.imm19_12:>8}   {self.rd:>5}    {self.opcode:>7}
    #         0x    {self.imm20:>1x}    {self.imm10_1:>10x}   {self.imm11:>1x}  {self.imm19_12:>8x}   {self.rd:>5x}    {self.opcode:>7x}
    #     """

    #     return table


    ## B Type

