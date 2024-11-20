extends Node2D

export var remaining_cost = 5
export(NodePath) var vendor_area_to_upgrade_path
onready var vendor_area_to_upgrade := get_node(vendor_area_to_upgrade_path) as Node2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

var upgrading_distance := 24
var cooldown_time := 0.0

var money_in_transit := 0

func _ready():
	$RichTextLabel.text = String(remaining_cost)

func _physics_process(delta):
	if remaining_cost == 0:
		vendor_area_to_upgrade.get_upgraded()
		queue_free()
	cooldown_time = max(0, cooldown_time - delta)
	if global_position.distance_to(player.global_position) < upgrading_distance and cooldown_time == 0 and remaining_cost - money_in_transit > 0:
		cooldown_time = 0.25
		var money = player.take_money()
		if money:
			money_in_transit += 1
			money.get_spent(self)
		
func receive_money():
	money_in_transit -= 1
	remaining_cost -= 1
	$RichTextLabel.text = String(remaining_cost)
