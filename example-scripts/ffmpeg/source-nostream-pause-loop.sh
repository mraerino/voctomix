#!/bin/sh
. `dirname "$0"`/../config.sh
wget -nc -O /tmp/pause.ts http://c3voc.mazdermind.de/testfiles/pause.ts
while true; do cat /tmp/pause.ts || exit 1; done |\
	ffmpeg -y -nostdin -re -i - \
	-filter_complex "
		[0:v] scale=$WIDTH:$HEIGHT,fps=$FRAMERATE [v]
	" \
	-map '[v]' \
	-c:v rawvideo \
	-pix_fmt yuv420p \
	-f matroska \
	tcp://localhost:17000
