#Libraries for math and data manipulation
import numpy as np
import copy
import math
import numpy.random as rand

#Plotting stuff
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button, RadioButtons
import seaborn
import corner
from matplotlib import rc
rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
rc('text', usetex=True) #Want to be able to use tex in the plot labels
seaborn.set_style('ticks')
seaborn.set_color_codes()

#Machine learning stuff
from sklearn.metrics import classification_report, confusion_matrix, precision_recall_fscore_support, precision_score

def observe(tseries,Ntest,nclass):
    testp = tseries[-Ntest:]
    ratios = []
    for i in range(nclass):
        n = len(testp[testp==(float(i)+1.)])
        ratios.append(float(n)/float(Ntest))
    ratios = np.array(ratios)
    pred = np.random.multinomial(1,ratios)
    pclass = np.where(pred==1)[0]
    return ratios, pclass

def signal(window, Ntrail, patients):
    pwind = []
    i = 0
    ypred = []
    yobs = []
    for obs in patients[Ntrail+1:,1]:
        r, p = observe(patients[i:Ntrail+i,1],Ntrail,2)
        if Ntrail+i+1<len(patients):
            ypred.append(p[0]+1.)
            yobs.append(obs)
        else:
            print Ntrail*(i+1), i
            break
        i += 1
        if i%window==0:
            yobs = np.array(yobs)
            ypred = np.array(ypred)
            pscore = precision_score(yobs,ypred,average='micro')
            pwind.append(pscore)
            ypred = []
            yobs = []
    return pwind

fig = plt.figure()
ax = fig.add_subplot(111)

# Adjust the subplots region to leave some space for the sliders and buttons
axis_color = 'darkblue'
fig.subplots_adjust(left=0.25, bottom=0.25)

patients = []
t = 0.
while len(patients)<5000:
    w1 = 1.0
    w2 = 0.5 + 5.*(np.sin(0.01*t))**2
    W = w1 + w2
    dt = -np.log(np.random.random_sample()) / W
    t = t + dt
    
    if np.random.random_sample() < w1 / W:
        patID = 1.
    else:
        patID = 2.
    patients.append((t,patID))
patients = np.array(patients)

# Draw the initial plot
# The 'line' variable is used for modifying the line later
w0 = 20
n0 = 5

[line] = ax.plot(signal(w0,n0,patients), linewidth=2, color='red')


# Add two sliders for tweaking the parameters

# Define an axes area and draw a slider in it
w_slider_ax  = fig.add_axes([0.25, 0.15, 0.65, 0.03])
w_slider = Slider(w_slider_ax, 'Window', 1, 100, valinit=int(w0))

# Draw another slider
N_slider_ax = fig.add_axes([0.25, 0.1, 0.65, 0.03])
N_slider = Slider(N_slider_ax, 'Ntrail', 1, 4000, valinit=int(n0))

# Define an action for modifying the line when any slider's value changes
def sliders_on_changed(val):
    #line.set_ydata(signal(w_slider.val, N_slider.val,patients))
    ax.lines[0].remove()
    data = signal(int(w_slider.val),int(N_slider.val),patients)
    [line] = ax.plot(data, linewidth=2, color='red')
    ax.set_xlim(0,len(data))
    fig.canvas.draw()
w_slider.on_changed(sliders_on_changed)
N_slider.on_changed(sliders_on_changed)

# Add a button for resetting the parameters
reset_button_ax = fig.add_axes([0.8, 0.025, 0.1, 0.04])
reset_button = Button(reset_button_ax, 'Reset', color=axis_color, hovercolor='0.975')
def reset_button_on_clicked(mouse_event):
    w_slider.reset()
    N_slider.reset()
reset_button.on_clicked(reset_button_on_clicked)

# Add a set of radio buttons for changing color
color_radios_ax = fig.add_axes([0.025, 0.5, 0.15, 0.15])
color_radios = RadioButtons(color_radios_ax, ('red', 'blue', 'green'), active=0)
def color_radios_on_clicked(label):
    line.set_color(label)
    fig.canvas.draw()
color_radios.on_clicked(color_radios_on_clicked)

plt.show()

