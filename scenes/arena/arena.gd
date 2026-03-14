extends Node2D
## Arena bounds. Defines the play area.
## Walls are StaticBody2D children; this script draws the floor.

const ARENA_SIZE := Vector2(1200.0, 600.0)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color(0.15, 0.22, 0.12))
