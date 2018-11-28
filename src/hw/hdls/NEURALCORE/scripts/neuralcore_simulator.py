#!/usr/bin/env python
# from hw_model import * 
import hw_model as hw
import numpy as np
import os
import sys
import argparse
import subprocess
import utility as util

w_width = 16
w_height = 16
image_w = 60
image_h = 200
l1_input = w_height*w_width
l2_input = 1024
l3_input = 64
output_size = 10
stride = 1
input_file_name = "input_img.txt"


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output_filename', help='Output file name', required=False)
    parser.add_argument('-t', '--operation_type', help='Operation mode: normal, re_run', required=False)
    parser.add_argument('-v', '--verbosity', help='verbosity', required=False)
    args = parser.parse_args()
    return vars(args)

def run_model(windows, W1, W2, W3, b1, b2, b3, verbosity="VERB_HIGH"):
    AC1 = hw.AccelCore(l1_input,l2_input)
    AC2 = hw.AccelCore(l2_input,l3_input)
    AC3 = hw.AccelCore(l3_input,output_size)
    out = []
    for i in range(windows.shape[0]):
        temp_out = AC1.forward(W1,windows[i].flatten(),b1)
        temp_out = AC2.forward(W2,temp_out,b2)
        out.append(AC3.forward(W3,temp_out,b3))
        if((i%100) == 0):
            util.print_log("Iteration {0}".format(i), verbosity=verbosity)
    return out

def save_output(output_vals, output_filename):
    file_object = open(output_filename, 'w')
    for i in range(len(output_vals)):
        temp = ""
        for j in range(output_vals[i].shape[0]):
            temp += str(int(output_vals[i][j]))
        file_object.write(temp + "\n")
    file_object.close()
    util.print_log("saving outputs to {0}".format(output_filename))

if __name__ == '__main__':
    args = parse_args()
    output_filename = args['output_filename']
    operation_type  = args['operation_type']
    verbosity       = args['verbosity']
    if output_filename == None:
        output_filename = "output.txt"
    if operation_type == None:
        operation_type = "re_run"
    if verbosity == None:
        verbosity = "VERB_HIGH"

    util.print_banner("Running HW simulator", verbosity="VERB_LOW")
    if operation_type.lower() == "re_run":
        util.print_log("re-running the model...", verbosity="VERB_LOW")
        windows, W1, W2, W3, b1, b2, b3 = hw.load_params("image.npy", "w1.npy", "w2.npy", "w3.npy", "b1.npy", "b2.npy", "b3.npy", w_width, w_height, stride)
    elif operation_type.lower() == "normal":
        util.print_log("running in normal model...", verbosity="VERB_LOW")
        windows, W1, W2, W3, b1, b2, b3 = hw.gen_random_params(input_file_name, image_h, image_w, w_width, w_height, stride, l1_input, l2_input, l3_input, output_size)
    hw.save_model(W1, W2, W3)
    hw.gen_sv_weight_file("weight.svh", W1, W2, W3, b1, b2, b3)
    out = run_model(windows, W1, W2, W3, b1, b2, b3, verbosity)
    save_output(out, output_filename)
