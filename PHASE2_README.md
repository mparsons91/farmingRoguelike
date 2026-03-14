# Phase 2 – First Enemy & Basic Combat

## What’s included

- **Enemy:** Red square, 3 HP, chases the player. Deals 1 contact damage every 1 s when touching the player.
- **Player attack:** **Space** or **Left click** = melee. Short-range hitbox around the player, 1 damage per enemy per swing, ~0.4 s cooldown.
- **Player health:** 5 HP. If an enemy touches you, you take 1 damage (with 1 s cooldown per enemy). At 0 HP the scene restarts (game over).
- **Main:** Two enemies spawn in the arena for testing.

## How to run

Open the project in Godot 4 and press **F5**.

## Controls

| Action   | Keys / input      |
|----------|-------------------|
| Move     | W A S D / Arrows  |
| Attack   | Space / Left click |

## New / changed files

- **project.godot** – `attack` input (Space, LMB); layer names: player, walls, enemies.
- **scenes/enemy/enemy.tscn** – CharacterBody2D, layer 3, mask 1+2 (player + walls).
- **scripts/enemy.gd** – Chase player, `take_damage()`, contact damage with cooldown, `_draw()` for placeholder.
- **scenes/player/player.tscn** – `MeleeHitbox` Area2D (mask = enemies), group `player`, collision_mask 6 (walls + enemies).
- **scripts/player.gd** – Health, `take_damage()`, `die()` (reload scene), melee attack and cooldown.
- **scenes/main.tscn** – `Enemies` node with two enemy instances.

## Next (Phase 3)

Waves and resource drops.
