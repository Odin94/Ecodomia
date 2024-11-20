extends Node2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

var staffing_distance = 24

var _is_staffed := false
var staff_upgrade_purchased := false

func _physics_process(delta):
	if not staff_upgrade_purchased:
		_is_staffed = global_position.distance_to(player.global_position) < staffing_distance


func is_staffed():
	return staff_upgrade_purchased or _is_staffed

func get_upgraded():
	staff_upgrade_purchased = true
