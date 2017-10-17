library ieee;
use ieee.std_logic_1164.all;
use work.global_const.all;

package alu_const is
    type AluType is (
        INVALID,
        ALU_OR, ALU_AND
    );
end alu_const;