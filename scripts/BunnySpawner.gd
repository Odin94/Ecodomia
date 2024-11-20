extends Node2D

var bunny_scene = load("res://scenes/Bunny.tscn")

export(NodePath) var target_area_path
onready var target_area := get_node(target_area_path) as Node2D

var spawned_bunnies = []

func _ready():
	print("Spawner", target_area)

func _physics_process(delta):
	spawned_bunnies = get_un_freed_bunnies()


func get_un_freed_bunnies():
	var bunnies_to_keep = []
	for bunny in spawned_bunnies:
		if is_instance_valid(bunny):
			bunnies_to_keep.append(bunny)
	return bunnies_to_keep


func _on_BunnySpawnTimer_timeout():
	if spawned_bunnies.size() < 10:
		var bunny = bunny_scene.instance()
		bunny.target_area_path = target_area_path
		bunny.target_area = target_area  # TODO: only set target_area in Bunny.gd if target_area_path is set and then only set target_area here? Would save some trouble
		bunny.global_position = global_position
		owner.add_child(bunny) # adds bunny to root node of current scene, rather than root node of everything
		spawned_bunnies.append(bunny)
