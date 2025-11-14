extends Node2D


const ATTRACTION_DISTANCE = 500.0
const ATTRACTION_DELAY = 0.01
const GROWTH_PER_CARROT = 0.01
const BACKUP_TIMER_DURATION = 15.0
const BUCKS_PER_CARROT = 0.334
const MIN_BUCKS = 5
const STACK_SIZE = 10
const STACK_Y_OFFSET = 5.0
const BUCK_SPAWN_DELAY = 0.05
const STACK_START_OFFSET = 0.02

const FEEDRUN_BUCKS_SCENE = preload("res://scenes/FeedRun/FeedRunBucks.tscn")

var is_active := false
var attracted_carrots := []
var carrots_reached := 0
var original_scale: Vector2
var backup_timer: Timer = null

onready var animated_sprite := $AnimatedSprite

func get_node_name():
	return "FeedRunChest"


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
		
		if carrot.attraction_target != null:
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
	
	if not is_instance_valid(carrot) or carrot.attraction_target != null:
		return
	
	carrot.attract_to(self)

func on_carrot_reached():
	if not is_active:
		return
	
	carrots_reached += 1
	scale = original_scale * (1.0 + GROWTH_PER_CARROT * carrots_reached)
	
	if carrots_reached >= attracted_carrots.size():
		on_all_carrots_collected()

func spawn_bucks():
	var bucks_count = max(MIN_BUCKS, ceil(carrots_reached * BUCKS_PER_CARROT))
	var stack_count = int(ceil(float(bucks_count) / STACK_SIZE))
	
	var spawn_area_top: float
	var spawn_area_bottom: float
	
	var player = get_tree().get_nodes_in_group("FeedRunPlayer")[0]
	var player_sprite = player.get_node("AnimatedSprite")
	var player_frame = player_sprite.frames.get_frame(player_sprite.animation, player_sprite.frame)
	var player_height = player_frame.get_height() * player.scale.y
	var player_top_y = player.global_position.y - player_height / 2.0
	
	var chest_frame = animated_sprite.frames.get_frame(animated_sprite.animation, animated_sprite.frame)
	var chest_height = chest_frame.get_height() * scale.y
	
	var chest_bottom_y = global_position.y + chest_height / 2.0
	
	if chest_bottom_y < player_top_y:
		spawn_area_top = chest_bottom_y
		spawn_area_bottom = player_top_y
	else:
		spawn_area_top = player_top_y - 100
		spawn_area_bottom = player_top_y
	
	var stacks_per_batch = 3
	var stack_idx = 0
	
	while stack_idx < stack_count:
		var stacks_in_batch = min(stacks_per_batch, stack_count - stack_idx)
		var batch_stacks = []
		var max_batch_duration = 0.0
		
		for batch_idx in range(stacks_in_batch):
			var x = rand_range(-132, 132)
			var y = rand_range(spawn_area_top, spawn_area_bottom)
			var target_pos = Vector2(global_position.x + x, y)
			
			var current_stack_idx = stack_idx + batch_idx
			var bucks_in_stack = min(STACK_SIZE, bucks_count - current_stack_idx * STACK_SIZE)
			
			var stack_start_delay = batch_idx * STACK_START_OFFSET
			var stack_spawn_duration = (bucks_in_stack - 1) * BUCK_SPAWN_DELAY
			var stack_total_duration = stack_start_delay + stack_spawn_duration
			max_batch_duration = max(max_batch_duration, stack_total_duration)
			
			batch_stacks.append({
				"target_pos": target_pos,
				"bucks_in_stack": bucks_in_stack,
				"start_delay": stack_start_delay
			})
		
		for stack_data in batch_stacks:
			if stack_data.start_delay > 0:
				yield (get_tree().create_timer(stack_data.start_delay), "timeout")
			spawn_stack_bucks(stack_data.target_pos, stack_data.bucks_in_stack)
		
		var wait_time = max_batch_duration - (stacks_in_batch - 1) * STACK_START_OFFSET
		if wait_time > 0:
			yield (get_tree().create_timer(wait_time), "timeout")
		
		stack_idx += stacks_in_batch

func spawn_stack_bucks(target_pos: Vector2, bucks_in_stack: int):
	for buck_idx in range(bucks_in_stack):
		var buck = FEEDRUN_BUCKS_SCENE.instance()
		var stack_y_offset = - buck_idx * STACK_Y_OFFSET
		
		buck.setup(target_pos + Vector2(0, stack_y_offset))
		buck.scale = Vector2(1.0 / scale.x, 1.0 / scale.y)
		
		add_child(buck)
		
		if buck_idx < bucks_in_stack - 1:
			yield (get_tree().create_timer(BUCK_SPAWN_DELAY), "timeout")

func on_all_carrots_collected():
	if not is_active:
		return
	
	if not is_instance_valid(self):
		return
	
	if not is_instance_valid(animated_sprite):
		return
	
	is_active = false
	
	if backup_timer:
		if backup_timer.is_connected("timeout", self, "on_all_carrots_collected"):
			backup_timer.disconnect("timeout", self, "on_all_carrots_collected")
		backup_timer.queue_free()
		backup_timer = null
	
	if not is_instance_valid(animated_sprite):
		return
	
	animated_sprite.animation = "opening"
	animated_sprite.playing = true
	
	var last_frame = animated_sprite.frames.get_frame_count("opening") - 1
	
	yield (animated_sprite, "animation_finished")
	
	if not is_instance_valid(self) or not is_instance_valid(animated_sprite):
		return
	
	animated_sprite.frame = last_frame
	animated_sprite.playing = false

	var spawn_state = spawn_bucks()
	if spawn_state is GDScriptFunctionState:
		yield (spawn_state, "completed")
	
	if is_instance_valid(get_parent()):
		get_parent().call_deferred("on_chest_opened")
