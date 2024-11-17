extends Node2D


enum STATUS {UNHARVESTED, PICKING_UP, PICKED_UP, PUTTING_DOWN, PUT_DOWN}

var pick_up_distance := 50
var speed := 200

var status = STATUS.UNHARVESTED
onready var player = get_tree().get_nodes_in_group("Player")[0]

var _current_velocity := Vector2.ZERO
var drag_factor = 0.25


func move_to_target(target: Vector2, delta):
	var local_speed := speed
	if global_position.distance_to(target) < 25:
		local_speed = 50
	if global_position.distance_to(target) < 5:
		return
	var direction := global_position.direction_to(target)
	var desired_velocity := direction * local_speed
	var change = (desired_velocity - _current_velocity) * drag_factor  # change that slowly converges our velocity onto desired_velocity
	
	_current_velocity += change
	position += _current_velocity * delta
	look_at(global_position + _current_velocity)

func process_unharvested():
	if global_position.distance_to(player.global_position) < pick_up_distance:
		status = STATUS.PICKING_UP
		_current_velocity = speed * (global_position - player.global_position).normalized() * 8  # vector away from player
		
func process_picking_up(delta):
	var target = player.get_pickup_location()
	
	move_to_target(target, delta)
	
	if global_position.distance_to(target) < 5:
		player.collected_cargo.append(self)
		status = STATUS.PICKED_UP
	
	# TODO: Put area2d on player at pickup_location and transition state when entering it? Or just work off of distance?

func process_picked_up(delta):
	# player script handles movement now	
	pass
	# put drop-off zones in groups and look for distance to them here


func _physics_process(delta):
	match status:
		STATUS.UNHARVESTED:
			process_unharvested()
		STATUS.PICKING_UP:
			process_picking_up(delta)
		STATUS.PICKED_UP:
			process_picked_up(delta)
		STATUS.PUTTING_DOWN:
			print("The object is being put down.")
		STATUS.PUT_DOWN:
			print("The object has been put down.")
		_:
			print("Unknown status.")
 
