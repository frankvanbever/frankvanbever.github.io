--- 
layout: post 
title:  "My FOSS workflow for learning songs" 
date: 2015-04-09 
categories: FOSS, Bass, Musescore, Ardour
---


About a year ago I decided that I was going to pick up my bass guitar again after being on a hiatus for a couple of years.  This was mainly motivated by the feeling that I was spending too much time in front of a monitor (and seeing Bootsy play at Couleur Cafe Festival).  However, being
the computer geek that I am I can't help but throw some (open
source!) technology into the mix. This post details the workflow I follow to
learn a song.


Musescore
--------- 
<div align="center">
<img src="{{'/assets/img/2015-04-22-FOSS-bass-workflow/musescore-logo.png' | prepend:site.baseurl }}" alt="" align="center" > 
</div> 

My teacher usually assigns me a song to learn and gives me the sheet
music. This is where the workflow starts. I input this sheet music into
Musescore.

<div align="center">
<img src="{{'/assets/img/2015-04-22-FOSS-bass-workflow/musescore.png' | prepend:site.baseurl }}" alt="" align="center" > 
</div> 


[Musescore](https://musescore.org/) is a WYSIWYG editor for sheet music
notation. You can provide input through different mechanisms:
point-and-click, computer keyboard (A through G are the notes, numpad
determines note length), or MIDI. Once you have the controls in your
fingers it only takes a couple of minutes to input a pop song.

This in itself is already very interesting, but Musescore has a number of
features that make it a killer tool for getting the song just right.


### Playback


<div align="center">
<img src="{{'/assets/img/2015-04-22-FOSS-bass-workflow/play_panel2.png' | prepend:site.baseurl }}" alt="" align="center" > 
</div> 

Musescore can [play back](https://musescore.org/en/node/35971) the music
you wrote down using the editor. This allows you to play along with an
isolated track of what your trying to learn. The Play panel also adds
tempo control, so you can slow down the song to learn and gradually build
up.

### Metronome
The recently released version 2.0 of Musescore now has a metronome.
Playing with a metronome is always a good idea when you really want to get
the timing down. It is also possible to configure the metronome to count
in.

### Looping
You can select a number of measures and play them back in a loop. This can
be especially handy for those hard-to-nail-down parts in a song: slow it
down and play it in a loop.


Once I feel I've got a pretty good grasp on the song I start playing along
with a recording. When I get to a level I feel comfortable I move to the
next stage:


Ardour - recording yourself 
--------------------------- 
<div align="center"> 
<img src="{{'/assets/img/2015-04-22-FOSS-bass-workflow/ardour_made.png' | prepend: site.baseurl }}" alt="" align="center" >
</div>

The next step involves [Ardour](http://ardour.org/), a digital audio workstation application. I have
a usb audio interface (Focusrite Scarlet 2i2, works great under Linux) which
I can connect to the line out of my amplifier or plug my bass into directly.
Being able to re-listen to what you've been playing is a valuable tool for
improving your playing.

<div align="center">
<img src="{{'/assets/img/2015-04-22-FOSS-bass-workflow/ardour.png' | prepend:site.baseurl }}" alt="" align="center" > 
</div> 

What I do is I load up a recording of the song I'm trying to learn and record
over it. This allows you to spot subtle timing errors, noise you make by not
fretting right or not muting your strings right. When you're in the zone with
a bad case of bass face it's sometimes hard to hear these problems. But the
recording doesn't lie.

The recently launched version 4.0 now also supports Windows.

Final thoughts
--------------

I find that these tools are a great aid when I try to learn a song. The fact
that I'm able to achieve this using open source software is an added bonus.
The applications I've described here however aren't the only possibilities.
Software like Sibelius or Finale could be used as a replacement for Musescore.
Audacity, Ableton, Reaper, etc. could be used as a replacement for Ardour.


**TL;DR:** Use an application that can play back sheet music. Record yourself
and listen to hear errors you wouldn't otherwise notice.
