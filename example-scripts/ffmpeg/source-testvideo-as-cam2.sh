#!/bin/sh
. `dirname "$0"`/../config.sh
ffmpeg -y -nostdin \
	-i "http://ftp.uni-erlangen.de/cdn.media.ccc.de/broadcast/sendezentrum/h264-hd/31c3-sendezentrum-1003-de-Freak_Show_FS147_That_Escalatored_Quickly_hd.mp4" \
	-ac 2 \
	-filter_complex "
		[0:v] scale=$WIDTH:$HEIGHT,fps=$FRAMERATE [v] ;
		[0:a] aresample=$AUDIORATE [a]
	" \
	-map "[v]" -map "[a]" \
	-pix_fmt yuv420p \
	-c:v rawvideo \
	-c:a pcm_s16le \
	-f matroska \
	tcp://localhost:10001
