extends Node2D

export(NodePath) var cargo_stash_path
onready var cargo_stash := get_node(cargo_stash_path) as Node2D

export(NodePath) var bunny_spawner_path
onready var bunny_spawner := get_node(bunny_spawner_path) as Node2D

onready var vendor_area: Node2D = get_closest_vendor_area()

var bunnies_awaiting_satisfaction = []

func _process(delta):
	for bunny in bunny_spawner.spawned_bunnies:
		if bunny in bunnies_awaiting_satisfaction:
			continue
		if bunny.global_position.distance_to(global_position) < 2 and vendor_area.is_staffed():
			var cargo = cargo_stash.spend_cargo()
			if cargo:
				# TODO: Make cargo fly to bunny
				bunnies_awaiting_satisfaction.append(bunny)
				cargo.give_to_bunny(bunny)
				yield(get_tree().create_timer(.5), "timeout")
				bunny.get_satisfied()


func get_closest_vendor_area() -> Node2D:
	var closest_node = null
	var closest_distance = INF
	var nodes = get_tree().get_nodes_in_group("VendorArea")
	
	for node in nodes:
		var distance = global_position.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node
	
	return closest_node
