extends Node2D

var rng = RandomNumberGenerator.new()

onready var player = get_tree().get_nodes_in_group("Player")[0]
var drop_off_area: Node2D

enum STATUS {DROPPING_OFF, LYING_AROUND, FOLLOWING_PLAYER}

var pick_up_distance := 50
var speed := 200
var _current_velocity := Vector2.ZERO
var drag_factor = 0.25

var status = STATUS.DROPPING_OFF
var is_in_pickup_delay := false

var target := global_position

# When added to a MoneyDropOffArea's stash, the area sets this money's target (TODO: manage all money movement in one single script?)

func process_dropping_off(delta):
	move_to_target(target, delta)
	if global_position.distance_to(target) < 2:
		status = STATUS.LYING_AROUND
	
	
func process_lying_around(delta):
	if global_position.distance_to(player.global_position) < pick_up_distance:
		get_picked_up()


func process_following_player(delta):
	var target = player.get_pickup_location()
	move_to_target(target, delta)
	

func _physics_process(delta):
	match status:
		STATUS.DROPPING_OFF:
			process_dropping_off(delta)
		STATUS.LYING_AROUND:
			process_lying_around(delta)
		STATUS.FOLLOWING_PLAYER:
			process_following_player(delta)
		_:
			print("Money unknown status: ", status)
		

func get_picked_up():
	if is_in_pickup_delay:
		return

	print("picked up!")
	is_in_pickup_delay = true
	drop_off_area.stash.erase(self)

	var delay = rng.randf_range(0.05, 0.2)
	yield(get_tree().create_timer(delay), "timeout")
	status = STATUS.FOLLOWING_PLAYER


func move_to_target(target: Vector2, delta):
	var local_speed := speed
	if global_position.distance_to(target) < 25:
		local_speed = 50
	if global_position.distance_to(target) < 1:
		return
	var direction := global_position.direction_to(target)
	var desired_velocity := direction * local_speed
	var change = (desired_velocity - _current_velocity) * drag_factor  # change that slowly converges our velocity onto desired_velocity
	
	_current_velocity += change
	position += _current_velocity * delta
	look_at(global_position + _current_velocity)
