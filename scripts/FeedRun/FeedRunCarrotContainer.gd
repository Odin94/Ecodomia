extends Node2D

const CARROT_SCENE = preload("res://scenes/FeedRun/Carrot.tscn")
const SPAWN_CENTER = Vector2(0, 0)
const SPAWN_OFFSET_RANGE_X = 150.0
const SPAWN_OFFSET_RANGE_Y = 50.0
const MOVE_SPEED = 200.0
const COLLISION_DISABLE_THRESHOLD = 300
const COLLISION_ENABLE_THRESHOLD = 200
onready var X_LIMIT_RIGHT = position.x + 115.0
onready var X_LIMIT_LEFT = position.x - 115.0

var carrots := []
var collisions_enabled := true

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

func get_random_ellipse_offset() -> Vector2:
	var angle = randf() * 2.0 * PI
	var radius = sqrt(randf())
	var x = radius * cos(angle) * SPAWN_OFFSET_RANGE_X
	var y = radius * sin(angle) * SPAWN_OFFSET_RANGE_Y
	return Vector2(x, y)

func spawn_carrots():
	for _i in range(10):
		var carrot = CARROT_SCENE.instance()
		var offset = get_random_ellipse_offset()
		carrot.position = SPAWN_CENTER + offset
		add_child(carrot)
		carrots.append(carrot)

func spawn_carrots_amount(count: int):
	for _i in range(count):
		var carrot = CARROT_SCENE.instance()
		var offset = get_random_ellipse_offset()
		carrot.position = SPAWN_CENTER + offset
		add_child(carrot)
		carrots.append(carrot)

func multiply_carrots(multiplier: int):
	var current_carrots = get_tree().get_nodes_in_group("carrots")
	var valid_carrots = []
	for carrot in current_carrots:
		if is_instance_valid(carrot) and not carrot.is_attracted:
			valid_carrots.append(carrot)
	
	var current_count = valid_carrots.size()
	var new_carrots_to_spawn = (current_count * multiplier) - current_count
	
	if new_carrots_to_spawn > 0:
		spawn_carrots_amount(new_carrots_to_spawn)
