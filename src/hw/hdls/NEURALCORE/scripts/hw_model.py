from window_slider_unit_test import gen_window
import numpy as np

def gen_sv_weight_file(file_name, W1, W2, W3, b1, b2, b3):
    writeString = ""
    writeString += get_matrix_as_sv_array(W1, 512 , 1024, "weight_l1")
    writeString += get_matrix_as_sv_array(W2, 2048, 64  , "weight_l2")
    writeString += get_matrix_as_sv_array(W3, 128 , 10  , "weight_l3")
    writeString += get_val_as_sv_array(b1, 2 , 1024, "bias_l1")
    writeString += get_val_as_sv_array(b2, 2 , 64  , "bias_l2")
    writeString += get_val_as_sv_array(b3, 2 , 10  , "bias_l2")
    file_object = open(file_name, 'w')
    file_object.write(writeString)
    file_object.close()


def save_model():
    dump_weight(W1, "weight_l1.txt")
    dump_weight(W2, "weight_l2.txt")
    dump_weight(W3, "weight_l3.txt")

def get_matrix_as_sv_array(mat, bit_width, array_len, sv_array_name):
    sv_arry_str = ""
    # import ipdb as pdb; pdb.set_trace()
    for i in range(len(mat)):
        tempString = ""
        for j in range(mat[i].shape[0]):
            tempString = convertBin(mat[i][j]) + tempString
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
        tempString = "{0}'b".format(bit_width) + convertBin(val) + "," + tempString
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
        print("Fucked up...")

def dump_weight(weights, file_name):
    weight_str = ""
    for idx, weight in enumerate(weights):
        # import ipdb as pdb; pdb.set_trace()
        weight = [convertBin(x) for x in weight]
        weight=str(weight).replace(".", "").replace("\n","").replace("[","").replace("]","").replace("\'","").replace(", ", "")
        weight_str += "[{0}]".format(idx) + str(hex(int(weight, 2))) + "\n"
    with open(file_name, "w") as f:
        f.write(weight_str)

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
        for i in range(bufferOut.shape[0]):
            bufferOut[i] = self.activation(self.multiply(weights[i],window,bias))
        return bufferOut  
