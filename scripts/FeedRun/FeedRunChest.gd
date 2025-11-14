extends Node2D

const ATTRACTION_DISTANCE = 500.0
const ATTRACTION_DELAY = 0.01
const GROWTH_PER_CARROT = 0.01
const BACKUP_TIMER_DURATION = 10.0

var is_active := false
var attracted_carrots := []
var carrots_reached := 0
var original_scale: Vector2
var backup_timer: Timer = null

onready var animated_sprite := $AnimatedSprite

func _ready():
	original_scale = scale

func activate():
	if is_active:
		return
	
	is_active = true
	attracted_carrots.clear()
	carrots_reached = 0
	scale = original_scale
	
	if backup_timer:
		backup_timer.queue_free()
	
	backup_timer = Timer.new()
	backup_timer.wait_time = BACKUP_TIMER_DURATION
	backup_timer.one_shot = true
	add_child(backup_timer)
	backup_timer.connect("timeout", self, "on_all_carrots_collected")
	backup_timer.start()
	
	animated_sprite.animation = "default"
	animated_sprite.playing = true
	
	find_and_attract_carrots()

func find_and_attract_carrots():
	var carrots = get_tree().get_nodes_in_group("carrots")
	var nearby_carrots := []
	
	for carrot in carrots:
		if not is_instance_valid(carrot):
			continue
		
		if carrot.is_attracted:
			continue
		
		var distance = global_position.distance_to(carrot.global_position)
		if distance <= ATTRACTION_DISTANCE:
			nearby_carrots.append(carrot)
	
	if nearby_carrots.empty():
		on_all_carrots_collected()
		return
	
	var delay = 0.0
	for carrot in nearby_carrots:
		attracted_carrots.append(carrot)
		attract_carrot_with_delay(carrot, delay)
		delay += ATTRACTION_DELAY

func attract_carrot_with_delay(carrot: Node2D, delay: float):
	if delay > 0:
		yield (get_tree().create_timer(delay), "timeout")
	
	if not is_instance_valid(carrot) or carrot.is_attracted:
		return
	
	carrot.attract_to(self)

func on_carrot_reached():
	if not is_active:
		return
	
	carrots_reached += 1
	scale = original_scale * (1.0 + GROWTH_PER_CARROT * carrots_reached)
	
	if carrots_reached >= attracted_carrots.size():
		on_all_carrots_collected()

func on_all_carrots_collected():
	if not is_active:
		return
	is_active = false
	
	if backup_timer:
		backup_timer.queue_free()
		backup_timer = null
	
	animated_sprite.animation = "opening"
	animated_sprite.playing = true
	
	yield (animated_sprite, "animation_finished")
	
	animated_sprite.animation = "default"
	animated_sprite.playing = false

	get_parent().call_deferred("on_chest_opened")
