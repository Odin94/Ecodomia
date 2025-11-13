extends Node2D

var bunnies := []
var scroll_speed: float

func _ready():
	scroll_speed = get_parent().SCROLL_SPEED

func _process(delta):
	update_bunny_positions(delta)
	remove_off_screen_bunnies()

func update_bunny_positions(delta):
	for bunny in bunnies:
		if is_instance_valid(bunny):
			bunny.position.y += scroll_speed * delta

func remove_off_screen_bunnies():
	var viewport_height = get_viewport().get_visible_rect().size.y
	var removal_threshold = viewport_height + 100
	
	for i in range(bunnies.size() - 1, -1, -1):
		var bunny = bunnies[i]
		if not is_instance_valid(bunny) or bunny.position.y > removal_threshold:
			if is_instance_valid(bunny):
				bunny.queue_free()
			bunnies.remove(i)
