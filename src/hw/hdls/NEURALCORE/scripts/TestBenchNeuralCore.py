#!/usr/bin/env python

from window_slider_unit_test import gen_window
import numpy as np

w_width = 16
w_height = 16
image_w = 60
image_h = 200
l1_input = w_height*w_width
l2_input = 1024
l3_input = 64
output_size = 10
stride = 1

""" Generate weights """
def generate_weights(size, type='ternary'):
    W1 = np.random.normal(0, 1.0, (size))
    for i in range(W1.shape[0]):
        if type.lower() == "binary":
            if(W1[i]>0):
                W1[i] = 1
            else:
                W1[i] = 0
        else:
            if(W1[i]>0.5):
                W1[i] = 1
            elif(W1[i]<-0.5):
                W1[i] = -1
            else:
                W1[i] = 0
    return W1

""" Generate image """ 
image = generate_weights(image_h*image_w, 'binary')
# import ipdb as pdb; pdb.set_trace()
with open("input_img.txt", "w") as img_f:
    for pixel in image:
        img_f.write("{0}\n".format(int(pixel)))
img_f.close()
image = image.reshape(image_h,image_w)
# image = np.zeros((image_h,image_w))
# for i in range(image.shape[0]):
#     for j in range(image.shape[1]):
#         if(i%2):
#             image[i,j] = 0
#         else:
#             image[i,j] = 1
# import ipdb as pdb; pdb.set_trace()
window = (gen_window(image, w_width, w_height, stride))

W1 = []
W2 = []
W3 = []

for i in range(l2_input):
    W1.append(generate_weights(l1_input))
for i in range(l3_input):
    W2.append(generate_weights(l2_input))
for i in range(output_size):
    W3.append(generate_weights(l3_input))
#import ipdb as pdb; pdb.set_trace()
b1 = generate_weights(1)
b2 = generate_weights(1)
b3 = generate_weights(1)

""" AccelCore """
class AccelCore():
    def __init__(self, input_size, output_size):
        self.input_size_ = input_size
        self.output_size_ = output_size

    def multiply(self, weight, window, bias):
        return (np.dot(weight, window) + bias)
    
    def activation(self, value):
        if(value > 0):
            return  1
        else:
            return 0
    
    def fillBuffer(self, weights, window, bias):
        bufferOut = np.zeros(self.output_size_)
        for i in range(bufferOut.shape[0]):
            bufferOut[i] = self.activation(self.multiply(weights[i],window,bias))
        return bufferOut  

AC1 = AccelCore(l1_input,l2_input)
AC2 = AccelCore(l2_input,l3_input)
AC3 = AccelCore(l3_input,output_size)



def convertBin(value):
    if(value == 1):
        return "01"
    elif(value == -1):
        return "11"
    elif(value == 0):
        return "00"
    else:
        return "output_size"
        print("Fucked up...")

writeString = ""
file_object = open("weight.svh", 'w')
file_object.write("logic[511:0]weight_l1[1023:0]={")
for i in range(len(W1)):
    tempString = ""
    for j in range(W1[i].shape[0]):
        tempString += convertBin(W1[i][j])
    writeString += "512'b" + tempString + ","
writeString = writeString[:-1]
file_object.write(writeString)
file_object.write("};\n") 
writeString = ""
file_object.write("logic[2047:0]weight_l2[63:0]={")
for i in range(len(W2)):
    tempString = ""
    for j in range(W2[i].shape[0]):
        tempString += convertBin(W2[i][j])
    writeString += "2048'b" + tempString + ","
writeString = writeString[:-1]
file_object.write(writeString)
file_object.write("};\n") 
writeString = ""
file_object.write("logic[127:0]weight_l3[9:0]={")
for i in range(len(W3)):
    tempString = ""
    for j in range(W3[i].shape[0]):
        tempString += convertBin(W3[i][j])
    writeString += "128'b" + tempString + ","
writeString = writeString[:-1]
file_object.write(writeString)
file_object.write("};\n") 
writeString = ""
file_object.write("logic[1:0]bias_l1[1023:0]={")
for i in range(l2_input):
    tempString = convertBin(b1[0])
    writeString += "2'b" + tempString + ","
writeString = writeString[:-1]
file_object.write(writeString)
file_object.write("};\n") 
writeString = ""
file_object.write("logic[1:0]bias_l2[63:0]={")
for i in range(l3_input):
    tempString = convertBin(b2[0])
    writeString += "2'b" + tempString + ","
writeString = writeString[:-1]
file_object.write(writeString)
file_object.write("};\n") 
writeString = ""
file_object.write("logic[1:0]bias_l3[9:0]={")
for i in range(output_size):
    tempString = convertBin(b3[0])
    writeString += "2'b" + tempString + ","
writeString = writeString[:-1]
file_object.write(writeString)
file_object.write("};\n") 


file_object.close()


out = []
for i in range(window.shape[0]):
    temp_out = AC1.fillBuffer(W1,window[i].flatten(),b1)
    temp_out = AC2.fillBuffer(W2,temp_out,b2)
    out.append(AC3.fillBuffer(W3,temp_out,b3))
    if((i%100) == 0):
        print("Iteration " + str(i))


file_object = open("output.txt", 'w')
for i in range(len(out)):
    temp = ""
    for j in range(out[i].shape[0]):
        temp += str(int(out[i][j]))
    file_object.write(temp + "\n")
file_object.close()
