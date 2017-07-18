# python oximeter_surface_mapping.py data/2016_4_1/1_6_2_full.txt

import os
import io
import shutil

#os.system('cd C:\Users\tasif\Dropbox\project_reflection_oximeter\mapping\processing\pulse_ox_mapping')
#os.system('dir')

import numpy as np
import matplotlib.pyplot as plt
import sys
import matplotlib
import matplotlib.mlab as ml
from matplotlib.colors import LogNorm
from matplotlib.ticker import LogFormatterMathtext
import Tkinter, tkFileDialog
from collections import Counter
import scipy.ndimage as ndimage


# In[3]:

#fname = "data/2016_4_1/1_6_2_full.txt" #tkFileDialog.askopenfilename()
fname = sys.argv[1]
DPF_1 = float(sys.argv[2])
DPF_2 = float(sys.argv[3])
d = float(sys.argv[4])
fname_blank1 = str(fname).replace(".txt", "")
fname_blank2 = fname_blank1.replace(".csv", "")

data = np.genfromtxt(fname, delimiter=',', skip_header=0,dtype=np.object)

time = data[:,0]; 
time = np.array([float(x) for x in time])

pixelID = data[:,1]; 
pixelID = np.array([float(x) for x in pixelID])

red = data[:,2]; 
red = np.array([float(x) for x in red])

redAmb = data[:,3]; 
redAmb = np.array([float(x) for x in redAmb])

ired = data[:,4]; 
ired = np.array([float(x) for x in ired])

iredAmb = data[:,5]; 
iredAmb = np.array([float(x) for x in iredAmb])




# In[5]:




for j in range (0,9):
    exec 'redPixel_%s = []' %(j) 
    exec 'iredPixel_%s = []' %(j)
    exec 'spo2Pixel_%s = []' %(j)

for i in range(0,len(pixelID)):
    for j in range (0,9):
        #print j
        if (pixelID[i] == j):
            #print j
            #print red[i]
            exec 'redPixel_%s.append(red[%s])' %(j,i)
            exec 'iredPixel_%s.append(ired[%s])' %(j,i)

            
# fix font Arial, 18, legend font 14
font = {'family' : 'normal',
        'weight' : 'normal',
        'size'   : 24}

matplotlib.rc('font', **font)
title_font = {'fontname':'Arial', 'size':'24', 'color':'black', 'weight':'normal',
              'verticalalignment':'bottom'} # Bottom vertical alignment for more space
axis_font = {'fontname':'Arial', 'size':'24'}


ny, nx = 100, 100
xmin, xmax = 0, 2
ymin, ymax = 0, 2
xi = np.linspace(xmin, xmax, nx)
yi = np.linspace(ymin, ymax, ny)

x = np.array([0.0, 1.0, 2.0, 0.0, 1.0, 2.0, 0.0, 1.0, 2.0])# 5 5.0,
y = np.array([2.0, 2.0, 2.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0])# 5.0,
red_z = np.array([np.mean(redPixel_0), np.mean(redPixel_1), np.mean(redPixel_2), np.mean(redPixel_3),               np.mean(redPixel_4), np.mean(redPixel_5), np.mean(redPixel_6), np.mean(redPixel_7), np.mean(redPixel_8)])
ired_z = np.array([np.mean(iredPixel_0), np.mean(iredPixel_1), np.mean(iredPixel_2), np.mean(iredPixel_3),               np.mean(iredPixel_4), np.mean(iredPixel_5), np.mean(iredPixel_6), np.mean(iredPixel_7), np.mean(iredPixel_8)])

z_red = ml.griddata(x, y, red_z, xi, yi,interp='linear')#,interp='linear'
z_ired = ml.griddata(x, y, ired_z, xi, yi,interp='linear')#,interp='linear'

fig = plt.figure()
plt.contour(xi, yi, z_red, 20, linewidths = 0.5, colors = 'k')
plt.hold(True)
im = plt.pcolormesh(xi, yi, z_red, cmap = plt.get_cmap('rainbow'))
plt.colorbar(im, orientation='vertical') 
    
