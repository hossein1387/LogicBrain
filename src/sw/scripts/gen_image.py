#!/usr/bin/env python
import numpy as np;
import matplotlib.pyplot as plt
import argparse


#=====================================================================================================
# defaul values
VGA_HEIGHT           = 480
VGA_WIDTH            = 640
OUTPUT_IMG_WIDTH     = 45
OUTPUT_IMG_HEIGHT    = 185
SPACING              = 50
NUM_IMAGES_TO_DECODE = 10


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input_filename', help='input file name', required=True)
    parser.add_argument('-o', '--output_filename', help='output file name', required=True)
    parser.add_argument('-n', '--image_to_decode', help='number of input image to decode', required=False)
    parser.add_argument('-w', '--image_width', help='image width', required=False)
    parser.add_argument('-l', '--image_height', help='image height', required=False)
    parser.add_argument('-s', '--spacing', help='spacing between images', required=False)
    args = parser.parse_args()
    return vars(args)


def load_output_txt(file, image_to_decode=NUM_IMAGES_TO_DECODE, image_height=OUTPUT_IMG_HEIGHT, image_width=OUTPUT_IMG_WIDTH):
    with open(file) as f:
        lines = f.readlines()
        images = np.ones((image_width*image_height, image_to_decode))
        # import ipdb as pdb; pdb.set_trace()
        for idx, line in enumerate(lines):
            line = line.replace("\n", "")
            if line != "\n":
                vals = list(line)
                images[idx,:] = [int(val) for val in vals]
    return images

def gen_vga_img(imgs, output_filename, image_to_decode=NUM_IMAGES_TO_DECODE, image_height=OUTPUT_IMG_HEIGHT, image_width=OUTPUT_IMG_WIDTH, spacing=SPACING):
    out_img = np.ones((VGA_HEIGHT, VGA_WIDTH))
    # import ipdb as pdb; pdb.set_trace()
    for i in range(0,image_to_decode):
        image = imgs[:, i]
        image = np.array(image)
        image = image.reshape(image_height, image_width)
        # import ipdb as pdb; pdb.set_trace()
        indw = (i+1)*spacing
        out_img[spacing:spacing+image_height, indw:indw+image_width] = image
    plt.imshow(out_img, cmap='gray')
    # import ipdb as pdb; pdb.set_trace()
    plt.savefig(output_filename+".png")

if __name__ == '__main__':
    args = parse_args()
    input_filename  = args['input_filename']
    output_filename = args['output_filename']
    image_to_decode = args['image_to_decode']
    image_width     = args['image_width']
    image_height    = args['image_height']
    spacing         = args['spacing']
    if image_to_decode == None:
        image_to_decode = NUM_IMAGES_TO_DECODE
    else:
        image_to_decode = int(image_to_decode)
    if image_width == None:
        image_width = OUTPUT_IMG_WIDTH
    else:
        image_width = int(image_width)
    if image_height == None:
        image_height = OUTPUT_IMG_HEIGHT
    else:
        image_height = int(image_height)
    if spacing == None:
        spacing = SPACING
    else:
        spacing = int(spacing)
    images = load_output_txt(input_filename, image_to_decode, image_height, image_width)
    gen_vga_img(images, output_filename, image_to_decode, image_height, image_width, spacing)
