#!/usr/bin/env python
from hw_model import *
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
    args = parser.parse_args()
    return vars(args)

def gen_random_test():
    """ Generate image """ 
    image = generate_weights(image_h*image_w, 'binary')
    with open(input_file_name, "w") as img_f:
        for pixel in image:
            img_f.write("{0}\n".format(int(pixel)))
    img_f.close()
    image = image.reshape(image_h,image_w)
    np.save("image.npy", image)
    windows = (gen_window(image, w_width, w_height, stride))
    W1 = []
    W2 = []
    W3 = []
    for i in range(l2_input):
        W1.append(generate_weights(l1_input))
    for i in range(l3_input):
        W2.append(generate_weights(l2_input))
    for i in range(output_size):
        W3.append(generate_weights(l3_input))
    b1 = generate_weights(1)
    b2 = generate_weights(1)
    b3 = generate_weights(1)
    np.save("w1.npy", W1)
    np.save("w2.npy", W2)
    np.save("w3.npy", W3)
    np.save("b1.npy", b1)
    np.save("b2.npy", b2)
    np.save("b3.npy", b3)
    return windows, W1, W2, W3, b1, b2, b3

def load_params(img_npy, w1_npy, w2_npy, w3_npy, b1_npy, b2_npy, b3_npy):
    # import ipdb as pdb; pdb.set_trace()
    image = np.load(img_npy)
    windows = (gen_window(image, w_width, w_height, stride))
    w1 = np.load(w1_npy)
    w2 = np.load(w2_npy)
    w3 = np.load(w3_npy)
    b1 = np.load(b1_npy)
    b2 = np.load(b2_npy)
    b3 = np.load(b3_npy)
    return windows, w1, w2, w3, b1, b2, b3

def run_model(windows, W1, W2, W3, b1, b2, b3):
    AC1 = AccelCore(l1_input,l2_input)
    AC2 = AccelCore(l2_input,l3_input)
    AC3 = AccelCore(l3_input,output_size)
    out = []
    for i in range(windows.shape[0]):
        temp_out = AC1.forward(W1,windows[i].flatten(),b1)
        temp_out = AC2.forward(W2,temp_out,b2)
        out.append(AC3.forward(W3,temp_out,b3))
        if((i%100) == 0):
            print("Iteration " + str(i))
    return out

def save_output(output_vals, output_filename):
    file_object = open(output_filename, 'w')
    for i in range(len(output_vals)):
        temp = ""
        for j in range(output_vals[i].shape[0]):
            temp += str(int(output_vals[i][j]))
        file_object.write(temp + "\n")
    file_object.close()

if __name__ == '__main__':
    args = parse_args()
    output_filename = args['output_filename']
    operation_type  = args['operation_type']
    if output_filename == None:
        output_filename = "output.txt"
    if operation_type == None:
        operation_type = "re_run"

    if operation_type.lower() == "re_run":
        windows, W1, W2, W3, b1, b2, b3 = load_params("image.npy", "w1.npy", "w2.npy", "w3.npy", "b1.npy", "b2.npy", "b3.npy")
    elif operation_type.lower() == "normal":
        windows, W1, W2, W3, b1, b2, b3 = gen_random_test()

    out = run_model(windows, W1, W2, W3, b1, b2, b3)
    save_output(out, output_filename)
