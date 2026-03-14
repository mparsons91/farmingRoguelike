extends CharacterBody2D
## Player: movement, melee attack, health. Sprite sheets parsed into idle, walk, run, attack.

const SPEED := 320.0
const MELEE_DAMAGE := 1
const ATTACK_DURATION := 0.12
const ATTACK_COOLDOWN := 0.4

## Sprite sheet paths (With_shadow = single image with multiple frames)
const SHEET_IDLE := "res://assets/character/PNG/Sword/With_shadow/Sword_idle_with_shadow.png"
const SHEET_WALK := "res://assets/character/PNG/Sword/With_shadow/Sword_Walk_with_shadow.png"
const SHEET_RUN := "res://assets/character/PNG/Sword/With_shadow/Sword_Run_with_shadow.png"
const SHEET_ATTACK := "res://assets/character/PNG/Sword/With_shadow/Sword_attack_with_shadow.png"

## Idle sheet: 768x256, 4 rows (down, left, right, up), 12 frames per row (row 3 up = 4 frames x3).
const IDLE_SHEET_WIDTH := 768
const IDLE_SHEET_HEIGHT := 256
const IDLE_CELL_SIZE := 64
const IDLE_COLS := 12
const IDLE_ROWS := 4
const IDLE_TRIM := 12
const IDLE_FRAME_COUNT := 12
const IDLE_UP_FRAMES := 4

## Run sheet (Sword_Run_with_shadow.png): 512x256, 4 rows x 8 columns, 8 frames per direction, 12px trim.
const RUN_SHEET_WIDTH := 512
const RUN_SHEET_HEIGHT := 256
const RUN_CELL_SIZE := 64
const RUN_COLS := 8
const RUN_ROWS := 4
const RUN_FRAME_COUNT := 8

## Direction: 0=down, 1=left, 2=right, 3=up
var _last_facing: int = 0

@export var attack_frames: int = 6

@export var max_health := 5
var health: int
var _attack_active_until_msec: int = 0
var _attack_cooldown_until_msec: int = 0
var _hit_this_attack: Array = []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var melee_hitbox: Area2D = $MeleeHitbox

func _ready() -> void:
	add_to_group("player")
	health = max_health
	_setup_sprite_frames()
	animated_sprite.animation_finished.connect(_on_animation_finished)
	_play_idle_for_facing()
	melee_hitbox.body_entered.connect(_on_melee_body_entered)
	melee_hitbox.monitoring = false

## Create one AtlasTexture for a cell at (col, row). Use cell_w/cell_h for texture-derived dimensions (avoids pixel drift).
func _sheet_cell(tex: Texture2D, col: int, row: int, cell_size: int = IDLE_CELL_SIZE, trim: int = IDLE_TRIM, cell_w: int = -1, cell_h: int = -1) -> AtlasTexture:
	var at: AtlasTexture = AtlasTexture.new()
	at.atlas = tex
	at.filter_clip = true
	var cw: int = cell_w if cell_w > 0 else cell_size
	var ch: int = cell_h if cell_h > 0 else cell_size
	var size_w: int = cw - trim * 2
	var size_h: int = ch - trim * 2
	at.region = Rect2i(
		col * cw + trim,
		row * ch + trim,
		size_w,
		size_h
	)
	return at

## Build 4 direction animations from idle-style sheet (4 rows: down, left, right, up; 12 frames/row; row 3 up = 4 frames x3). Cell size from texture to avoid pixel drift.
func _setup_direction_sheet(sf: SpriteFrames, tex: Texture2D, prefix: StringName, fps: float, trim: int = IDLE_TRIM) -> void:
	if tex == null:
		return
	var cell_w: int = tex.get_width() / IDLE_COLS
	var cell_h: int = tex.get_height() / IDLE_ROWS
	var anim_names: Array = [prefix + "_down", prefix + "_left", prefix + "_right", prefix + "_up"]
	var frame_duration: float = 1.0 / fps
	for row in IDLE_ROWS:
		sf.add_animation(anim_names[row])
		sf.set_animation_loop(anim_names[row], true)
		sf.set_animation_speed(anim_names[row], fps)
		if row == 3:
			for _repeat in 3:
				for col in IDLE_UP_FRAMES:
					sf.add_frame(anim_names[row], _sheet_cell(tex, col, row, IDLE_CELL_SIZE, trim, cell_w, cell_h), frame_duration)
		else:
			for col in IDLE_FRAME_COUNT:
				sf.add_frame(anim_names[row], _sheet_cell(tex, col, row, IDLE_CELL_SIZE, trim, cell_w, cell_h), frame_duration)

## Run sheet: 512x256, 4 rows x 8 cols, 8 frames per direction, 12px trim, same speed as idle (3 FPS).
## Cell size derived from texture so regions align to actual pixels and avoid drift.
func _setup_run_animations(sf: SpriteFrames, tex: Texture2D) -> void:
	if tex == null:
		return
	const RUN_FPS := 3.0
	var cell_w: int = tex.get_width() / RUN_COLS
	var cell_h: int = tex.get_height() / RUN_ROWS
	var anim_names: Array = [&"run_down", &"run_left", &"run_right", &"run_up"]
	var frame_duration: float = 1.0 / RUN_FPS
	for row in RUN_ROWS:
		sf.add_animation(anim_names[row])
		sf.set_animation_loop(anim_names[row], true)
		sf.set_animation_speed(anim_names[row], RUN_FPS)
		for col in RUN_FRAME_COUNT:
			sf.add_frame(anim_names[row], _sheet_cell(tex, col, row, RUN_CELL_SIZE, IDLE_TRIM, cell_w, cell_h), frame_duration)

