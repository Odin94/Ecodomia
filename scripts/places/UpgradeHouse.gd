extends Node2D

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var position_when_bought := global_position

var min_opacity := 0.2
var max_opacity := 1.0
var current_opacity := 1.0
var opacity_delta := 2


func _ready():
	visible = false
	$Roof.visible = true
	global_position = Vector2(-9999999, -9999999)  # hide until purchased
	yield (get_tree().create_timer(2), "timeout")


func _physics_process(delta):
	current_opacity = min(current_opacity + delta * opacity_delta, max_opacity)
	for body in $HouseArea.get_overlapping_bodies():
		if body == player:
			current_opacity = max(current_opacity - delta * opacity_delta * 2 , min_opacity)
	$Roof.modulate.a = current_opacity


# triggered by upgrader
func purchase():
	global_position = position_when_bought
	$SmokeCloud.visible = true
	$SmokeCloud.play()
	yield (get_tree().create_timer(.2), "timeout")
	visible = true
