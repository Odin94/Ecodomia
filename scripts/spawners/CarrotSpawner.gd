extends Node2D

var cargo_scene = load("res://scenes/Cargo.tscn")

var rng = RandomNumberGenerator.new()

var spawned_carrots := []
var max_untouched_carrots := 50

func _ready():
	rng.randomize()

func _on_SpawnTimer_timeout():
	spawned_carrots = _get_untouched_spawned_carrots()
	if spawned_carrots.size() >= max_untouched_carrots:
		return

	var x = rng.randf_range(-32, 32)
	var y = rng.randf_range(-32, 32)
	
	var cargo = cargo_scene.instance()
	cargo.global_position = global_position
	cargo.status = cargo.STATUS.SPAWNING
	cargo._current_velocity = cargo.speed * Vector2.UP * 2
	cargo.target = global_position + Vector2(x, y)
	get_parent().add_child(cargo)
	spawned_carrots.append(cargo)
	
	$SpawnTimer.wait_time = rng.randf_range(.1, 12)


func _get_untouched_spawned_carrots():
	var filtered_spawned_carrots := []
	for carrot in spawned_carrots:
		if carrot.status == carrot.STATUS.SPAWNING or carrot.status == carrot.STATUS.UNHARVESTED:
			filtered_spawned_carrots.append(carrot)

	return filtered_spawned_carrots
