---
date: 2025-12-25
title: Envelope Filter Model in Python
---

One of my goals is to code up an Envelope Filter DSP effect for bass guitar. I've been reading Audio Effects by Reiss & Andrew P. McPherson and I've gotten to the description of a wah effect with the filter controlled by an envelope follower in chapter 4. That should be enough to get a prototype implementation started in Python.

I'll need a few things:
1. A resonant low-pass filter
2. An envelope follower.

I'll do those in order.

# Resonant Low-Pass filter

I need a filter that has a nice big resonance at the cutoff frequency. I think it would also be beneficial to not have too much (or any) ripple in the passband of the filter. Let's have a look at the scipy toolbox.

If you look at the different types of filters available then a butterworth filter seems like it would be a good choice to start from given that it does not have any ripple in the passband. We'll have to introduce the resonance some way though.

Let's first get our imports out of the way:


```python
from scipy import signal
import matplotlib.pyplot as plt
import numpy as np
```

Now let's start designing a filter:


```python
%matplotlib ipympl

cutoff = 100 
b, a = signal.butter(2, cutoff, 'low', analog=True)
w, h = signal.freqs(b, a)
plt.semilogx(w, 20 * np.log10(abs(h)))
plt.title('Butterworth filter frequency response')
plt.xlabel('Frequency [rad/s]')
plt.ylabel('Amplitude [dB]')
plt.margins(0, 0.1)
plt.grid(which='both', axis='both')
plt.axvline(cutoff, color='green')
```


![Butterworth Filter Frequency Response](/envelope-filter/output_4_1.png)




