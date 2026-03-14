extends CharacterBody2D
## Player controller: WASD / Arrow keys movement.
## Phase 1 – core movement only.

const SPEED := 320.0
const SIZE := Vector2(32.0, 32.0)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()

func _draw() -> void:
	draw_rect(Rect2(-SIZE / 2, SIZE), Color(0.2, 0.6, 0.9))
