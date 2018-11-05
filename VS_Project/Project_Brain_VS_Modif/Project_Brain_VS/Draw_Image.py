import matplotlib.pyplot as plt
from matplotlib import colors
import numpy as np
import csv

# 60 x 200 image
data = np.zeros((60,200))
i = 0
j = 0


with open("image.csv", 'r') as f:
    reader = csv.reader(f)
    for row in reader:
        j = 0
        for column in row:
            try:
                data[i,j] = float(column)
            except:
                pass
            j = j + 1
        i = i + 1

cmap = colors.ListedColormap(['red', 'blue', 'red','cyan', 'magenta', 'yellow','black','white'])
bounds = [0,10,20,30,60,100,150,200,220]
norm = colors.BoundaryNorm(bounds, cmap.N)
fig, ax = plt.subplots()
ax.imshow(data, cmap=cmap, norm=norm)


plt.show()


"""
data = np.random.rand(10, 10) * 20

# create discrete colormap
cmap = colors.ListedColormap(['red', 'blue'])
bounds = [0,20,40,60,80,100,150,200,230]
norm = colors.BoundaryNorm(bounds, cmap.N)

fig, ax = plt.subplots()
ax.imshow(data, cmap=cmap, norm=norm)

# draw gridlines
ax.grid(which='major', axis='both', linestyle='-', color='k', linewidth=2)
ax.set_xticks(np.arange(-.5, 10, 1));
ax.set_yticks(np.arange(-.5, 10, 1));

plt.show()

"""
