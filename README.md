# Snakefile
Snake in Makefile.

## Requirements:
- POSIX‑compatible shell
- GNU make 3.81+
- VT100‑compatible terminal

## Install:
- `curl -fsSLO https://raw.githubusercontent.com/ania-7abc/Snakefile/refs/heads/main/Snakefile`

## Run:
- `make -f Snakefile run`

## Control:
- `WASD / Arrows` -- move
- `Q` -- exit
- `Space` -- pause

## Settings

- `WIDTH` – game field width (default `20`)
- `HEIGHT` – game field height (default `20`)
- `DELAY` – delay between moves in seconds (default `0.2`)
- `SNAKE_DIR` – directory for saving game state (default `.snake_state`)
- `AUTO_FILE` – file for automatic control
- `NO_COLOR` – if defined, disables colors
- `SNAKE_COLOR` – snake color (default `\033[1;32m`, bright green)
- `MAP_COLOR` – border color (default `\033[1;34m`, bright blue)
- `APPLE_COLOR` – food color (default `\033[1;31m`, bright red)

To change a setting, add a parameter in the format `KEY=value` to the `make -f Snakefile` command. For example, to change `WIDTH` and `HEIGHT` to `40`, run `make -f Snakefile run WIDTH=40 HEIGHT=40`.

## AUTO_FILE API

The program specified in `AUTO_FILE` takes exactly **5 arguments** (in the given order):

1. **Field width** (integer)
2. **Field height** (integer)
3. **Previous movement direction** – string `x y`, where `x, y ∈ {-1, 0, 1}`
4. **Snake position** – string `x1,y1 x2,y2 x3,y3 ...`, where the first pair is the head
5. **Food position** – string `x,y`

### Output (to stdout)

One of the strings:

- `"gameover"` – give up (e.g., if there is no valid move)
- `"error"` – error
- `"x y"` – new movement direction, where `x, y ∈ {-1, 0, 1}` (both cannot be zero)

> The direction is always given as a pair of numbers from -1 to 1.

