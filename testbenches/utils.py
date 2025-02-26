import cocotb
import typing
import numpy as np
from constants_pkg import *


def assert_response(signal, expected_response : int):
    
    if expected_response < 0:
        assert signal.value.signed_integer == expected_response, \
            f"Expected {signal._name}={(expected_response)}, got {signal._name}={(signal.value)}" 
    else:
        assert signal.value == int(expected_response), \
            f"Expected {signal._name}={(expected_response)}, got {signal._name}={(signal.value)}" 