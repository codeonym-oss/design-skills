# Delivery specs & ffmpeg cheat sheet

## Platform specs
| Platform | Resolution | Aspect | Max length | Loudness | Script preset |
|---|---|---|---|---|---|
| YouTube | 1920×1080 or 3840×2160 | 16:9 | — | −14 LUFS | `youtube` |
| YouTube Shorts | 1080×1920 | 9:16 | 3 min | −14 | `vertical` |
| Instagram Reels | 1080×1920 | 9:16 | 3 min (safe zone: keep text out of bottom 20 %) | −14 | `vertical` |
| Instagram / LinkedIn feed | 1080×1080 or 1080×1350 | 1:1 / 4:5 | LinkedIn 10 min | −14 | `square` |
| LinkedIn / X landscape | 1920×1080 | 16:9 | X 2:20 (free) | −14 | `web` |
| TikTok | 1080×1920 | 9:16 | 10 min | −14 | `vertical` |
| Portfolio / landing page | 1920×1080, ≤ 10 MB for autoplay loops | any | short loop | muted | `web --sw` or `gif.sh` → WebM |
| Client review | 1280×720 | any | — | — | `preview` |

Frame rate: keep the source rate (30 or 60). Screen recordings of code look best at 60 fps only if there is fast motion; 30 is fine for talking + typing.

## Loudness targets
−14 LUFS integrated for streaming/social · −16 LUFS podcasts/voice-only · −23 LUFS broadcast · true peak ≤ −1.5 dBTP.

## ffmpeg one-liners (run them in the container with `ds exec ffmpeg …`)
```bash
# Lossless trim (cuts on keyframes; fast)
ffmpeg -ss 00:01:05 -to 00:02:30 -i in.mp4 -c copy trimmed.mp4

# Frame-accurate trim (re-encodes)
ffmpeg -ss 00:01:05.200 -to 00:02:30.500 -i in.mp4 -c:v libx264 -crf 18 -c:a aac out.mp4

# Concatenate clips with identical codecs
printf "file '%s'\n" part1.mp4 part2.mp4 part3.mp4 > list.txt
ffmpeg -f concat -safe 0 -i list.txt -c copy joined.mp4

# Replace / add music bed at -20 dB under original audio
ffmpeg -i video.mp4 -i music.mp3 -filter_complex "[1:a]volume=-20dB[m];[0:a][m]amix=inputs=2:duration=first[a]" -map 0:v -map "[a]" -c:v copy out.mp4

# Burn subtitles (styled)
ffmpeg -i in.mp4 -vf "subtitles=subs.srt:force_style='FontName=Inter,FontSize=22,Bold=1,Outline=2'" -c:a copy out.mp4

# Speed up a boring section 4× (video + audio)
ffmpeg -i in.mp4 -filter_complex "[0:v]setpts=PTS/4[v];[0:a]atempo=2,atempo=2[a]" -map "[v]" -map "[a]" fast.mp4

# Extract audio for a podcast
ffmpeg -i in.mp4 -vn -c:a libmp3lame -q:a 2 audio.mp3

# Add a logo watermark bottom-right
ffmpeg -i in.mp4 -i logo.png -filter_complex "[1]scale=160:-1,format=rgba,colorchannelmixer=aa=0.6[l];[0][l]overlay=W-w-32:H-h-32" -c:a copy out.mp4

# Inspect a file
ffprobe -v error -show_entries stream=codec_name,width,height,r_frame_rate,bit_rate -of compact in.mp4
```
