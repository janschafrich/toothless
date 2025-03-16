import cocotb
import typing
import numpy as np
from constants_pkg import *
import rv_instructions as rv


_current_instr = None


def set_current_instr(instr : rv.RVInstr):
    """Sets the current instruction globally."""
    global _current_instr
    _current_instr = instr



def print_signal(signal):
    """Prints signame and current value"""
    print(f"             {signal._name}={signal.value}")



def assert_response(signal, expected_response: int):
    """Assertion function that automatically prints the current instruction if an error occurs."""
    if expected_response < 0:
        assert signal.value.signed_integer == expected_response, \
            f"Expected {signal._name}={(expected_response)}, got {signal._name}={(signal.value)}"
    else:
        assert int(signal.value) == int(expected_response), \
            f"Expected {signal._name}={(expected_response)}, got {signal._name}={(signal.value)}\n" \
            f"Offending instruction: {_current_instr.get_formatted_fields() if _current_instr else 'No instruction set'}"