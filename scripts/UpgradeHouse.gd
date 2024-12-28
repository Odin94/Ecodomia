extends Node2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

var min_opacity := 0.2
var max_opacity := 1.0
var current_opacity := 1.0
var opacity_delta := 2

func _ready():
	$Roof.visible = true


func _physics_process(delta):
	current_opacity = min(current_opacity + delta * opacity_delta, max_opacity)
	for body in $HouseArea.get_overlapping_bodies():
		if body == player:
			print(current_opacity - delta * opacity_delta * 2)
			current_opacity = max(current_opacity - delta * opacity_delta * 2 , min_opacity)
	$Roof.modulate.a = current_opacity
