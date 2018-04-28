---
layout: post
title: "The Theory and Technique of Electronic Music - Ch01 exercise solution"
date: 2018-04-28 21:10
categories: msp
---


I've started working my way through Miller Puckette's [*The Theory and Technique
of Electronic Music*](http://msp.ucsd.edu/techniques.htm).
So far it's been super interesting, making the link between
the digital signal processing I studied at school and the music theory I study at
the academy. It uses a graphical environment called Pure Data to demonstrate the
concepts discussed in the book.
I haven't played around a lot with it, but it seems to be quite
an interesting environment for rapid prototyping of musical application.

One thing that bothered me though is that the book (or at least the version I have)
does not contain an answer key for the exercises. If you're doing self study like
I am currently doing that's kind of annoying. So I decided to publish the solutions
I came up with here in hope that they are useful to somebody else.
I can't guarantee that these solutions are correct but where possible I looked
stuff up on Wikipedia. If you found this useful or found an error,
drop me a line on twitter [@fvbever](https://twitter.com/fvbever).


#### Exercise 1:

A sinusoid has initial phase \\(\phi=0\\) and angular frequency \\(\omega = \pi/10\\). What is its period in samples? What is the phase at sample number \\(n=10\\)?


&rArr; The phase is equal to \\(\omega n + \phi\\) so the phase at sample 10 is

$$\frac{\pi}{10} 10 + 0 = \pi rad$$


#### Exercise 2:

*Two sinusoids have periods of 20 and 30 samples, respectively. What is the period of the sum of the two?* 
&rArr; The period is determined by the fundamental period. In this case 30 samples.


#### Exercise 3:

*If 0 dB corresponds to an amplitude of 1, how many dB corresponds to amplitudes of 1.5, 2, 3, and 5?*

&rArr;

$$20\log_{10}(1) = 0dB$$

$$20\log_{10}(1.5) = 3.52dB$$

$$20\log_{10}(2) = 6.02dB$$

$$20\log_{10}(3) = 9.54B$$

$$20\log_{10}(5) = 13.98dB$$


#### Exercise 4:

*Two uncorrelated signals of RMS amplitude 3 and 4 are added; what's the RMS amplitude of the sum?*

&rArr;

$$A_{RMS}\{x[n]\}=\sqrt{P\{x[n]\}}$$

In general it's the case that

$$P\{x[n] + y[n]\} = P\{x[n]\} + P\{y[n]\} + 2 COV\{x[n],y[n]\}$$

Because the signals are not correlated we get:

$$P\{x[n] + y[n]\} = P\{x[n]\} + P\{y[n]\}$$

so

$$A_{RMS}\{x[n]+y[n]\}=\sqrt{P\{x[n]\} + P\{y[n]\}}$$


$$A_{RMS}\{x[n]+y[n]\}=\sqrt{3^{2} + 4^{2}}$$

$$A_{RMS}\{x[n]+y[n]\}=\sqrt{25} = 5$$


#### Exercise 5:

*How many uncorrelated signals, all of equal amplitude, would you have to add to 
get a signal that is 9 dB greater in amplitude?*

&rArr; 9dB is a factor \\(x = 10^{\frac{9}{20}} = 2.82 \\) so you'd have
to sum 2.82 uncorrelated signals.


#### Exercise 6:

*What is the angular frequency of middle C at 44100 samples per second?*

&rArr; The frequency of \\(C_{4}\\) is 216.626 Hz.

$$ \omega = 2\pi f = 2 \pi 216.626 Hz = 1643.84 \frac{rad}{s} $$

#### Exercise 7:

*Two sinusoids play at middle C (MIDI 60) and the neighboring C sharp (MIDI 61).
What is the difference, in Hertz, between their frequencies?*

&rArr;

$$ f = 440 \cdot 2^{\frac{m - 69}{12}} $$

$$ f_{C_{4}}=261.626 Hz $$

$$ f_{C\#_{4}}=277.18 Hz $$

$$ f_{C\#_{4}} -  f_{C_{4}} =15.56 Hz $$

#### Exercise 8:

*How many cents is the interval between the seventh and the eighth harmonic of a 
periodic signal?*

&rArr; The distance in cent is given by

$$ distance = 1200 \log{2} (\frac{f_{2}}{f_{1}}) $$

$$ x =  1200 \log{2}(\frac{8}{7}) = 231.17 cent $$

#### Exercise 9:

*If an audio signal $x[n], n = 0, ..., N-1$ has peak amplitude 1, what is the
minimum possible RMS amplitude? What is the maximum possible?*

&rArr;

$$ MAX(A_{RMS}) = A_{peak} = 1 $$

$$ MIN(A_{RMS}) = \frac{A_{peak}}{\sqrt{N}} = \frac{1}{\sqrt{N}} $$






