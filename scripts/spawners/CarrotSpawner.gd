extends Node2D

var cargo_scene = load("res://scenes/Cargo.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _on_SpawnTimer_timeout():
	var x = rng.randf_range(-32, 32)
	var y = rng.randf_range(-32, 32)
	
	var cargo = cargo_scene.instance()
	cargo.global_position = global_position
	cargo.status = cargo.STATUS.SPAWNING
	cargo._current_velocity = cargo.speed * Vector2.UP * 2
	cargo.target = global_position + Vector2(x, y)
	get_parent().add_child(cargo)
	
	$SpawnTimer.wait_time = rng.randf_range(.1, 12)
