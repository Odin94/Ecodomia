extends Node2D

const ATTRACTION_DISTANCE = 120.0
const WALK_OFF_SPEED = 150.0

enum State {WALKING, CONNECTED, WALKING_OFF}

var state = State.WALKING
var connected_carrot: Node2D = null
var walk_off_direction: float = 0.0

onready var animated_sprite := $AnimatedSprite

# TODOdin: Show heart (happy) emoji when bunny is connected to a carrot
# Stop walking and show heart-break (sad) emoji when there is no carrot and bunny is very close to player
func _ready():
	pass

func _process(_delta):
	if state == State.WALKING:
		check_for_carrots()
	elif state == State.CONNECTED:
		if not is_instance_valid(connected_carrot):
			start_walking_off()
		else:
			var distance = global_position.distance_to(connected_carrot.global_position)
			if distance < 15.0:
				start_walking_off()
	elif state == State.WALKING_OFF:
		position.x += walk_off_direction * WALK_OFF_SPEED * _delta

func check_for_carrots():
	var carrots = get_tree().get_nodes_in_group("carrots")
	
	if carrots.empty():
		return
	
	for carrot in carrots:
		if not is_instance_valid(carrot):
			continue
		
		if carrot.is_attracted:
			continue
		
		var distance = global_position.distance_to(carrot.global_position)
		
		if distance <= ATTRACTION_DISTANCE:
			connect_to_carrot(carrot)
			break

func connect_to_carrot(carrot: Node2D):
	if state != State.WALKING:
		return
	
	state = State.CONNECTED
	connected_carrot = carrot
	
	animated_sprite.animation = "stand down"
	
	carrot.attract_to_bunny(self)

func start_walking_off():
	if state != State.CONNECTED:
		return
	
	state = State.WALKING_OFF
	
	walk_off_direction = 1.0 if randf() > 0.5 else -1.0
	
	if walk_off_direction > 0:
		animated_sprite.animation = "walk right"
	else:
		animated_sprite.animation = "walk left"