## Idle: same layout, 3 FPS. Cell size from texture so regions align and stay smooth.
func _setup_idle_animations(sf: SpriteFrames, tex: Texture2D) -> void:
	if tex == null:
		return
	var cell_w: int = tex.get_width() / IDLE_COLS
	var cell_h: int = tex.get_height() / IDLE_ROWS
	var anim_names: Array = [&"idle_down", &"idle_left", &"idle_right", &"idle_up"]
	const IDLE_FPS := 3.0
	var frame_duration: float = 1.0 / IDLE_FPS
	for row in IDLE_ROWS:
		sf.add_animation(anim_names[row])
		sf.set_animation_loop(anim_names[row], true)
		sf.set_animation_speed(anim_names[row], IDLE_FPS)
		if row == 3:
			for _repeat in 3:
				for col in IDLE_UP_FRAMES:
					sf.add_frame(anim_names[row], _sheet_cell(tex, col, row, IDLE_CELL_SIZE, IDLE_TRIM, cell_w, cell_h), frame_duration)
		else:
			for col in IDLE_FRAME_COUNT:
				sf.add_frame(anim_names[row], _sheet_cell(tex, col, row, IDLE_CELL_SIZE, IDLE_TRIM, cell_w, cell_h), frame_duration)

## Slice a horizontal sprite sheet into num_frames AtlasTextures. Returns empty if not sliceable.
func _slice_sheet(tex: Texture2D, num_frames: int) -> Array:
	var out: Array = []
	if tex == null or num_frames <= 0:
		return out
	if num_frames == 1:
		out.append(tex)
		return out
	var tw: int = tex.get_width()
	var th: int = tex.get_height()
	var fw: int = tw / num_frames
	if fw <= 0:
		return out
	for i in num_frames:
		var at: AtlasTexture = AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2i(i * fw, 0, fw, th)
		out.append(at)
	return out

func _play_idle_for_facing() -> void:
	var anim_names: Array = [&"idle_down", &"idle_left", &"idle_right", &"idle_up"]
	var name: StringName = anim_names[_last_facing]
	if animated_sprite.sprite_frames.has_animation(name):
		animated_sprite.play(name)

func _setup_sprite_frames() -> void:
	var sf := SpriteFrames.new()
	var tex: Texture2D
	var frames: Array

	tex = load(SHEET_IDLE) as Texture2D
	if tex == null:
		tex = load("res://assets/character/PNG/Sword/With_shadow/Sword_Idle_with_shadow.png") as Texture2D
	_setup_idle_animations(sf, tex)

	tex = load(SHEET_WALK) as Texture2D
	_setup_direction_sheet(sf, tex, &"walk", 2.0)

	tex = load(SHEET_RUN) as Texture2D
	_setup_run_animations(sf, tex)

	tex = load(SHEET_ATTACK) as Texture2D
	frames = _slice_sheet(tex, attack_frames)
	sf.add_animation(&"attack")
	if frames.is_empty() and tex:
		sf.add_frame(&"attack", tex, 0.2)
	else:
		for fr in frames:
			sf.add_frame(&"attack", fr as Texture2D, 1.0 / 12.0)
	sf.set_animation_loop(&"attack", false)
	sf.set_animation_speed(&"attack", 12.0)

	animated_sprite.sprite_frames = sf

func _on_animation_finished() -> void:
	if animated_sprite.animation == &"attack":
		_update_movement_animation()

## Map velocity to facing: 0=down, 1=left, 2=right, 3=up. Prefer horizontal when |x| >= |y|.
func _facing_from_velocity(v: Vector2) -> int:
	if v.is_zero_approx():
		return _last_facing
	if abs(v.x) >= abs(v.y):
		return 1 if v.x < 0 else 2
	return 3 if v.y < 0 else 0

func _play_walk_for_facing() -> void:
	var anim_names: Array = [&"walk_down", &"walk_left", &"walk_right", &"walk_up"]
	var name: StringName = anim_names[_last_facing]
	if animated_sprite.sprite_frames.has_animation(name):
		animated_sprite.play(name)

func _play_run_for_facing() -> void:
	var anim_names: Array = [&"run_down", &"run_left", &"run_right", &"run_up"]
	var name: StringName = anim_names[_last_facing]
	if animated_sprite.sprite_frames.has_animation(name):
		animated_sprite.play(name)

func _update_movement_animation() -> void:
	if animated_sprite.animation == &"attack":
		return
	if velocity.is_zero_approx():
		_play_idle_for_facing()
	else:
		_last_facing = _facing_from_velocity(velocity)
		if animated_sprite.sprite_frames.has_animation(&"run_down"):
			_play_run_for_facing()
		elif animated_sprite.sprite_frames.has_animation(&"walk_down"):
			_play_walk_for_facing()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
		_last_facing = _facing_from_velocity(velocity)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()
	if animated_sprite.animation != &"attack":
		_update_movement_animation()

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	if _attack_active_until_msec > 0 and now >= _attack_active_until_msec:
		_attack_active_until_msec = 0
		_hit_this_attack.clear()
		melee_hitbox.monitoring = false
	if Input.is_action_just_pressed("attack") and now >= _attack_cooldown_until_msec:
		_attack_cooldown_until_msec = now + int(ATTACK_COOLDOWN * 1000)
		_attack_active_until_msec = now + int(ATTACK_DURATION * 1000)
		_hit_this_attack.clear()
		melee_hitbox.monitoring = true
		if animated_sprite.sprite_frames.has_animation(&"attack"):
			animated_sprite.play(&"attack")

func _on_melee_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if body in _hit_this_attack:
		return
	_hit_this_attack.append(body)
	if body.has_method("take_damage"):
		body.take_damage(MELEE_DAMAGE)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	get_tree().reload_current_scene()
