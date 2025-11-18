extends Node2D

var smoke_cloud_scene = load("res://scenes/FX/SmokeCloud.tscn")
onready var player = get_tree().get_nodes_in_group("Player")[0]

var staffing_distance = 24

var _is_staffed := false
var staff_upgrade_purchased := false

func _physics_process(_delta):
	if not staff_upgrade_purchased:
		_is_staffed = global_position.distance_to(player.global_position) < staffing_distance


func is_staffed():
	return staff_upgrade_purchased or _is_staffed

func upgrade():
	var smoke_cloud := smoke_cloud_scene.instance() as Node2D
	smoke_cloud.global_position = global_position - Vector2(0, 32)
	smoke_cloud.scale = Vector2(1.5, 1.5)
	owner.add_child(smoke_cloud)
	smoke_cloud.play()
	
	yield (get_tree().create_timer(.3), "timeout")
	staff_upgrade_purchased = true
	$AnimatedSprite.visible = true
