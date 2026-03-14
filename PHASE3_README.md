# Phase 3 – Waves & Resource Drops

## What’s included

- **Wave manager:** Every 25 seconds a new wave starts. Wave 1 = 3 enemies, Wave 2 = 4, Wave 3 = 5, etc. Enemies spawn at random positions in the arena.
- **Resource pickups:** When an enemy dies it drops 1 **Wood** (brown square). Walking over it collects it and adds to your run totals.
- **Run resources:** `RunResources` autoload stores Wood and Ore for the current run. Shown in the UI; reset when you start a new run (e.g. after death).
- **UI:** Top-left shows **Wave: N** and **Wood: X  Ore: Y** (updates live).

## How to run

Open the project in Godot 4 and press **F5**. Survive waves, kill enemies, collect wood. New waves spawn on a timer.

## New / changed files

- **project.godot** – `RunResources` autoload.
- **scripts/run_resources.gd** – Autoload: `wood`, `ore`, `add_resource()`, `get_count()`, `reset_for_run()`.
- **scripts/resource_pickup.gd** – Area2D script: `resource_type`, `amount`; on body_entered (player) adds to RunResources and removes pickup.
- **scenes/pickups/resource_pickup.tscn** – Pickup Area2D (mask = player); visual in script (wood = brown, ore = grey).
- **scripts/main.gd** – Wave timer, `_spawn_wave()`, `spawn_pickup()`, UI label updates.
- **scenes/main.tscn** – Main script, Pickups node, WaveTimer, UI (Wave + Resources labels); no static enemies (all spawned).
- **scripts/enemy.gd** – On death calls `main.spawn_pickup(global_position, "wood", 1)` then `queue_free()`.

## Next (Phase 4)

Run vs. meta: end run (death/escape), hub screen, persist resources between runs.
