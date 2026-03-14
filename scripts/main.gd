extends Node2D
## Main scene: wave manager, pickup spawning, run setup. Phase 3.

const PICKUP_SCENE: PackedScene = preload("res://scenes/pickups/resource_pickup.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy/enemy.tscn")
const ARENA_SIZE := Vector2(1200.0, 600.0)
const SPAWN_MARGIN := 80.0
const WAVE_INTERVAL_SEC := 25.0
const ENEMIES_PER_WAVE_BASE := 2

var wave_number: int = 1

@onready var enemies_node: Node2D = $Enemies
@onready var pickups_node: Node2D = $Pickups
@onready var wave_timer: Timer = $WaveTimer
@onready var wave_label: Label = $UI/WaveLabel
@onready var resources_label: Label = $UI/ResourcesLabel

func _ready() -> void:
	add_to_group("main")
	RunResources.reset_for_run()
	wave_timer.wait_time = WAVE_INTERVAL_SEC
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	_spawn_wave()
	wave_timer.start()

func _process(_delta: float) -> void:
	wave_label.text = "Wave: %d" % wave_number
	resources_label.text = "Wood: %d  Ore: %d" % [RunResources.wood, RunResources.ore]

func _on_wave_timer_timeout() -> void:
	wave_number += 1
	_spawn_wave()

func _spawn_wave() -> void:
	var count: int = ENEMIES_PER_WAVE_BASE + wave_number
	for i in count:
		_spawn_enemy(_random_arena_position())

func _random_arena_position() -> Vector2:
	var x: float = randf_range(SPAWN_MARGIN, ARENA_SIZE.x - SPAWN_MARGIN)
	var y: float = randf_range(SPAWN_MARGIN, ARENA_SIZE.y - SPAWN_MARGIN)
	return Vector2(x, y)

func _spawn_enemy(at: Vector2) -> void:
	var enemy: Node2D = ENEMY_SCENE.instantiate() as Node2D
	enemy.position = at
	enemies_node.add_child(enemy)

func spawn_pickup(pos: Vector2, resource_type: StringName, amount: int) -> void:
	var pickup: Area2D = PICKUP_SCENE.instantiate() as Area2D
	pickup.global_position = pos
	pickup.resource_type = resource_type
	pickup.amount = amount
	pickups_node.add_child(pickup)