The filter design toolbox in Scipy seeminly does not support my use case of designing a resonant filter. I need some kind of biquad IIR filter where I have more control over the design. There seems to be a project on Pypi which does this: [python-biquad](https://github.com/jurihock/biquad). Alternatively I can do my own implementation using the [audio equalizer coockbock formulae](https://webaudio.github.io/Audio-EQ-Cookbook/audio-eq-cookbook.html) by Robert Bristow-Johnson.
A low-pass filter with controls is given by:

$$
H(s) = \frac{1}{s^{2}+\frac{s}{Q}+1}
$$
$$
b_{0} = \frac{1 - cos(\omega_{0})}{2}
$$
$$
b_{1} = 1 - cos(\omega_{0})
$$
$$
b_{2} = \frac{1 - cos(\omega_{0})}{2}
$$
$$
a_{0} = 1 + \alpha
$$
$$
a_{1} = -2cos(\omega_{0})
$$
$$
a_{2} = 1 - \alpha
$$

With the parameters:

$$
\omega_{0} = 2 \pi \frac{f_{0}}{F_{s}}
$$

the angular frequency and

$$
\alpha = \frac{sin(\omega_{0})}{2Q}
$$




```python

cutoff = 100
Fs = 48000
w0 = 2 * np.pi * cutoff/Fs

Q = 10
alpha = np.sin(w0)/(2*Q)


b0 = (1 - np.cos(w0))/2
b1 = 1 - np.cos(w0)
b2 = b0

a0 = 1 + alpha
a1 = -2 * np.cos(w0)
a2 = 1 - alpha

num = [b0, b1, b2]
den = [a0, a1, a2]

w, h = signal.freqz(num, den, fs=Fs)

fig1, ax1 = plt.subplots()
ax1.set_title(f"Wah filter frequency response")
ax1.axvline(cutoff, color='black', linestyle=':')
ax1.semilogx(w, 20 * np.log10(abs(h)), 'C0')
```


![Wah Filter Frequency Response](/envelope-filter/output_6_1.png)


That looks like a resonant low pass filter. For the range I'm basing myself on the Dunlop Crybaby Bass Wah pedal, which ranges between 180Hz cutoff at heel down and 1800Hz at toe down. Let's plot those two extremes:


```python

def resonant_lpf(cutoff,Q,Fs=48000):
    
    w0 = 2 * np.pi * cutoff/Fs
    alpha = np.sin(w0)/(2*Q)


    b0 = (1 - np.cos(w0))/2
    b1 = 1 - np.cos(w0)
    b2 = b0

    a0 = 1 + alpha
    a1 = -2 * np.cos(w0)
    a2 = 1 - alpha

    num = [b0, b1, b2]
    den = [a0, a1, a2]

    return {'cutoff':cutoff,'num':num,'den':den}

Q=8
heel_down = resonant_lpf(180, Q)
toe_down = resonant_lpf(1800, Q)

w_heel, h_heel = signal.freqz(heel_down['num'], heel_down['den'], fs=Fs)
w_toe, h_toe = signal.freqz(toe_down['num'], toe_down['den'], fs=Fs)


fig1, ax1 = plt.subplots()
ax1.set_title(f"Wah filter frequency response")
ax1.axvline(heel_down['cutoff'], color='C0', linestyle=':')
ax1.semilogx(w_heel, 20 * np.log10(abs(h_heel)), 'C0', label="heel down")
ax1.axvline(toe_down['cutoff'], color='C1', linestyle=':')
ax1.semilogx(w_toe, 20 * np.log10(abs(h_toe)), 'C1', label="toe down")
ax1.legend()
ax1.set_ylabel("Amplitude [dB]")
ax1.set_xlabel("Frequency [Hz]")
```

![Wah Filter Frequency Response Range](/envelope-filter/output_8_1.png)


This seems like we can get started with this range to prototype the wah part. This is the filter part of the envelope filter. Now let's get the envelope part going.

# Envelope Follower

The next part of the system is a level detector. This detector generates the envelope that we use to trigger the shifting of the center frequency.

$$
y_{l}[n] = 
\begin{cases}
\alpha_{A}y_{L}[n-1]+(1-\alpha_{A})x_{L}[n] & x_{L}[n] > y_{L}[n-1] \\
\alpha_{R}y_{L}[n-1]+(1-\alpha_{R})x_{L}[n] & x_{L}[n] \leq y_{L}[n-1]
\end{cases}
$$

with

$$
\alpha_{A} = e^{-1/(\tau_{A}f_{s})}
$$
$$
\alpha_{R} = e^{-1/(\tau_{R}f_{s})}
$$

Where $\tau_{A}$ is the *attack time* and $\tau_{R}$ is the *release time*.

Let's implement this and test it on a short sample recording.


```python
from scipy.io import wavfile

import warnings
warnings.filterwarnings("ignore")

samplerate, data = wavfile.read("bass-sample.wav")
length = data.shape[0] / samplerate

def level_detector(samples, fs=44100, t_attack=1, t_release=1):
    alpha_A = np.exp(-1/(t_attack * fs))
    alpha_R = np.exp(-1/(t_release * fs))
    
    level = np.zeros(len(samples))
    output = 0
    for i in range(len(samples)):
        sample = np.abs(samples[i])
        if sample > output:
            level[i] = alpha_A*output + (1-alpha_A)*sample
        else:
            level[i] = alpha_R*output + (1-alpha_R)*sample

        output = level[i]

    return level


envelope = level_detector(data[:,0],t_attack=0.005,t_release=0.200)

time = np.linspace(0., length, data.shape[0])

fig2, ax2 = plt.subplots()
ax2.set_title("Signal Detector Envelope")
ax2.plot(time, data[:, 0], label="Left channel")
ax2.plot(time, envelope, 'o', label="envelope")
ax2.legend()
ax2.set_ylabel("Amplitude")
ax2.set_xlabel("Time [s]");
```


![Signal Detector Envelope](/envelope-filter/output_10_0.png)



This looks good, however there are some small oscillations which might pose a problem. I'll ignore those for now but it might be necessary to add some low pass filtering. In the case that it's necessary I guess a rolling average filter will be the easiest solution to this problem.

# Applying the filters

Now that I have my two filters and an envelope signal I can start actually manipulating some samples. Let's first listen to what the dry bass guitar sound is like:


```python
from IPython.display  import Audio
Audio(data.T, rate=samplerate)
```


<audio controls src="/envelope-filter/dry_bass.mp3"></audio>


Now let's filter it with the heel down filter


```python
from scipy.signal import lfilter

heel_down_signal = lfilter(heel_down["num"], heel_down["den"], data)
Audio(heel_down_signal.T, rate=samplerate)
```


<audio controls src="/envelope-filter/resonant_lowpass_heel_down.mp3"></audio>


```python
toe_down_signal = lfilter(toe_down["num"], toe_down["den"], data)
Audio(toe_down_signal.T, rate=samplerate)
```


<audio controls src="/envelope-filter/resonant_lowpass_toe_down.mp3"></audio>

```python
specgram1, (raw_spec, heel_spec, toe_spec) = plt.subplots(nrows=3)
raw_spec.specgram(data.T[0],Fs=samplerate, NFFT=1024);
heel_spec.specgram(heel_down_signal.T[0],Fs=samplerate, NFFT=1024);
toe_spec.specgram(toe_down_signal.T[0],Fs=samplerate, NFFT=1024);
```

![Resonant Low Pass Filter Spectrograms](/envelope-filter/output_18_0.png)


This doesn't really seem to do the trick. At this point my suspicion is that this is because the peak is not high and narrow enough. Let's redesign the filter with some different types.

# PeakingEQ Filter

<div class="alert alert-block alert-warning">
    
This experiment with the PeakingEQ filter is me fundamentally misunderstanding what it does.
    
I'm leaving it in here because it might be interesting for the reader to see where I went wrong.

For actual results skip to the [Band-pass Filter](#Band-Pass-Filter) section.

</div>

Let's try a peaking EQ filter which should sound quite a bit more pronounced.

The PeakingEQ filter as given by the formula:

$$
H(s) = \frac{}{s^{2}+\frac{s}{AQ}+1}
$$

$$
b_{0} = 1 + \alpha A
$$

$$
b_{1} = -2cos\omega_{0}
$$

$$
b_{2} =  1 - \alpha A
$$

$$
a_{0} = 1 + \frac{\alpha}{A}
$$

$$
a_{1} = -2cos\omega_{0}
$$

$$
a_{2} = 1 - \frac{\alpha}{A}
$$

Using the same definitions of $\alpha$ and $\omega_{0}$ as before.


```python
def peakingEQ(cutoff,Q,dBgain,Fs=44100):
    
    w0 = 2 * np.pi * cutoff/Fs
    alpha = np.sin(w0)/(2*Q)

    A = 10**(dBgain/40)

    b0 = 1 + alpha*A
    b1 = -2*np.cos(w0)
    b2 = 1 - alpha*A

    a0 = 1 + alpha/A
    a1 = b1
    a2 = 1 - alpha/A

    num = [b0, b1, b2]
    den = [a0, a1, a2]

    return {'cutoff':cutoff,'num':num,'den':den}

Q=8
dBgain = 12
peaking_heel_down = peakingEQ(180, Q, dBgain)
peaking_toe_down = peakingEQ(1800, Q, dBgain)

w_peaking_heel, h_peaking_heel = signal.freqz(peaking_heel_down['num'], peaking_heel_down['den'], fs=44100)
w_peaking_toe, h_peaking_toe = signal.freqz(peaking_toe_down['num'], peaking_toe_down['den'], fs=44100)

fig3, ax3 = plt.subplots()
ax3.set_title(f"PeakingEQ Wah filter frequency response")
ax3.axvline(peaking_heel_down['cutoff'], color='C0', linestyle=':')
ax3.semilogx(w_peaking_heel, 20 * np.log10(abs(h_peaking_heel)), 'C0', label="heel down")
ax3.axvline(peaking_toe_down['cutoff'], color='C1', linestyle=':')
ax3.semilogx(w_peaking_toe, 20 * np.log10(abs(h_peaking_toe)), 'C1', label="toe down")
ax3.legend()
ax3.set_ylabel("Amplitude [dB]")
ax3.set_xlabel("Frequency [Hz]");
```



![PeakingEQ Wah Filter Frequency Response](/envelope-filter/output_21_0.png)


Let's apply these filters to our sound sample


```python
from scipy.signal import filtfilt
peaking_heel_down_signal = filtfilt(peaking_heel_down["num"], peaking_heel_down["den"], data.T[-1])
Audio(peaking_heel_down_signal.T, rate=samplerate)
```


<audio  controls="controls" src="/envelope-filter/peakingEQ_heel_down.mp3"></audio>


```python
peaking_toe_down_signal = filtfilt(peaking_toe_down["num"], peaking_toe_down["den"], data.T[-1])
Audio(peaking_toe_down_signal.T, rate=samplerate)
```

<audio  controls="controls" src="/envelope-filter/peakingEQ_toe_down.mp3"></audio>

```python
specgram2, (raw_peaking_spec, heel_peaking_spec, toe_peaking_spec) = plt.subplots(nrows=3)
raw_peaking_spec.specgram(data.T[-1],Fs=samplerate, NFFT=1024);
heel_peaking_spec.specgram(peaking_heel_down_signal,Fs=samplerate, NFFT=1024);
toe_peaking_spec.specgram(peaking_toe_down_signal,Fs=samplerate, NFFT=1024);
```


![PeakingEQ Spectrograms](/envelope-filter/PeakingEQ_spectrograms.png)

# Band-Pass Filter

I made a mistake selecting the peakingEQ filter. This filter only boosts certain frequencies and doesn't actually filter them i.e. the bottom of the frequency is at 0dB, where we need to have negative gain everywhere except for the passband. This means that I need to implement a band pass filter (BPF) instead. There's 2 types in the cookbook: one with constant skirt gain and one with constant 0dB peak gain. We only want the wah to filter, not add any additional gain. Hence we use the constant 0dB peak gain BPF.

$$
H(s) = \frac{\frac{s}{Q}}{s^{2}+\frac{s}{Q}+1}
$$

$$
b_{0} = \alpha
$$

$$
b_{1} = 0
$$

$$
b_{2} =  -\alpha
$$

$$
a_{0} = 1 + \alpha
$$

$$
a_{1} = -2cos\omega_{0}
$$

$$
a_{2} = 1 - \alpha
$$

Using the same definitions of $\alpha$ and $\omega_{0}$ as before.


```python
def bandpassfilter(cutoff, Q, Fs=44100):

    w0 = 2 * np.pi * cutoff/Fs
    alpha = np.sin(w0)/(2*Q)

    b0 = alpha
    b1 = 0
    b2 = -1 * alpha

    a0 = 1 + alpha
    a1 = -2*np.cos(w0)
    a2 = 1 - alpha

    num = [b0, b1, b2]
    den = [a0, a1, a2]

    return {'cutoff': cutoff, 'num': num, 'den': den}


Q = 8
bandpass_heel_down = bandpassfilter(180, Q)
bandpass_toe_down = bandpassfilter(1800, Q)

w_bandpass_heel, h_bandpass_heel = signal.freqz(bandpass_heel_down['num'],
                                                bandpass_heel_down['den'],
                                                fs=44100)
w_bandpass_toe, h_bandpass_toe = signal.freqz(bandpass_toe_down['num'],
                                              bandpass_toe_down['den'],
                                              fs=44100)

fig4, ax4 = plt.subplots()
ax4.set_title("Bandpass Wah filter frequency response")

ax4.axvline(bandpass_heel_down['cutoff'], color='C0', linestyle=':')
ax4.semilogx(w_bandpass_heel,
             20 * np.log10(abs(h_bandpass_heel)),
             'C0',
             label="heel down")

ax4.axvline(bandpass_toe_down['cutoff'], color='C1', linestyle=':')
ax4.semilogx(w_bandpass_toe,
             20 * np.log10(abs(h_bandpass_toe)),
             'C1',
             label="toe down")

ax4.legend()
ax4.set_ylabel("Amplitude [dB]")
ax4.set_xlabel("Frequency [Hz]");

```


![Bandpass Wah Filter Frequency Response](bandpass_wah_filter_freq_resp.png)


```python
bandpass_heel_down_signal = filtfilt(bandpass_heel_down["num"],
                                     bandpass_heel_down["den"],
                                     data.T[-1])
Audio(bandpass_heel_down_signal.T, rate=samplerate)
```

<audio  controls="controls" src="/envelope-filter/bandpass_heel_down.mp3"></audio>

```python
bandpass_toe_down_signal = filtfilt(bandpass_toe_down["num"],
                                     bandpass_toe_down["den"],
                                     data.T[-1])
Audio(bandpass_toe_down_signal.T, rate=samplerate)
```

<audio  controls="controls" src="/envelope-filter/bandpass_toe_down.mp3"></audio>





```python
specgram2, (raw_bandpass_spec, heel_bandpass_spec, toe_bandpass_spec) = plt.subplots(nrows=3)
raw_bandpass_spec.specgram(data.T[-1],Fs=samplerate, NFFT=1024);
heel_bandpass_spec.specgram(bandpass_heel_down_signal,Fs=samplerate, NFFT=1024);
toe_bandpass_spec.specgram(bandpass_toe_down_signal,Fs=samplerate, NFFT=1024);
```


![Bandpass Filter Spectrogram](/envelope-filter/Bandpass_Filtered_Spectrogram.png)



```python

sample_filtered = np.zeros(len(data.T[-1]))
signal_in = data.T[-1]
zi = signal.lfilter_zi(bandpass_toe_down['num'],bandpass_toe_down['den'])
for i in range(len(data.T[-1])):
    sample_filtered[i], zi = signal.lfilter(bandpass_toe_down['num'], bandpass_toe_down['den'], [signal_in[i]], zi=zi)
```


```python
specgram3, sample_filtered_spec = plt.subplots()
sample_filtered_spec.specgram(sample_filtered,Fs=samplerate, NFFT=1024);
```

![Sample Filtered Spectrogram](/envelope-filter/sample_filtered_specgram.png)


```python
Audio(sample_filtered, rate=samplerate)
```



<audio  controls="controls" src="/envelope-filter/sample_filtered.mp3"></audio>


This shows that I can do per-sample based filtering. Now we should adapt it so the filter varies between the two filters. I guess the first step here is introducing some normalization.


```python
normalized_envelope = envelope / np.max(envelope)

fig_env_norm, ax_env_norm = plt.subplots()
ax_env_norm.set_title("Normalized envelope")


ax_env_norm.plot(time, normalized_envelope, 'o', label="envelope")

ax_env_norm.legend()
ax_env_norm.set_ylabel("Envelope value")
ax_env_norm.set_xlabel("Time");
```



![Normalized Envelope](/envelope-filter/normalized_envelope.png)



```python
sample_envelope_filtered = np.zeros(len(data.T[-1]))
signal_in = data.T[-1]
# Always start in heel-down position.
zi = signal.lfilter_zi(bandpass_heel_down['num'],bandpass_heel_down['den'])

freq_min = 180
freq_max = 1800
freq_range = freq_max - freq_min

for i in range(len(data.T[-1])):
    freq = freq_min + normalized_envelope[i] * freq_range
    env_filt = bandpassfilter(freq,Q)
    sample_envelope_filtered[i], zi = signal.lfilter(env_filt['num'], env_filt['den'], [signal_in[i]], zi=zi)
```


```python
specgram4, sample_env_filtered_spec = plt.subplots()
sample_env_filtered_spec.specgram(sample_envelope_filtered,Fs=samplerate, NFFT=1024);
```

![Sample Filtered Spectrogram](/envelope-filter/Envelope_Filtered_Spectrogram.png)


```python
Audio(sample_envelope_filtered, rate=samplerate)
```

<audio  controls="controls" src="/envelope-filter/sample_envelope_filtered.mp3"></audio>

# Conclusion

I think I've got the basis now for an envelope filter that I can continue to work on. The next steps are playing around some more with the parameters, figuring out what the topology of an actual effect would be (do we need additional effects to make it sound as good as possible?) and converting this code to C++ using JUCE to make an actual effect out of it. 

