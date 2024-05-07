---
date:  2024-05-28
title: Simulated Sine-Wave Analysis
---

This is based on the scripts from [Introduction to Digital Filters](https://ccrma.stanford.edu/~jos/filters/).

Let's figure out the frequency response of the *simplest lowpass filter*:

$$
y(n) = x(n) + x(n-1),\quad n=1,2,...,N
$$

We do this using *simulated sine-wave analysis*. This approach complements the analytical approach from the book.

<!--more-->

First thing we need is the `swanal` function:


```python
import numpy as np
from scipy.signal import lfilter

import matplotlib.pyplot as plt

def mod2pi(x):
    y = x
    while y >= np.pi:
        y = y - np.pi * 2
    while y < -1*np.pi:
        y = y + np.pi * 2

    return y

def swanal(t,f,B,A):
    '''Perform sine-wave analysis on filter B(z)/A/(z)'''
    ampin = 1    # input signal amplitude
    phasein = 0  # input signal phase

    N = len(f) # Number of test frequencies
    gains = np.zeros(N)
    phases = np.zeros(N)

    if len(A) == 1:
        ntransient = len(B)-1
    else:
        error('Need to set transient response duration here')
  
    for k in np.arange(0,len(f)):
        s = ampin*np.cos(2*np.pi*f[k]*t+phasein)
        y = lfilter(B,A,s)
        yss = y[ntransient+0:len(y)]
        ampout = np.max(np.abs(yss))
        peakloc = np.argmax(np.abs(yss))
        gains[k] = ampout/ampin
        if ampout < np.finfo(float).eps:
            phaseout = 0
        else:
            # `peakloc` is an index. Matlab uses 1-based indexing whereas 
            # Python uses 0-based indexing. 
            sphase = 2 * np.pi * f[k] * ((peakloc+1)+ntransient-1)
            phaseout = np.arccos(yss[peakloc]/ampout) - sphase
            phaseout = mod2pi(phaseout)

        phases[k] = phaseout - phasein

        fig1,ax1 = plt.subplots()
        title1 = f"Filter Input Sinusoid f({k})={f[k]}"
        ax1.set_title(title1)
        ax1.set_xlabel("Time (sec)")
        ax1.set_ylabel("Amplitude")
        ax1.plot(t,s,'*k')
        tinterp = np.linspace(0,t[-1],num=200)
        si = ampin*np.cos(2*np.pi*f[k]*tinterp+phasein)
        ax1.plot(tinterp,si,'-k')
        fig1.set_figwidth(15)

        fig2,ax2 = plt.subplots()
        title2 = f"Filter Output Sinusoid f({k})={f[k]}"
        ax2.set_title(title2)
        ax2.set_xlabel("Time (sec)")
        ax2.set_ylabel("Amplitude")
        ax2.plot(t,y,'*k')
        fig2.set_figwidth(15)
    return gains,phases
```

Now let's actually use the `swanal` function:


```python
B = [1,1]
A = [1]

N = 10
fs = 1

fmax = fs/2
df = fmax/(N-1)

f = np.zeros(10)
for i in range(10):
    f[i] = i*df
dt = 1/fs
tmax = 10
t = np.arange(0,tmax+1,dt)
ampin = 1
phasein = 0

gains, phases = swanal(t, f/fs, B, A)
```


    
![png]((/output_3_0.png)
    



    
![png](/output_3_1.png)
    



    
![png](/output_3_2.png)
    



    
![png](/output_3_3.png)
    



    
![png](/output_3_4.png)
    



    
![png](/output_3_5.png)
    



    
![png](/output_3_6.png)
    



    
![png](/output_3_7.png)
    



    
![png](/output_3_8.png)
    



    
![png](/output_3_9.png)
    



    
![png](/output_3_10.png)
    



    
![png](/output_3_11.png)
    



    
![png](/output_3_12.png)
    



    
![png](/output_3_13.png)
    



    
![png](/output_3_14.png)
    



    
![png](/output_3_15.png)
    



    
![png](/output_3_16.png)
    



    
![png](/output_3_17.png)
    



    
![png](/output_3_18.png)
    



    
![png](/output_3_19.png)
    


Now let's plot these:


```python
import matplotlib.pyplot as plt
%matplotlib inline

def freqplot(fdata, ydata, symbol, title, xlab='Frequency', ylab='', fig=None, ax=None):
    if not fig or not ax:
        fig, ax = plt.subplots()
    ax.set_xlabel(xlab)
    ax.set_ylabel(ylab)
    ax.set_title(title)
    ax.grid()
    ax.plot(fdata,ydata,symbol)
    return fig, ax


title1 = 'Amplitude Response'
fig1, ax1 = freqplot(f, gains, '*k', title1,'Frequency (Hz)', 'Gain')
tar = 2 * np.cos(np.pi*f/fs) # Theoretical amplitude response
fig1, ax1 = freqplot(f, tar, '-c', title1,'Frequency (Hz)', 'Gain', fig1, ax1)
ax1.grid()
fig1.set_figwidth(15)


title2 = 'Phase Response'
tpr = -np.pi * f / fs # Theoretical Phase Response
pscl = 1/(2*np.pi) # Convert radian phase shift to cycles
fig2, ax2 = freqplot(f, tpr*pscl, '-c', title2, 'Frequency (Cycles)', 'Phase Shift (cycles)')
fig2, ax2 = freqplot(f, phases*pscl, '*k', title2, 'Frequency (Cycles)', 'Phase Shift (cycles)', fig2, ax2)
ax2.grid()
fig2.set_figwidth(15)
```



![png](/output_5_0.png)





![png](/output_5_1.png)



This corresponds to the graphs on the page, so yay, success! 🍾🥂

Now let's dig deeper into what is going on here exactly.

Test sinusoids are generated with

```python
s = ampin * cos(2*np.pi*f[k]*t+phasein)
```

with:
 - `ampin`: the amplitude
 - `f[k]`: the frequency (in Hz)
 - `phasein`: the phase (in radians)

The amplitude can initially be set to 1 and the phase to 0 and if the system behaves itself (i.e. it is linear and time-invariant) then these parameters don't matter.

```python
        y = lfilter(B,A,s)
```
applies the filter to the test sinusoid `s`. The coefficients in this case are:

```python
B = [1,1]
A = [1]
```

AFAICT this is a FIR filter given that the denominator is equal to 1.

It's best to read the book, but here is a quick summary of what this code does.

There's 10 input sinusoids that are generated and passed through the filter. The output amplitude and phase are then estimated.

The amplitude is estimated by doing

```python
np.max(np.abs(yss))
```

This is only a rough estimation because the actual maximum is most likely located between the samples. Some interpolation would most likely solve this issue.

The phase on the other hand is estimated with the following code:

```python
# `peakloc` is an index. Matlab uses 1-based indexing whereas 
            # Python uses 0-based indexing. 
            sphase = 2 * np.pi * f[k] * ((peakloc+1)+ntransient-1)
            phaseout = np.arccos(yss[peakloc]/ampout) - sphase
            phaseout = mod2pi(phaseout)
```

sphase is the phase of the sample at the peak location in the input signal.
Phaseout is then determined by finding the phase angle of the sample at the peak
location in the output signal and subtracting the phase from the input to get
the phase shift. `mod2pi(phaseout)` scales that value to the range $$ [-\pi;\pi[ $$

Once again there's a pretty good 1-1 mapping of what Matlab/Octave provides and
what Numpy/Scipy provides. One of the main sources of bugs has been the
difference between 1-indexed arrays in Matlab compared to 0-indexed arrays in
Python.
