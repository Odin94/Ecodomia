extends Node2D

export(NodePath) var cargo_stash_path
onready var cargo_stash = get_node(cargo_stash_path) as Node2D if cargo_stash_path != "" else null

export(NodePath) var bunny_spawner_path
onready var bunny_spawner = get_node(bunny_spawner_path) as Node2D if bunny_spawner_path != "" else null

onready var vendor_area: Node2D = get_closest_node("VendorArea")
onready var money_drop_off_area: Node2D = get_closest_node("MoneyDropOffArea")

var bunnies_awaiting_satisfaction = []

func _ready():
	assert(is_instance_valid(vendor_area), "Invalid vendor_area in purchase_area, maybe none is nearby?")
	assert(is_instance_valid(money_drop_off_area), "Invalid money_drop_off_area in purchase_area, maybe none is nearby?")


func _process(_delta):
	for bunny in bunny_spawner.spawned_bunnies:
		if bunny in bunnies_awaiting_satisfaction:
			continue
		if bunny.global_position.distance_to(global_position) < 2 \
		and vendor_area.is_staffed() \
		and not money_drop_off_area.is_full():
			var cargo = cargo_stash.spend_cargo()
			if cargo:
				bunnies_awaiting_satisfaction.append(bunny)
				cargo.give_to_bunny(bunny)
				yield (get_tree().create_timer(.5), "timeout")
				bunny.get_satisfied()


func get_closest_node(type: String) -> Node2D:
	var closest_node = null
	var closest_distance = 200 # must be at least this close
	var nodes = get_tree().get_nodes_in_group(type)
	
	for node in nodes:
		var distance = global_position.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node
	
	return closest_node
