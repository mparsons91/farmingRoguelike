extends Area2D
## Pickup that adds resources when the player overlaps. Phase 3.

var resource_type: StringName = &"wood"
var amount: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	RunResources.add_resource(resource_type, amount)
	queue_free()

const SIZE := Vector2(20.0, 20.0)

func _draw() -> void:
	var color: Color = Color(0.6, 0.35, 0.15) if resource_type == &"wood" else Color(0.45, 0.45, 0.5)
	draw_rect(Rect2(-SIZE / 2, SIZE), color)
