extends Node2D

var carrot_spawner_scene = load("res://scenes/spawners/CarrotSpawner.tscn")

export var original_cost = 15
onready var remaining_cost = original_cost
export(NodePath) var vendor_area_to_upgrade_path
onready var vendor_area_to_upgrade = get_node(vendor_area_to_upgrade_path) as Node2D if vendor_area_to_upgrade_path != "" else null

export(NodePath) var cargo_collector_to_spawn_path
onready var cargo_collector_to_spawn = get_node(cargo_collector_to_spawn_path) as Node2D if cargo_collector_to_spawn_path != "" else null

export(Vector2) var carrot_spawner_location = null

export(NodePath) var bunny_spawner_path # path to a whole set of sales nodes, eg. cargo-storage, money-dropoff, purchase-area etc.
onready var bunny_spawner = get_node(bunny_spawner_path) as Node2D if bunny_spawner_path != "" else null

export(NodePath) var gate_path
onready var gate_to_open = get_node(gate_path) as Node2D if gate_path != "" else null

export(NodePath) var purchaseable_path # Anything with a "purchase" function
onready var purchaseable = get_node(purchaseable_path) as Node2D if purchaseable_path != "" else null


export(Array, NodePath) var prerequisite_upgrades_paths = []
var prerequisite_upgrades = []

onready var player = get_tree().get_nodes_in_group("Player")[0]

var upgrading_distance := 24

var full_cooldown_time := 0.25
var min_cooldown_time = 0.05
var cooldown_reduction_factor := 0.03
var cooldown_time := full_cooldown_time
var current_cooldown_time := 0.0

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
	if bunny_spawner:
		bunny_spawner.pause_bunny_spawning = true
		
	for upgrade_path in prerequisite_upgrades_paths:
		if upgrade_path != "":
			prerequisite_upgrades.append(get_node(upgrade_path) as Node2D)
		visible = false


func perform_upgrade():
	if is_instance_valid(vendor_area_to_upgrade):
		vendor_area_to_upgrade.upgrade()
	if is_instance_valid(cargo_collector_to_spawn):
		cargo_collector_to_spawn.spawn()
	if carrot_spawner_location:
		var carrot_spawner = carrot_spawner_scene.instance()
		carrot_spawner.global_position = carrot_spawner_location
		owner.get_parent().add_child(carrot_spawner) # if we just take owner, owner will be undefined in carrot_spawner once this upgrader is queue_free'd
	if bunny_spawner:
		bunny_spawner.pause_bunny_spawning = false
	if gate_to_open:
		gate_to_open.start_opening()
		
	if is_instance_valid(purchaseable): # todo: Turn all/most of these upgradeables into purchaseables?
		purchaseable.purchase()

func _physics_process(delta):
	for upgrade in prerequisite_upgrades:
		if is_instance_valid(upgrade): # completed upgrades get freed
			return
	visible = true
	
	if remaining_cost <= 0:
		perform_upgrade()
		queue_free()
	current_cooldown_time = max(0, current_cooldown_time - delta)
	if global_position.distance_to(player.global_position) < upgrading_distance:
		cooldown_time = max(cooldown_time - delta * cooldown_reduction_factor, min_cooldown_time)
		if current_cooldown_time == 0 and remaining_cost - money_in_transit > 0:
			current_cooldown_time = cooldown_time
			var money = player.take_money()
			if money:
				money_in_transit += 1
				money.get_spent(self)
	else:
		cooldown_time = full_cooldown_time

func receive_money():
	money_in_transit -= 1
	remaining_cost -= 1
	set_number_sprites(remaining_cost)


func set_number_sprites(num: int):
	if num > 999 or num < 0:
		num = 0
	if remaining_cost / 100 == 0:
		$Sprite_zeroes.position.x = 6
		$Sprite_tens.position.x = -5
	
	var zero_vec = coords_by_number[0]
	var region_rect = $Sprite_zeroes.region_rect
	region_rect.position = coords_by_number.get(remaining_cost % 10, zero_vec)
	$Sprite_zeroes.region_rect = region_rect
	
	region_rect = $Sprite_tens.region_rect
	if remaining_cost < 10:
		region_rect.position = coords_by_number["invisible"]
	else:
		region_rect.position = coords_by_number.get(remaining_cost / 10 % 10, zero_vec)
	$Sprite_tens.region_rect = region_rect
	
	region_rect = $Sprite_hundreds.region_rect
	if remaining_cost < 100:
		region_rect.position = coords_by_number["invisible"]
	else:
		region_rect.position = coords_by_number.get(remaining_cost / 100, zero_vec)
	$Sprite_hundreds.region_rect = region_rect
