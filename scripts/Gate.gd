extends Node2D

var moving := false

var top_target_position_offset := Vector2(0, -32)
var bottom_target_position_offset := Vector2(0, 32)

var speed := 20

func _physics_process(delta):
	if moving:
		move_to_target($TopBody, global_position + top_target_position_offset, speed * delta)
		move_to_target($BottomBody, global_position + bottom_target_position_offset, speed * delta)

func start_opening():
	$BottomBody/CollisionShape2D.disabled = true
	$TopBody/CollisionShape2D.disabled = true
	moving = true
	print("Starting to move")


func move_to_target(kinematic: KinematicBody2D, target: Vector2, delta):
	if kinematic.global_position.distance_to(target) < 2:
		return
	var velocity = kinematic.global_position.direction_to(target)

	kinematic.move_and_slide(velocity * speed)
