# VIctory on an RTX 3050 (8 GB, 16 GB RAM)

A fork of [trustno1-coder/VIctory-NVIDIA](https://github.com/trustno1-coder/VIctory-NVIDIA), itself built on
[VIctory](https://github.com/Marvisak/VIctory): a compatibility layer that runs an Xbox Series title natively on
Windows from files **you** supply. This fork does not change the layer's code. It documents what happens on a
**low-end** PC (RTX 3050 8 GB, 16 GB of RAM, i5-12400F) and ships a launcher tuned for it.

> **This repository contains no game files, code or assets.** You need your own legally obtained copy of the title.
> It is not affiliated with or endorsed by the title's developer or publisher, nor by NVIDIA.
> See [docs/asset-policy.md](docs/asset-policy.md). The original README of the code this builds on is kept in
> [docs/README-trustno1.md](docs/README-trustno1.md).

## Where it stands (2026-11-27)

**Not playable at 30 fps. It is playable slowly: a median of about 6 frames a second on this PC, with long stutters on
every place it has not drawn before.** Measured on one PC, over one 101-minute session.

| | |
|---|---|
| CPU | Intel Core i5-12400F (6 cores, 12 threads) |
| GPU | NVIDIA GeForce RTX 3050, 8 GB, driver 610.88 |
| RAM | 16 GB DDR4-3200, **one stick** (single channel) |
| Disk | 1 TB NVMe-class SSD (the game and caches), Windows page file on it |
| OS | Windows 11 Pro, build 26300 |
| Profile | Series S, DLSS Performance (scene drawn at 0.5 scale), no frame generation |
| Build | `trustno1-coder/VIctory-NVIDIA` at `d12eb1b` (2026-11-27), built from source |

### Frame times (from the layer's own log, 816 intervals with 1,000 or more draws a frame)

| | ms a frame | frames a second |
|---|---|---|
| Median | 176 | 5.7 |
| Mean of the intervals | – | 6.4 |
| Best tenth (10th percentile) | 84 | 12 |
| Best interval | 48 | 21 |
| Worst tenth (90th percentile) | 433 | 2.3 |
| Share of intervals at 10 fps or more | 21 % | |
| Share of intervals at 15 fps or more | 2 % | |

Open water and the first rooms ran at about **13 fps** by the player's own reading of the title bar (not a log
figure). The log's numbers above include the whole session: loading, shader preparation on the first run, and every
new area. A second launch, with the shader cache already built, is smoother.

Stability in that session: **no device loss, no crash, no error lines** in the log. One shader of the title does not
translate (its draws are dropped).

### How far we came, on the same PC

| Build | World | Frame rate in the world |
|---|---|---|
| VIctory with our own fixes (two-layer compositor, watchdog patch) | black; menus and loading art only | 0.7 to 1.5 fps |
| Same, plus 13 community pull requests merged | reaches the world, still black | about 2 fps, no crash |
| [CGBJ's build](https://github.com/codec-d/cool_fox) (`Play-VIctory`) | **renders** (dark indoors) | 2.5 to 3 fps |
| CGBJ's build, brighter stand-in light | renders, readable | 2.5 to 3 fps |
| **This fork: VIctory-NVIDIA, Series S + DLSS Performance** | renders | **median 5.7, up to 13 fps on open water** |

That is roughly **4 to 9 times the frame rate** of where we started, and the picture went from a black screen to the
game world. The jump from CGBJ's build to this one comes from DLSS drawing the scene at half scale and from this
base's faster submission code.

## What you need

Honestly, for this fork on this hardware:

- **Windows 10 or 11** (x64), a CPU with AVX2, an NVIDIA RTX card with a recent driver.
- **16 GB of RAM works, but is the weak point.** The layer used about **20 GB** of process memory and filled the
  card's 8 GB (7.2 GB in use, 92 % load). Windows had to page the rest: the page file grew from 18 GB to **29 GB**
  while playing, and Windows' total commit sat at 41 of 42.5 GB. Keep **at least 30 GB free on the system drive**
  and close everything else (browser, chat, music). The upstream recommendation is 32 GB; we did not test it.
- **An SSD.** A hard disk will make the stutters much worse.
- **8 GB of video memory is the limit.** An earlier build crashed after about 50 minutes with
  `Not enough memory resources are available (0x8007000E)`. This one did not in 101 minutes, but it has little room.
- **Your own dump** of the title's Xbox Series build v1.0.2.1 (the folder with `game_scarlett_master.exe`).
- [Rust](https://rustup.rs) (the toolchain is pinned) and the Visual Studio Build Tools with
  "Desktop development with C++", to build it.
- Graphics driver timeout: we raised Windows' `TdrDelay` and `TdrDdiDelay` to 60 s (needs administrator and a restart)
  because the first builds we tried hung the card for longer than Windows' default 2 s. This build did not need it in
  the measured session, but the value was set.

**Not supported on an RTX 30 card:** DLSS frame generation (needs RTX 40 or later; the log says
`Disabling DLSS-G since it is not supported on current hardware`). DLSS super resolution works.

## How to run it

```powershell
git clone https://github.com/s3eidat/VIctory-NVIDIA-RTX3050
cd VIctory-NVIDIA-RTX3050
copy victory.example.toml victory.toml        # then set your paths, outside this folder
cargo build --release --locked -p victory
.\Get-NVIDIA-DLSS.cmd                         # NVIDIA's own DLSS files, from NVIDIA's GitHub (about 70 MB)
notepad game_dir.txt                          # one line: the folder with game_scarlett_master.exe
run-3050.cmd
```

`run-3050.cmd` copies your save folder to `%USERPROFILE%\victory-save-backups` first (copy only, nothing is deleted),
then starts the layer with:

| Setting | Why |
|---|---|
| `-SeriesS` | The lighter console profile. |
| `-Dlss performance` | The cheapest DLSS mode: the scene is drawn at half scale and upscaled. |
| `-NoFrameGenReady` | Frame generation is not available on this card, and holding memory back for it costs textures. |
| `-Fps 1000` | No frame cap. |
| `VICTORY_AMBIENT=1.6`, `VICTORY_AMBIENT_AIR=0.8` | The title's ray-traced indirect light does not run, so a stand-in light is used. These values brighten dark rooms and faces and reduce the brown haze. |

**First launch:** the graphics driver prepares every shader from scratch, which takes about 10 to 15 minutes before it
looks right. After that the shaders are saved and starts are much faster.

### In the game

- **F1** opens this build's settings menu, **F3** shows the stats panel (frame rate, draws, GPU and memory).
- Do not click away from the game window or alt-tab: the title suspends itself when it loses focus.
- A **PS4 controller** works through [DS4Windows](https://github.com/Ryochan7/DS4Windows) with its profile set to
  **Xbox 360 output** (the layer reads Xbox controllers only). The mouse is not read. The keyboard works as a
  stand-in pad: W A S D move, I J K L look, Enter = A, Backspace = B, Z and C = the triggers.

## Known problems on this PC

- **2 to 6 fps most of the time**, 12 or more only in light scenes. Of a frame, the card needs about 17 ms on average
  (it is not the limit any more); the CPU-side work of the layer is.
- **Stutter on every new place** until its shaders are made. The second visit is smooth.
- **No ray tracing.** Rooms and faces in shadow are dark; the stand-in light helps but is not the real lighting.
- **Memory is tight.** 16 GB of RAM in single channel is below what the authors recommend.
- **PS4 pad, shooting:** the trigger values reach the layer (measured up to 165 and 194 of 255), but the in-game
  shot did not fire in our test. We did not find the cause.
- **DLSS frame generation** is not available, and we did not get [ANR](https://github.com/apex-compute/ANR) (a
  frame-generation replacement for older cards) to work with this build: untested.

## Not measured

A second RAM stick, an AMD card, and a repeated run with a warm shader cache. A Radeon RX 9060 XT 16 GB and a second
16 GB stick are planned for December; this page will be updated with the numbers.

## Credits

This fork changes no code of the layer. It is the work of everyone below; our part is the 3050 launcher, the
measurements and this page. The tests and the comparison of builds were done on one PC with the help of
[Claude Code](https://claude.com/claude-code).

- **[VIctory](https://github.com/Marvisak/VIctory)** by Marvisak and its contributors: the loader, the runtime
  services, the Direct3D 12 back end and the shader recompiler. Everything else sits on it.
- **[trustno1-coder/VIctory-NVIDIA](https://github.com/trustno1-coder/VIctory-NVIDIA)**: the base of this fork: DLSS,
  the F1 and F3 panels, and the build that ran best here.
- **[foxhound](https://github.com/readmet3xt-lab/foxhound)** by readmet3xt-lab, which that base is built on.
- **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)**: the first fork we ran with a rendered world,
  and the work its pull requests carry.
- **[CGBJ / codec-d's cool_fox](https://github.com/codec-d/cool_fox)** (the original repository was taken down; we ran a
  copy from a mirror built from source): NVIDIA wave32 lowering, the Series S two-plane fix, memory budgets, and the
  stand-in light that made the world readable on our card.
- **[avatarmanz/VIctory-7900XTX](https://github.com/avatarmanz/VIctory-7900XTX)**,
  **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)**,
  **[DexNom/VIctory](https://github.com/DexNom/VIctory)**,
  **[myokex/victory-amd](https://github.com/myokex/victory-amd)**,
  **[FQY55kai/ZJOU-VICTORY](https://github.com/FQY55kai/ZJOU-VICTORY)**: forks we saved and read; their findings
  explained where a frame goes.
- The roughly 1,100 pull requests sent to VIctory; 13 of the bundles were merged into the first of our builds.
- **NVIDIA** Streamline, DLSS and Reflex: NVIDIA's, loaded at run time from a folder you supply.
- **[DS4Windows](https://github.com/Ryochan7/DS4Windows)** and
  **[ViGEmBus](https://github.com/nefarius/ViGEmBus)** (Nefarius): the PS4 controller as an Xbox pad.
- **[Apex Compute's ANR](https://github.com/apex-compute/ANR)**: looked at, not used.

## License

GPL-3.0-or-later, as VIctory and its forks. See [LICENSE](LICENSE); the one file that is not covered is named in
[docs/asset-policy.md](docs/asset-policy.md).
