extends Node2D

export var remaining_cost = 1
export(NodePath) var vendor_area_to_upgrade_path
onready var vendor_area_to_upgrade := get_node(vendor_area_to_upgrade_path) as Node2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

var upgrading_distance := 24
var cooldown_time := 0.0

var money_in_transit := 0

var coords_by_number := {
	1: Vector2(0, 0),
	2: Vector2(9, 0),
	3: Vector2(18, 0),
	4: Vector2(0, 12),
	5: Vector2(9, 12),
	6: Vector2(18, 12),
	7: Vector2(0, 24),
	8: Vector2(9, 24),
	9: Vector2(18, 24),
	0: Vector2(0, 36),
	"invisible": Vector2(9, 36)
}

func _ready():
	set_number_sprites(remaining_cost)	

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
	set_number_sprites(remaining_cost)


func set_number_sprites(num: int):
	var region_rect = $Sprite_zeroes.region_rect
	region_rect.position = coords_by_number[remaining_cost % 10]
	$Sprite_zeroes.region_rect = region_rect
	
	region_rect = $Sprite_tens.region_rect	
	if remaining_cost / 10 == 0:
		region_rect.position = coords_by_number["invisible"]
	else:
		region_rect.position = coords_by_number[remaining_cost / 10]
	$Sprite_tens.region_rect = region_rect
	
