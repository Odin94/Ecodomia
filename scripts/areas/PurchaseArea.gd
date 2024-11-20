extends Node2D

export(NodePath) var cargo_stash_path
onready var cargo_stash := get_node(cargo_stash_path) as Node2D

onready var bunnies = get_tree().get_nodes_in_group("Bunny")  # TODO: Eventually only get bunnies in your own queue

var bunnies_awaiting_satisfaction = []

func _process(delta):
	for bunny in bunnies:
		if bunny in bunnies_awaiting_satisfaction:
			continue
		if bunny.global_position.distance_to(global_position) < 2:
			var cargo = cargo_stash.spend_cargo()
			if cargo:
				# TODO: Make cargo fly to bunny
				bunnies_awaiting_satisfaction.append(bunny)
				cargo.give_to_bunny(bunny)
				yield(get_tree().create_timer(.5), "timeout")
				bunny.get_satisfied()
				bunnies = get_tree().get_nodes_in_group("Bunny") # find newly spawned bunnies
