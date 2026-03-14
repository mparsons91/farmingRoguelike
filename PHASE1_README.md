# Phase 1 – Core Movement & Arena

## What’s included

- **Player:** Blue square, moves with **WASD** or **Arrow keys**. Speed: 320 px/s.
- **Arena:** Bounded play area (1200×600) with walls so the player can’t leave. Dark green floor.
- **Camera:** Follows the player with slight smoothing.

## How to run

1. Open **Godot 4**.
2. **Project → Open** and select the `farmingRoguelike` folder (the one that contains `project.godot`).
3. Press **F5** or click **Run Project** (play button).

## Controls

| Action | Keys   |
|--------|--------|
| Move   | W A S D or Arrow keys |

## Project structure

```
farmingRoguelike/
├── project.godot          # Main scene, input map (move_left/right/up/down), display
├── scenes/
│   ├── main.tscn          # Entry: Arena + Player + Camera2D (child of Player)
│   ├── arena/
│   │   ├── arena.tscn     # Floor + walls (StaticBody2D, collision layer 2)
│   │   └── arena.gd       # ARENA_SIZE, floor draw
│   └── player/
│       └── player.tscn    # CharacterBody2D, collision, visual (drawn in script)
└── scripts/
    └── player.gd          # Movement and _draw() for placeholder graphic
```

## Next (Phase 2)

First enemy type and basic combat.
