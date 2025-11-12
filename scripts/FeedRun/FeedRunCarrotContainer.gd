extends Node2D

const CARROT_SCENE = preload("res://scenes/FeedRun/Carrot.tscn")
const SPAWN_CENTER = Vector2(0, 0)
const SPAWN_OFFSET_RANGE = 50.0
const MOVE_SPEED = 200.0
onready var X_LIMIT_RIGHT = position.x + 115.0
onready var X_LIMIT_LEFT = position.x - 115.0

var carrots := []

func _ready():
	spawn_carrots()

func _process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var move_direction = 0.0
	
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		move_direction -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		move_direction += 1.0
	
	if move_direction != 0.0:
		var new_x = position.x + move_direction * MOVE_SPEED * delta
		new_x = clamp(new_x, X_LIMIT_LEFT, X_LIMIT_RIGHT)
		position.x = new_x

func spawn_carrots():
	for _i in range(10):
		var carrot = CARROT_SCENE.instance()
		var offset = Vector2(
			rand_range(-SPAWN_OFFSET_RANGE, SPAWN_OFFSET_RANGE),
			rand_range(-SPAWN_OFFSET_RANGE, SPAWN_OFFSET_RANGE)
		)
		carrot.position = SPAWN_CENTER + offset
		add_child(carrot)
		carrots.append(carrot)

func spawn_carrots_amount(count: int):
	for _i in range(count):
		var carrot = CARROT_SCENE.instance()
		var offset = Vector2(
			rand_range(-SPAWN_OFFSET_RANGE, SPAWN_OFFSET_RANGE),
			rand_range(-SPAWN_OFFSET_RANGE, SPAWN_OFFSET_RANGE)
		)
		carrot.position = SPAWN_CENTER + offset
		add_child(carrot)
		carrots.append(carrot)
