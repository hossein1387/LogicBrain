#!/usr/bin/env python

import os
import sys
import argparse
import utility as util

#=======================================================================
# Globals
#=======================================================================
available_instr = {"ldc":8, "strr":7, "strw":6, "strx":5, "ldw":4, "ldx":3, "conv":2, "wait":1, "nop":0}
get_bin = lambda x, n: format(x, 'b').zfill(n) if x<(2**n -1) \
                       else util.print_log("{0} exceeds maximum {1}".format(x, (2**n -1)), id_str="ERROR", verbosity="VERB_LOW")
INSTRUCTION_LENGTH = 42
#=======================================================================
# Utility Funcs
#=======================================================================

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--inputfile', help='Input assembly source code for accel core processor', required=True)
    parser.add_argument('-o', '--outputfile', help='Output binary file', required=False)
    parser.add_argument('-v', '--verbosity', help='Print verbosity', required=False)
    args = parser.parse_args()
    return vars(args)


def decode_instr(instr_, line_num):
    # import ipdb as pdb; pdb.set_trace()
    instr = instr_.split(",")
    instr_bin_str = ""
    instr_len = len(instr)
    if instr[0] in available_instr:
        opcode = instr[0]
        if opcode == "ldc":
            if instr_len != 3:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, ldc requires 2 args but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                opcode = get_bin(available_instr[opcode], 4)
                pes    = get_bin(int(instr[1]), 32)
                accl_id= get_bin(int(instr[2]), 6)
                instr_bin_str += opcode + pes + accl_id
        elif opcode == "strr":
            if instr_len!= 3:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, strr requires 2 args but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                # import ipdb as pdb; pdb.set_trace()
                opcode = get_bin(available_instr[opcode], 4)
                dst    = get_bin(int(instr[1]), 16)
                rsv    = get_bin(0, 16)
                accl_id= get_bin(int(instr[2]), 6)
                instr_bin_str += opcode + dst + rsv + accl_id
        elif opcode == "strw":
            if instr_len!= 2:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, strw requires 1 arg but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                opcode = get_bin(available_instr[opcode], 4)
                dst    = get_bin(int(instr[1]), 16)
                rsv1   = get_bin(0, 16)
                rsv2   = get_bin(0, 6)
                instr_bin_str += opcode + dst + rsv1 + rsv2
        elif opcode == "strx":
            if instr_len!= 2:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, strx requires 1 arg but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                opcode = get_bin(available_instr[opcode], 4)
                dst    = get_bin(int(instr[1]), 16)
                rsv1   = get_bin(0, 16)
                rsv2   = get_bin(0, 6)
                instr_bin_str += opcode + dst + rsv1 + rsv2 
        elif opcode == "ldw":
            if instr_len!= 4:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, ldw requires 3 args but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                opcode = get_bin(available_instr[opcode], 4)
                pe_num = get_bin(int(instr[1]), 16)
                src    = get_bin(int(instr[2]), 16)
                accl_id= get_bin(int(instr[3]), 6)
                instr_bin_str += opcode + pe_num + src + accl_id
        elif opcode == "ldx":
            if instr_len!= 4:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, ldx requires 3 args but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                opcode = get_bin(available_instr[opcode], 4)
                pe_num = get_bin(int(instr[1]), 16)
                src    = get_bin(int(instr[2]), 16)
                accl_id= get_bin(int(instr[3]), 6)
                instr_bin_str += opcode + pe_num + src + accl_id
        elif opcode == "conv":
            if instr_len!= 3:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, conv requires 2 arg but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                # import ipdb as pdb; pdb.set_trace()
                opcode = get_bin(available_instr[opcode], 4)
                code   = 4*"1010"
                rsv    = get_bin(0, 16)
                accl_id= get_bin(int(instr[2]), 6)
                instr_bin_str += opcode + code + rsv + accl_id
        elif opcode == "wait":
            if instr_len!= 1:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, wait requires no arg but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                opcode = get_bin(available_instr[opcode], 4)
                code   = 4*"1010"
                rsv1   = get_bin(0, 16)
                rsv2   = get_bin(0, 6)
                instr_bin_str += opcode + code + rsv1 + rsv2
        elif opcode == "nop":
            if instr_len!= 1:
                util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
                util.print_log("line[{0}]: syntax error, nop requires no arg but {1} was passed".format(line_num, instr_len-1), id_str="ERROR", verbosity="VERB_LOW")
                sys.exit()
            else:
                opcode = get_bin(available_instr[opcode], 4)
                code   = 4*"0000"
                rsv1   = get_bin(0, 16)
                rsv2   = get_bin(0, 6)
                instr_bin_str += opcode + code + rsv1 + rsv2
    else:
        util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
        util.print_log("line[{0}]: Unknown instruction".format(line_num), id_str="ERROR", verbosity="VERB_LOW")
        sys.exit()
    if len(instr_bin_str) != INSTRUCTION_LENGTH:
        util.print_log("{0}".format(instr_), id_str="ERROR", verbosity="VERB_LOW")
        util.print_log("line[{0}]: Exceed the expected instruction bit width ({1}).".format(line_num, INSTRUCTION_LENGTH), id_str="ERROR", verbosity="VERB_LOW")
        sys.exit()
    return instr_bin_str

def clean_code_line(line):
    line = line.replace(" ", "")
    line = line.replace("\n", "")
    if "#" in line:
        comment_indx = line.find('#')
        line = line[:comment_indx]
    line = line.lower()
    return line

def parse_code(file):
    with open(file, "r") as f:
        lines = f.readlines()
        line_num = 0
        code_str = ""
        bin_str_code = ""
        for line in lines:
            line_num += 1
            line = clean_code_line(line)
            if line != "":
                bin_instr = line.ljust(15, ' ') + ":" + decode_instr(line, line_num)
                bin_str_code += bin_instr + "\n"
                util.print_log(bin_instr, id_str="INFO", color="green", verbosity="VERB_LOW")
#=======================================================================
# Main
#=======================================================================
if __name__ == '__main__':
    cmd_to_run = ""
    args = parse_args()
    verbosity = args["verbosity"]
    inputfile = args["inputfile"]
    outputfile= args["outputfile"]
    if verbosity is None:
        verbosity = "VERB_LOW"
    util.print_banner("Accel Core Assembler", verbosity=verbosity)
    parse_code(inputfile)

