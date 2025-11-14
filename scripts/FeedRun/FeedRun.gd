extends Node2D

# TODOdin: 
# * Carrot spawn animation
# * golden mega-carrots & mega-bunnies
# * speed up time / movement
# * designed levels instead of randomness
# * Entering/exiting FeedRun and rewards
# * Carrot-eating obstacles to avoid
# * Better rewards if more carrots left over at the end


# Challenging level design options:
# * Bunnies so close to gate that they start eating carrots before you reach the gate -> +gate is better than x-gate unexpectedly
# * +-gates that add more than you'd get from mult-gates
# * Multiple gates in close succession where you can't switch sides fast enough and an unexpected side is better

export var level_name: String = "feedrun_level_2"

const SCROLL_SPEED = 100.0
const DEFAULT_WAIT_MILLIS = 5000.0

const MULTIPLIER_GATE_SCENE = preload("res://scenes/FeedRun/MultiplierGate.tscn")
const BUNNY_SCENE = preload("res://scenes/FeedRun/Bunny.tscn")
const CHEST_SCENE = preload("res://scenes/FeedRun/FeedRunChest.tscn")
const GATE_X_POSITIONS = [425.0, 600.0]
const GATE_SCALE = Vector2(2.6, 2.0)
const INITIAL_Y_OFFSET = -32.0
const SPAWN_CENTER = Vector2(0, -64)
const BUNNY_SPAWN_OFFSET_RANGE_X = 168.0
const BUNNY_SPAWN_OFFSET_RANGE_Y = 50.0

var level_data: Dictionary = {}
var current_entry_index := 0
var wait_timer := 0.0
var current_wait_time := 0.0
var is_processing_level := false
var chest: Node2D = null
var is_scrolling_chest := false
const CHEST_PLAYER_CLOSE_DISTANCE = 250.0

onready var multiplier_gates_node := $Background/MultiplierGates
onready var bunny_container_node := $BunnyContainer
onready var background_node := $Background

func _ready():
	load_level_data()
	if not level_data.empty():
		is_processing_level = true
		process_current_entry()
		current_wait_time = get_wait_time_for_entry(current_entry_index)
		current_entry_index += 1

func _process(delta):
	if not is_processing_level:
		return
	
	wait_timer += delta * 1000.0
	
	if wait_timer >= current_wait_time:
		wait_timer = wait_timer - current_wait_time
		
		if current_entry_index >= level_data.get("data", []).size():
			is_processing_level = false
			end_run_spawn_chest()
			return
		
		process_current_entry()
		current_wait_time = get_wait_time_for_entry(current_entry_index)
		current_entry_index += 1

func load_level_data():
	var file_path = "res://scripts/FeedRun/levels/" + level_name + ".json"
	var file = File.new()
	
	if not file.file_exists(file_path):
		push_error("Level file not found: " + file_path)
		return
	
	file.open(file_path, File.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var json_parse_result = JSON.parse(json_text)
	
	if json_parse_result.error != OK:
		push_error("Failed to parse JSON: " + str(json_parse_result.error_string))
		return
	
	level_data = json_parse_result.result

func get_wait_time_for_entry(entry_index: int) -> float:
	if entry_index < 0 or entry_index >= level_data.get("data", []).size():
		return DEFAULT_WAIT_MILLIS
	
	var entry = level_data.get("data", [])[entry_index]
	if entry.has("wait_millis"):
		return entry["wait_millis"]
	return DEFAULT_WAIT_MILLIS

func process_current_entry():
	if current_entry_index >= level_data.get("data", []).size():
		return
	
	var entry = level_data.get("data", [])[current_entry_index]
	
	if entry.has("gates"):
		spawn_gates_from_data(entry["gates"])
	
	if entry.has("bunnies"):
		spawn_bunnies_from_data(entry["bunnies"])

func spawn_gates_from_data(gates_data: Array):
	var gate_pair := []
	
	for i in range(min(gates_data.size(), GATE_X_POSITIONS.size())):
		var gate_data = gates_data[i]
		var gate = MULTIPLIER_GATE_SCENE.instance()
		gate.position = Vector2(GATE_X_POSITIONS[i], INITIAL_Y_OFFSET)
		gate.scale = GATE_SCALE
		
		var gate_kind = gate.KIND.ADD if gate_data.get("type", "ADD") == "ADD" else gate.KIND.MULT
		var gate_amount = gate_data.get("amount", 0)
		
		gate.setAmountAndKind(gate_amount, gate_kind)
		multiplier_gates_node.add_child(gate)
		multiplier_gates_node.gates.append(gate)
		gate_pair.append(gate)
	
	if gate_pair.size() == 2:
		gate_pair[0].setPairedGate(gate_pair[1])
		gate_pair[1].setPairedGate(gate_pair[0])

func spawn_bunnies_from_data(bunnies_data: Dictionary):
	var count = bunnies_data.get("amount", 0)
	
	for _i in range(count):
		var bunny = BUNNY_SCENE.instance()
		var offset = Vector2(
			rand_range(-BUNNY_SPAWN_OFFSET_RANGE_X, BUNNY_SPAWN_OFFSET_RANGE_X),
			rand_range(-BUNNY_SPAWN_OFFSET_RANGE_Y, BUNNY_SPAWN_OFFSET_RANGE_Y)
		)
		bunny.position = SPAWN_CENTER + offset
		bunny_container_node.add_child(bunny)
		bunny_container_node.bunnies.append(bunny)


func end_run_spawn_chest():
	chest = CHEST_SCENE.instance()
	chest.position = Vector2(bunny_container_node.position.x, SPAWN_CENTER.y)
	add_child(chest)
	is_scrolling_chest = true
	scroll_chest_coroutine()

func scroll_chest_coroutine():
	while is_scrolling_chest and is_instance_valid(chest):
		var player_nodes = get_tree().get_nodes_in_group("FeedRunPlayer")
		var player = player_nodes[0]

		var player_pos = player.global_position
		var chest_pos = chest.global_position
		
		var distance = abs(chest_pos.y - player_pos.y)
		
		if distance <= CHEST_PLAYER_CLOSE_DISTANCE:
			is_scrolling_chest = false
			if background_node.has_method("set_should_scroll"):
				background_node.set_should_scroll(false)
			yield (get_tree().create_timer(1.0), "timeout")
			chest.activate()
		else:
			var delta = get_process_delta_time()
			chest.position.y += SCROLL_SPEED * delta
			
			yield (get_tree(), "idle_frame")

func on_chest_opened():
	yield (get_tree().create_timer(2.0), "timeout")
	
	var viewport_size = get_viewport().get_visible_rect().size
	
	var fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.rect_size = viewport_size
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(fade_overlay)
	add_child(canvas_layer)
	
	var fade_duration = 1.0
	var fade_time = 0.0
	
	while fade_time < fade_duration:
		fade_time += get_process_delta_time()
		var alpha = fade_time / fade_duration
		fade_overlay.color.a = alpha
		yield (get_tree(), "idle_frame")
	
	fade_overlay.color.a = 1.0
	
	if is_instance_valid(chest):
		chest.queue_free()
	chest = null
	is_scrolling_chest = false
