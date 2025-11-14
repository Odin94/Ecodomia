extends Node2D

var speed := 200
var _current_velocity := Vector2.ZERO
var drag_factor := 0.25
var target: Vector2

func _ready():
	pass

func setup(target_pos: Vector2):
	_current_velocity = speed * Vector2.UP * 2

	target = target_pos

func move_to_target(target_pos: Vector2, delta, passed_speed: int = speed):
	var local_speed := passed_speed
	if global_position.distance_to(target_pos) < 25:
		local_speed = 50
	if global_position.distance_to(target_pos) < 2:
		return
	var direction := global_position.direction_to(target_pos)
	var desired_velocity := direction * local_speed
	var change = (desired_velocity - _current_velocity) * drag_factor
	
	_current_velocity += change
	position += _current_velocity * delta

func _physics_process(delta):
	move_to_target(target, delta, 100)
