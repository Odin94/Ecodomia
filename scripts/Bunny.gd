extends KinematicBody2D

var money_scene = load("res://scenes/Money.tscn")

export(NodePath) var target_area_path
onready var target_area := get_node(target_area_path) as Node2D

onready var money_drop_off_area: Node2D = get_closest_money_drop_off_area()
onready var bunnies = get_tree().get_nodes_in_group("Bunny")  # TODO: Eventually only get bunnies in your own queue
var queue_position: int

var velocity := Vector2.ZERO
var speed = 50
var queue_standing_distance = 20

enum STATUS {IN_QUEUE, SATISFIED}

var status = STATUS.IN_QUEUE

func process_in_queue(delta):
	var closer_bunnies = get_closer_bunnies()
	queue_position = closer_bunnies.size()
	
	# assumes that all queues go right -> left
	var position_to_approach = target_area.global_position + Vector2(queue_standing_distance * queue_position, 0)
	move_to_target(position_to_approach, delta)
	if queue_position == 0 and global_position.distance_to(position_to_approach) < 2:
		$AnimatedSprite.animation = "stand up"

func process_satisfied(delta):
	var position_to_approach = target_area.global_position - Vector2(400, 0)
	move_to_target(position_to_approach, delta)

func _physics_process(delta):
	match status:
		STATUS.IN_QUEUE:
			process_in_queue(delta)
		STATUS.SATISFIED:
			process_satisfied(delta)
		_:
			print("Unknown status.")
	

func get_satisfied():
	status = STATUS.SATISFIED
	var money = money_scene.instance()
	money_drop_off_area.add_money(money)
	money.global_position = global_position
	get_tree().get_root().add_child(money)


func is_closer(bunny):
	var target_position = target_area.global_position
	return bunny.global_position.distance_to(target_position) < global_position.distance_to(target_position)

func get_closer_bunnies():
	var closer_bunnies = []
	for bunny in bunnies:
		if bunny.status == STATUS.IN_QUEUE and is_closer(bunny):
			closer_bunnies.append(bunny)
	return closer_bunnies

func move_to_target(target: Vector2, delta):
	if global_position.distance_to(target) < 2:
		velocity = Vector2.ZERO
		$AnimatedSprite.animation = "stand left"
		return
	$AnimatedSprite.animation = "walk left"
	velocity = global_position.direction_to(target)
	move_and_slide(velocity * speed)


func get_closest_money_drop_off_area() -> Node2D:
	var closest_node = null
	var closest_distance = INF
	var nodes = get_tree().get_nodes_in_group("MoneyDropOffArea")
	
	for node in nodes:
		var distance = global_position.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node
	
	return closest_node
