extends Node2D

var bunny_scene = load("res://scenes/Bunny.tscn")

export(NodePath) var target_area_path
onready var target_area = get_node(target_area_path) as Node2D if target_area_path != "" else null

export(NodePath) var money_drop_off_area_path
onready var money_drop_off_area = get_node(money_drop_off_area_path) as Node2D if money_drop_off_area_path != "" else null

var spawned_bunnies = []
var pause_bunny_spawning := false

func _ready():
	assert(is_instance_valid(target_area), "Invalid target area with path: " + target_area_path)
	assert(is_instance_valid(money_drop_off_area), "Invalid money_drop_off_area with path: " + money_drop_off_area_path)

func _physics_process(_delta):
	spawned_bunnies = get_un_freed_bunnies()


func get_un_freed_bunnies():
	var bunnies_to_keep = []
	for bunny in spawned_bunnies:
		if is_instance_valid(bunny):
			bunnies_to_keep.append(bunny)
	return bunnies_to_keep


func _on_BunnySpawnTimer_timeout():
	if pause_bunny_spawning:
		return
	if spawned_bunnies.size() < 10:
		var bunny = bunny_scene.instance()
		bunny.money_drop_off_area = money_drop_off_area
		bunny.target_area = target_area
		bunny.bunny_spawner = self
		bunny.global_position = global_position
		owner.add_child(bunny) # adds bunny to root node of current scene, rather than root node of everything
		spawned_bunnies.append(bunny)
