import sys
import utility as util
from window_slider_unit_test import gen_window
import numpy as np
np.set_printoptions(threshold=np.nan)

def get_hex_format(array, ternary=False):
    if ternary:
        array = [convertBin(el) for el in array]
        array = str(array).replace('[', '').replace(']', '').replace('.', '').replace('\n', '').replace(' ', '').replace("'", "").replace(",","")
    else:
        array = str(array).replace('[', '').replace(']', '').replace('.', '').replace('\n', '').replace(' ', '')
    print(array)
    return hex(int(array,2))

def gen_random_params(input_file_name, image_h, image_w, w_width, w_height, stride, l1_input, l2_input, l3_input, output_size):
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

def load_params(img_npy, w1_npy, w2_npy, w3_npy, b1_npy, b2_npy, b3_npy, w_width, w_height, stride):
    # import ipdb as pdb; pdb.set_trace()
    util.print_log("loading {0}...".format(img_npy))
    image = np.load(img_npy)
    windows = (gen_window(image, w_width, w_height, stride))
    util.print_log("loading {0}...".format(w1_npy))
    w1 = np.load(w1_npy)
    util.print_log("loading {0}...".format(w2_npy))
    w2 = np.load(w2_npy)
    util.print_log("loading {0}...".format(w3_npy))
    w3 = np.load(w3_npy)
    util.print_log("loading {0}...".format(b1_npy))
    b1 = np.load(b1_npy)
    util.print_log("loading {0}...".format(b2_npy))
    b2 = np.load(b2_npy)
    util.print_log("loading {0}...".format(b3_npy))
    b3 = np.load(b3_npy)
    return windows, w1, w2, w3, b1, b2, b3

def gen_sv_weight_file(file_name, W1, W2, W3, b1, b2, b3):
    writeString = ""
    writeString += get_matrix_as_sv_array(W1, 512 , 1024, "weight_l1")
    writeString += get_matrix_as_sv_array(W2, 2048, 64  , "weight_l2")
    writeString += get_matrix_as_sv_array(W3, 128 , 10  , "weight_l3")
    writeString += get_val_as_sv_array(b1, 2 , 1024, "bias_l1")
    writeString += get_val_as_sv_array(b2, 2 , 64  , "bias_l2")
    writeString += get_val_as_sv_array(b3, 2 , 10  , "bias_l3")
    file_object = open(file_name, 'w')
    file_object.write(writeString)
    file_object.close()


def get_matrix_as_sv_array(mat, bit_width, array_len, sv_array_name):
    sv_arry_str = ""
    # import ipdb as pdb; pdb.set_trace()
    for i in range(len(mat)):
        tempString = ""
        for j in range(mat[i].shape[0]):
            tempString += convertBin(mat[i][j])
        sv_arry_str = "{0}'b".format(bit_width) + tempString + "," + sv_arry_str
    # import ipdb as pdb; pdb.set_trace()
    sv_arry_str = sv_arry_str[:-1]
    sv_arry_str = "{" + sv_arry_str
    sv_arry_str = "logic[{0}:0]{1}[{2}:0]={3}".format(bit_width-1, sv_array_name, array_len-1, sv_arry_str)
    sv_arry_str += "};\n" 
    return sv_arry_str

def get_val_as_sv_array(val, bit_width, array_len, sv_array_name):
    # import ipdb as pdb; pdb.set_trace()
    sv_arry_str = "logic[{0}:0]{1}[{2}:0]=".format(bit_width-1, sv_array_name, array_len-1)
    tempString = ""
    for i in range(0, array_len):
        tempString += "{0}'b".format(bit_width) + convertBin(val) + ","
    tempString  = tempString[:-1]
    sv_arry_str+= "{" + tempString + "};\n" 
    return sv_arry_str

def convertBin(value):
    if(value == 1):
        return "01"
    elif(value == -1):
        return "11"
    elif(value == 0):
        return "00"
    else:
        return "output_size"
        util.print_log("only ternary weights of -1, 0 and 1 is supported", id_str="ERROR")
        sys.exit()

def dump_weight(weights, file_name):
    weight_str = ""
    for idx, weight in enumerate(weights):
        # import ipdb as pdb; pdb.set_trace()
        weight = [convertBin(x) for x in weight]
        weight=str(weight).replace(".", "").replace("\n","").replace("[","").replace("]","").replace("\'","").replace(", ", "")
        weight_str += "[{0}]".format(idx) + str(hex(int(weight, 2))) + "\n"
    with open(file_name, "w") as f:
        f.write(weight_str)

def save_model(W1, W2, W3):
    dump_weight(W1, "weight_l1.txt")
    dump_weight(W2, "weight_l2.txt")
    dump_weight(W3, "weight_l3.txt")

""" Generate weights """
def generate_weights(size, type='ternary'):
    weight = np.random.normal(0, 1.0, (size))
    for i in range(weight.shape[0]):
        if type.lower() == "binary":
            if(weight[i]>0):
                weight[i] = 1
            else:
                weight[i] = 0
        else:
            if(weight[i]>0.5):
                weight[i] = 1
            elif(weight[i]<-0.5):
                weight[i] = -1
            else:
                weight[i] = 0
    return weight

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
    
    def forward(self, weights, window, bias):
        bufferOut = np.zeros(self.output_size_)
        # import ipdb as pdb; pdb.set_trace() 
        for i in range(bufferOut.shape[0]):
            bufferOut[i] = self.activation(self.multiply(weights[i],window,bias))
        # import ipdb as pdb; pdb.set_trace() 
        return bufferOut  
