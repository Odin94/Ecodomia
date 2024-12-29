extends Node2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

var speed := 400.0
var grid_size := 32
var target := Vector2.ZERO

func _ready():
	self.visible = false

func _physics_process(delta):
	if player.held_furniture:
		self.visible = true
		target = snap_to_grid(player.global_position)
		target = adjust_for_movement_keys(target)
		
		move_to_target(target, delta)
		
		if Input.is_action_just_pressed("FurnitureInteraction"):
			var furniture = player.held_furniture
			player.held_furniture = null
			furniture.put_down(target)
	else:
		self.visible = false
		self.global_position = player.global_position
		
		
func snap_to_grid(pos: Vector2):
	return Vector2(
		round(pos.x / grid_size) * grid_size,
		round(pos.y / grid_size) * grid_size
	)


func adjust_for_movement_keys(target: Vector2) -> Vector2:
	var result = Vector2(target.x, target.y)
	if Input.is_action_pressed("up"):
		result.y -= grid_size
	if Input.is_action_pressed("down"):
		result.y += grid_size
	if Input.is_action_pressed("left"):
		result.x -= grid_size
	if Input.is_action_pressed("right"):
		result.x += grid_size
	return result

func move_to_target(target: Vector2, delta):
	var local_speed := speed
	if global_position.distance_to(target) < 15:
		local_speed = speed / 2
	if global_position.distance_to(target) < 5:
		local_speed = speed / 4
	if global_position.distance_to(target) < 1:
		return
	var direction := global_position.direction_to(target)
	var velocity := direction * local_speed
	
	position += velocity * delta
