--- 
layout: post 
title:  "My FOSS workflow for learning songs" 
date: 2015-04-22 
categories: FOSS, Bass, Musescore, Ardour
---

About a year ago I decided that I was going to pick up my bass guitar
again after being on a hiatus for a couple of years.  This was mainly
motivated by the feeling that I was spending too much time in front of
a monitor (and seeing Bootsy play at Couleur Cafe Festival).  However,
being the computer geek that I am I can't help but throw some technology
into the mix. This post details the workflow I follow to learn a song.


Musescore
--------- 
<div align="center">
<img src="{{'/assets/img/2015-04-22-FOSS-bass-workflow/musescore-logo.png' | prepend:site.baseurl }}" alt="" align="center" > 
</div> 

My teacher usually assigns me a song to learn and gives me the sheet
music. This is where the workflow starts. I input this sheet music into
Musescore.


[Musescore](https://musescore.org/) is a WYSIWYG editor for sheet music
notation. You can provide input through different mechanisms:
point-and-click, computer keyboard (A through G are the notes, numpad
determines note length), or MIDI. Once you have the controls in your
fingers it only takes a couple of minutes to input a pop song.

This in itself is already very interesting, but Musescore has a number of
features that make it a killer tool for getting the song just right.

### Playback

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
<img src="{{'/assets/img/2015-04-22-FOSS-bass-workflow/ardour_made.png' | prepend: site.baseurl }}" alt="" align="center" > </div>

I recently bought a Focusrite Scarlett 2i2 USB audio interface. It
performs admirably on my Linux system (Mint 17.1 Mate with a low-latency
kernel). I quickly integrated it into my practice routine. What I do is
I load up an mp3 or ogg file into Ardour, a DAW, and record myself playing
over the original song. I start doing this once I feel I've got the song
down playing along with Musescore. When you listen back to the recording
you're confronted with the tiny errors in your playing: strings you don't
mute, buzz caused by not fretting exactly right.  
