extends Node2D

const BUNNY_SCENE = preload("res://scenes/FeedRun/Bunny.tscn")
const GATE_SPAWN_INTERVAL = 5.0
const SPAWN_INTERVAL = GATE_SPAWN_INTERVAL / 2.0
const SPAWN_CENTER = Vector2(0, -64)
const SPAWN_OFFSET_RANGE = 50.0
const SCROLL_SPEED = 100.0

var bunnies := []
var spawn_timer := SPAWN_INTERVAL

func _ready():
	pass

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		spawn_bunnies()
	
	update_bunny_positions(delta)
	remove_off_screen_bunnies()

func spawn_bunnies():
	var count = randi() % 6 + 5
	
	for _i in range(count):
		var bunny = BUNNY_SCENE.instance()
		var offset = Vector2(
			rand_range(-SPAWN_OFFSET_RANGE, SPAWN_OFFSET_RANGE),
			rand_range(-SPAWN_OFFSET_RANGE, SPAWN_OFFSET_RANGE)
		)
		bunny.position = SPAWN_CENTER + offset
		add_child(bunny)
		bunnies.append(bunny)

func update_bunny_positions(delta):
	for bunny in bunnies:
		if is_instance_valid(bunny):
			bunny.position.y += SCROLL_SPEED * delta

func remove_off_screen_bunnies():
	var viewport_height = get_viewport().get_visible_rect().size.y
	var removal_threshold = viewport_height + 100
	
	for i in range(bunnies.size() - 1, -1, -1):
		var bunny = bunnies[i]
		if not is_instance_valid(bunny) or bunny.position.y > removal_threshold:
			if is_instance_valid(bunny):
				bunny.queue_free()
			bunnies.remove(i)
