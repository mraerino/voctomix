# Voctomix
The [C3Voc](https://c3voc.de/) creates Lecture Recordings from German Hacker/Nerd Conferences. We have used [dvswitch](http://dvswitch.alioth.debian.org/wiki/) very successfully in the past but it has some serious limitations, which in 2014 we started looking for a replacement. We tested [snowmix](http://sourceforge.net/projects/snowmix/) and [gst-switch](https://github.com/timvideos/gst-switch) and while both did some things we wanted right, we realised that no existing tool would be able to fulfil all our whishes. Furthermore both are a nightmare to extend. So we decided to build our own Implementation of a Live-Video-Mixer.

## Subprojects
The Voctomix Project consists of three parts:
 - [Voctocore](./voctocore/), the videomixer core-process that does the actual video- and audio crunching
 - [Voctogui](./voctogui/), a GUI implementation in GTK controlling the core's functionality and giving visual feedback of the mixed video
 - Voctotools (tbd.), a Collection of Tools and Examples on how to talk to the core-process, feeding and receiving video-streams

## Installation
Voctomix requires a fairly recent Version of GStreamer (at least 1.5, though we recommend 1.6 and later). This is natively present on [Debian Sid](https://packages.debian.org/sid/libgstreamer1.0-0) and [Ubuntu Wily](http://packages.ubuntu.com/wily/libgstreamer1.0-0). On these Systems it should run out of the Box and we recommend using one of them. A [Docker](http://www.docker.com) image that uses Ubuntu Wily as a base is bundled with Vocomix. Please refer to the seperate [readme](./README_DOCKER.md) how to use the Docker image.

Install the required Dependencies:
````
apt-get install gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools libgstreamer1.0-0 python3 python3-gi gir1.2-gstreamer-1.0
````

For the GUI you'll -- additionally to a gnome-desktop -- need to install the following dependencies:
````
apt-get install gstreamer1.0-alsa python3-gi-cairo
````

Now you should be able to clone the Git-Repository and run Voctomix or the GUI like this:
````
git clone https://github.com/voc/voctomix.git
cd voctomix
./voctocore/voctocore.py -vv
./voctogui/voctogui.py -vv
````

## Installation on Jessie
Because we are using Debian Jessie as our production system (which only has [1.4 packaged](https://packages.debian.org/jessie/libgstreamer1.0-0)), we are packaging the required Libraries in our own Debian Repository. The Packages inside this Repository are built against deb-multimedia.org, so to use them you should add the following lines to your `/etc/apt/sources.list`:
````
deb http://www.deb-multimedia.org jessie main non-free
deb http://c3voc.de/voctomix jessie non-free
````

You'll then need install the GPG-Keys:
````
apt-get update
apt-get install deb-multimedia-keyring
curl https://c3voc.de/voctomix/gpg-key.asc | apt-key add -
apt-get update
````

Now proceed as described on unter [Installation](#installation).

## Quickstart using Docker

Run the core and two example source streams
```
docker run -it --rm --name=voctocore c3voc/voctomix core
docker run -it --rm --name=cam1 --link=voctocore:corehost c3voc/voctomix gstreamer/source-videotestsrc-as-cam1.sh
docker run -it --rm --name=bg --link=voctocore:corehost c3voc/voctomix gstreamer/source-videotestsrc-as-background-loop.sh
```

Run the GUI 
```
xhost +local:$(id -un)
touch /tmp/vocto/configgui.ini
docker run -it --rm --name=gui --env=gid=$(id -g) --env=uid=$(id -u) --env=DISPLAY=:0 --link=voctocore:corehost \
  -v /tmp/vocto/configgui.ini:/opt/voctomix/voctogui/config.ini -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp/.docker.xauth:/tmp/.docker.xauth c3voc/voctomix gui
```

show more commands availabe
```
docker run -it --rm c3voc/voctomix help
docker run -it --rm c3voc/voctomix examples
```

## A word on CPU-Usage
Voctomix requires a fair amount of CPU-Time to run in the default configuration of 1920×1080 at 25fps. Our Production-Systems have these CPUs: `Intel Core i7-3770 CPU 4x 3.40GHz` but we're also experimenting with newer ones like these: `Intel Core i7-6700K, 4x 4.00GHz`.
For testing and development you may want to use a `config.ini` that reduces the resolution and also turns off the JPEG-Preview-Encoders, which take a huge amount of the required CPU-Power and are not required, as long as the GUI and the Core run on the same machine (or have a 10GE Link between them, FWIW). Don't forget to modify your source-scripts to provide the correct resolution.

Such a config.ini might look like this:
````
[mix]
videocaps=video/x-raw,format=UYVY,width=320,height=180,framerate=25/1,pixel-aspect-ratio=1/1

[previews]
enabled=false
videocaps=video/x-raw,width=320,height=180,framerate=25/1
````

## A word on running in a VM
While the Core runs fine inside any VM, the GUI uses OpenGL to display the Video-Streams. Don't forget to enable 3D Acceleration in your VM to support this.


## Contact
To get in touch with us we'd ask to join `#voctomix` on the hackint IRC network, mail to `voc AT c3voc DOT de` or meet us on one of the [many conferences](https://c3voc.de/eventkalender) we're at.
You may also want to watch [a Presentation](https://media.ccc.de/v/froscon2015-1520-conference_recording_und_streaming#video) some of us gave about our Video-Infrastructure.
