extends Node2D

const ATTRACTION_DISTANCE = 220.0
const WALK_OFF_SPEED = 150.0
const PLAYER_CLOSE_DISTANCE = 50.0

enum State {WALKING, CONNECTED, WALKING_OFF, SAD_NO_CARROT}

var state = State.WALKING
var connected_carrot: Node2D = null
var walk_off_direction: float = 0.0
onready var player: Node2D = get_tree().get_nodes_in_group("FeedRunPlayer")[0]

onready var animated_sprite := $AnimatedSprite
onready var happy_emoji := $Happy
onready var sad_emoji := $Sad

func _process(_delta):
	check_off_screen()
	
	if state == State.WALKING:
		if connected_carrot != null and not is_instance_valid(connected_carrot):
			connected_carrot = null
		check_for_carrots()
		check_player_proximity()
	elif state == State.SAD_NO_CARROT:
		pass
	elif state == State.CONNECTED:
		# Carrot will call back on connection 
		if not is_instance_valid(connected_carrot):
			start_walking_off()

	elif state == State.WALKING_OFF:
		position.x += walk_off_direction * WALK_OFF_SPEED * _delta

func check_off_screen():
	var viewport_height = get_viewport().get_visible_rect().size.y
	var removal_threshold = viewport_height + 100
	
	if position.y > removal_threshold:
		queue_free()

func check_for_carrots():
	if state == State.SAD_NO_CARROT:
		return
	
	if connected_carrot != null:
		return
	
	var carrots = get_tree().get_nodes_in_group("carrots")
	
	if carrots.empty():
		return
	
	for carrot in carrots:
		if not is_instance_valid(carrot):
			continue
		
		if carrot.attraction_target != null:
			continue
		
		var y_distance = abs(global_position.y - carrot.global_position.y)
		
		if y_distance <= ATTRACTION_DISTANCE:
			connect_to_carrot(carrot)
			break

func check_player_proximity():
	if state == State.CONNECTED or state == State.WALKING_OFF or state == State.SAD_NO_CARROT:
		return
	
	var carrots = get_tree().get_nodes_in_group("carrots")
	var valid_carrots = []
	for carrot in carrots:
		if is_instance_valid(carrot) and carrot.attraction_target == null:
			valid_carrots.append(carrot)
	
	if not valid_carrots.empty():
		if not animated_sprite.playing or animated_sprite.animation != "walk down":
			animated_sprite.animation = "walk down"
			animated_sprite.playing = true
		return

	var y_distance = abs(global_position.y - player.global_position.y)
	if y_distance <= PLAYER_CLOSE_DISTANCE:
		state = State.SAD_NO_CARROT
		sad_emoji.visible = true
		sad_emoji.play("default")
		animated_sprite.animation = "stand down"
		animated_sprite.stop()
	else:
		if not animated_sprite.playing or animated_sprite.animation != "walk down":
			animated_sprite.animation = "walk down"
			animated_sprite.playing = true

func connect_to_carrot(carrot: Node2D):
	if state != State.WALKING:
		return
	
	connected_carrot = carrot
	carrot.attract_to(self)

func on_carrot_reached():
	if state == State.WALKING and connected_carrot != null:
		state = State.CONNECTED
		animated_sprite.animation = "stand down"
		show_happy_emoji()
		start_walking_off()

func show_happy_emoji():
	happy_emoji.visible = true
	happy_emoji.play("default")
	yield (happy_emoji, "animation_finished")
	yield (get_tree().create_timer(1.0), "timeout")
	happy_emoji.visible = false
	happy_emoji.stop()

func start_walking_off():
	if state != State.CONNECTED:
		return
	
	state = State.WALKING_OFF
	connected_carrot = null
	
	walk_off_direction = 1.0 if randf() > 0.5 else -1.0
	
	if walk_off_direction > 0:
		animated_sprite.animation = "walk right"
	else:
		animated_sprite.animation = "walk left"
