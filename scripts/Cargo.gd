extends Node2D


enum STATUS {SPAWNING, UNHARVESTED, PICKING_UP, PICKED_UP, PUTTING_DOWN, PUT_DOWN, FLYING_TO_BUNNY}

var pick_up_distance := 50
var speed := 200

var status = STATUS.UNHARVESTED
onready var potential_hosts = [get_tree().get_nodes_in_group("Player")[0]]
onready var cargo_stashes = get_tree().get_nodes_in_group("CargoStash")
var carrying_host: Node2D

var _current_velocity := Vector2.ZERO
var drag_factor := 0.25
var cargo_stash: Node2D
var cargo_stash_putdown_location := Vector2.ZERO

var target: Vector2

var bunny: Node2D

func move_to_target(target: Vector2, delta, passed_speed: int = speed):
	var local_speed := passed_speed
	if global_position.distance_to(target) < 25:
		local_speed = 50
	if global_position.distance_to(target) < 2:
		return
	var direction := global_position.direction_to(target)
	var desired_velocity := direction * local_speed
	var change = (desired_velocity - _current_velocity) * drag_factor # change that slowly converges our velocity onto desired_velocity
	
	_current_velocity += change
	position += _current_velocity * delta
	look_at(global_position + _current_velocity)

func process_spawning(delta):
	# target set by CarrotSpawner, TODO: Put getting target in here somehow?
	move_to_target(target, delta, 100)
	rotate(-rotation) # make carrot rotation neutral somehow..?
	
	if global_position.distance_to(target) < 5:
		status = STATUS.UNHARVESTED

func process_unharvested():
	for host in potential_hosts:
		if global_position.distance_to(host.global_position) < pick_up_distance:
			status = STATUS.PICKING_UP
			_current_velocity = speed * (global_position - host.global_position).normalized() * 8 # vector away from host
			carrying_host = host
		
func process_picking_up(delta):
	var target = carrying_host.get_pickup_location(self)
	
	move_to_target(target, delta)
	
	if global_position.distance_to(target) < 5:
		carrying_host.add_cargo(self)
		status = STATUS.PICKED_UP
	
func process_picked_up(delta):
	move_to_target(carrying_host.get_pickup_location(self), delta)

	for stash in cargo_stashes:
		if global_position.distance_to(stash.global_position) < pick_up_distance:
			carrying_host.remove_cargo(self)
			status = STATUS.PUTTING_DOWN
			cargo_stash = get_closest_cargo_stash()
			cargo_stash.add_cargo(self)

func process_put_down(delta):
	move_to_target(cargo_stash_putdown_location, delta)

func process_flying_to_bunny(delta):
	if not is_instance_valid(bunny):
		queue_free()
		return
	move_to_target(bunny.global_position, delta)

func _physics_process(delta):
	match status:
		STATUS.SPAWNING:
			process_spawning(delta)
		STATUS.UNHARVESTED:
			process_unharvested()
		STATUS.PICKING_UP:
			process_picking_up(delta)
		STATUS.PICKED_UP:
			process_picked_up(delta)
		STATUS.PUTTING_DOWN:
			process_put_down(delta)
		STATUS.PUT_DOWN:
			print("The object has been put down.")
		STATUS.FLYING_TO_BUNNY:
			process_flying_to_bunny(delta)
		_:
			print("Cargo unknown status: ", status)
 

func give_to_bunny(bunny: Node2D):
	status = STATUS.FLYING_TO_BUNNY
	self.bunny = bunny


func get_closest_cargo_stash() -> Node2D:
	var closest_node = null
	var closest_distance = INF
	var nodes = cargo_stashes
	
	for node in nodes:
		var distance = global_position.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node
	
	return closest_node


func _on_CargoBunnyTrackTimer_timeout():
	var cargo_bunnies = get_tree().get_nodes_in_group("CollectorBunny")
	for bunny in cargo_bunnies:
		if not bunny in potential_hosts:
			potential_hosts.append(bunny)
