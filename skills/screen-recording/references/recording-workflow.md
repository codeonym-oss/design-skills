# Recording workflow: tutorial or demo

## Before (5 minutes)
- [ ] Outline: hook (what you'll get) → steps → result → call to action. Bullet points, not a script, unless it's a short promo.
- [ ] Prepare the demo state: repo cloned, dependencies installed, browser tabs open, test data ready, secrets out of `.env` on screen.
- [ ] Clean desktop: close chat apps, **Do Not Disturb** / Focus on, hide bookmarks bar.
- [ ] Readability: editor font 16–18, terminal font 16+, browser zoom 125 %, light or high-contrast theme.
- [ ] `bash <skill-dir>/scripts/presenter-mode.sh on` (bigger cursor, Ctrl ripple).
- [ ] Keystrokes (for shortcut-heavy tutorials): start `showmethekey-gtk`.
- [ ] OBS: correct profile + scene collection, mic level check (peaks around −10 dB), 10-second test recording played back with headphones.

## During
- Start recording, wait 2 s in silence (clean cut point), then start.
- Talk while doing; slightly slower than normal speech. Pause 1–2 s between sections — easy to cut.
- Mistake? Stop, pause 2 s, repeat the sentence from its start. Cut later — don't restart the whole take.
- Clap or press the "add chapter marker" hotkey at section changes (OBS 30+: *Add Chapter Marker*) to find them in the edit.
- Move the cursor deliberately; rest it away from what you're explaining.
- Use scene hotkeys to switch between Screen and Screen + Cam.

## After
```bash
bash <skill-dir>/scripts/presenter-mode.sh off
bash <skill-dir>/scripts/finish-recording.sh 2026-09-25_14-02-11.mkv --trim-start 2 --trim-end 1 --denoise
```
Then in Kdenlive (`video-editing` skill): cut mistakes → zooms on key moments → titles/lower-thirds → music bed (−20 dB) → captions → export.
Deliver: `encode.sh final.mp4 youtube`, plus `vertical` highlights for Shorts/Reels and `gif.sh` loops for the README/portfolio.

## Demo-style videos (Screen Studio look)
For short product demos (landing page, launch post), record with **OpenScreen** instead of OBS: it tracks clicks and adds smooth zoom-ins, cursor smoothing and a padded background automatically. Export, then finish audio with `loudnorm.sh` and deliver with `encode.sh`.
