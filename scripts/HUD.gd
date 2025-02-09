extends Node2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

onready var dash_eggs = [
	$CanvasLayer/Control/DashEgg1,
	$CanvasLayer/Control/DashEgg2,
	$CanvasLayer/Control/DashEgg3,
	$CanvasLayer/Control/DashEgg4,
	$CanvasLayer/Control/DashEgg5,
]

func _physics_process(delta):
	for egg in dash_eggs:
		egg.visible = false
	for i in player.dash_skill.current_dashes:
		dash_eggs[i].visible = true
