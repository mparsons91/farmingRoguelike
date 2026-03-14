extends CharacterBody2D
## Basic enemy: chases the player, has health, deals contact damage.
## Phase 2 – first enemy type.

const SPEED := 120.0
const CONTACT_DAMAGE := 1
const CONTACT_COOLDOWN_MS := 1000

@export var max_health := 3
var health: int
var _contact_cooldown_until: int = 0

func _ready() -> void:
	health = max_health
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	var player = _get_player()
	if player == null:
		return
	var dir: Vector2 = (player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()
	_apply_contact_damage(player)

func _get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D

func _apply_contact_damage(player: Node2D) -> void:
	var now := Time.get_ticks_msec()
	if now < _contact_cooldown_until:
		return
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() == player and player.has_method("take_damage"):
			player.take_damage(CONTACT_DAMAGE)
			_contact_cooldown_until = now + CONTACT_COOLDOWN_MS
			break

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		var pos: Vector2 = global_position
		var main: Node = get_tree().current_scene
		if main != null and main.has_method("spawn_pickup"):
			main.spawn_pickup(pos, &"wood", 1)
		queue_free()

const SIZE := Vector2(28.0, 28.0)

func _draw() -> void:
	draw_rect(Rect2(-SIZE / 2, SIZE), Color(0.85, 0.2, 0.2))