plt.scatter(x, y, marker = 'o', c = 'b', s = 5, zorder = 10)
plt.xlim(xmin, xmax)
plt.ylim(ymin, ymax)
    
plt.xlabel(r"$x$",fontsize=24)
plt.ylabel(r"$y$",fontsize=24)
    
    
    #print name_str
#plt.title('Reflected Intensity - Red', fontsize=16)
#plt.show()
fig.savefig(str(fname_blank2)+'_red.png', dpi=300, facecolor='w', edgecolor='w',
            orientation='portrait', papertype=None, format=None,
            transparent=False, bbox_inches=None, pad_inches=0.1,
            frameon=None)

## ir
fig = plt.figure()
plt.contour(xi, yi, z_ired, 20, linewidths = 0.5, colors = 'k')
plt.hold(True)

im = plt.pcolormesh(xi, yi, z_ired, cmap = plt.get_cmap('rainbow'))
plt.colorbar(im, orientation='vertical') 
    
plt.scatter(x, y, marker = 'o', c = 'b', s = 5, zorder = 10)
plt.xlim(xmin, xmax)
plt.ylim(ymin, ymax)
    
plt.xlabel(r"$x$",fontsize=24)
plt.ylabel(r"$y$",fontsize=24)
    
    
    #print name_str
#plt.title('Reflected Intensity - Infrared', fontsize=16)
#plt.show()
fig.savefig(str(fname_blank2)+'_ired.png', dpi=300, facecolor='w', edgecolor='w',
            orientation='portrait', papertype=None, format=None,
            transparent=False, bbox_inches=None, pad_inches=0.1,
            frameon=None)


# In[10]:

# calculating c_hbo2 and c_hb

alpha_hb02_660 = 319.6 #cm-1/M
alpha_hb_660 = 3226.56

alpha_hb02_940 = 1214
alpha_hb_940 = 693.44

alpha_hb02_515 = 20429.2
alpha_hb_515 = 28100

alpha_hb02_720 = 348
alpha_hb_720 = 1325.88

alpha_hb02_630 = 610
alpha_hb_630 = 5148.8

# red
I_1 = red_z
I0_1 = 1.2
d_1 = d # cm
#DPF_1 = 7 # han = 7, yasser = 3.35, ting = 7

# ired
I_2 = ired_z
I0_2 = 1.2
d_2 = d # cm
#DPF_2 = 14.5 # han = 19, yasser 14.5, ting = 20

a = np.array([[alpha_hb02_630,alpha_hb_630], [alpha_hb02_940,alpha_hb_940]])
b = np.array([-((np.log(I_1/I0_1))/(d_1*DPF_1)),-((np.log(I_2/I0_2))/(d_2*DPF_2))])
c = np.linalg.solve(a, b)

c_hbo2 = c[0,:]*1000
c_hb = c[1,:]*1000
so2 = 100*c_hbo2 / (c_hb + c_hbo2)

## plot 
z_so2 = ml.griddata(x, y, so2, xi, yi,interp='linear')#,interp='linear'

fig = plt.figure()
plt.contour(xi, yi, z_so2, 20, linewidths = 0.5, colors = 'k')
plt.hold(True)

im = plt.pcolormesh(xi, yi, z_so2, cmap = plt.get_cmap('rainbow_r'))
plt.colorbar(im, orientation='vertical') 
    
plt.scatter(x, y, marker = 'o', c = 'b', s = 5, zorder = 10)
plt.xlim(xmin, xmax)
plt.ylim(ymin, ymax)
    
plt.xlabel(r"$x$",fontsize=24)
plt.ylabel(r"$y$",fontsize=24)
    
    
    #print name_str
#plt.title('Oxygen Saturation', fontsize=16)
#plt.show()
fig.savefig(str(fname_blank2)+'_so2.png', dpi=300, facecolor='w', edgecolor='w',
            orientation='portrait', papertype=None, format=None,
            transparent=False, bbox_inches=None, pad_inches=0.1,
            frameon=None)


# In[8]:

so2

