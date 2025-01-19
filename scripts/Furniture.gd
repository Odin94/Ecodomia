extends Node2D

export var furniture_name: String
onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var progress_bar := $Control/ProgressBar

enum STATUS {LYING_AROUND, PICKED_UP, PUT_DOWN}
var status = STATUS.LYING_AROUND

var pick_up_distance := 50
var speed := 200
var drag_factor := 0.25
var _current_velocity := Vector2.ZERO

func _ready():
	set_sprite(furniture_name)
	$Control/StatsLabel.text = get_stat_text()

func _on_PickupTimer_timeout():
	var is_picking_up = status == STATUS.PUT_DOWN and Input.is_action_pressed("FurnitureInteraction")

	if status == STATUS.LYING_AROUND or is_picking_up:
		status = STATUS.PICKED_UP
		player.held_furniture = self
		progress_bar.visible = false
		HomeBase.remove_furniture(self)

func process_lying_around(_delta):
	if global_position.distance_to(player.global_position) < pick_up_distance and not player.held_furniture:
		progress_bar.visible = true
		if $PickupTimer.is_stopped():
			$PickupTimer.start()
	else:
		$PickupTimer.stop()
		progress_bar.visible = false
	var elapsed_time = $PickupTimer.wait_time - $PickupTimer.time_left
	progress_bar.value = elapsed_time / $PickupTimer.wait_time * progress_bar.max_value


func process_picked_up(delta):
	move_to_target(player.global_position + Vector2(-20, -20), delta)


func put_down(location: Vector2):
	status = STATUS.PUT_DOWN
	self.global_position = location
	self.rotation = 0
	HomeBase.place_furniture(self)
	$PickupDelayTimer.start()

func process_put_down(_delta):
	if not $PickupDelayTimer.is_stopped():
		return

	if global_position.distance_to(player.global_position) < pick_up_distance and not player.held_furniture and Input.is_action_pressed("FurnitureInteraction"):
		progress_bar.visible = true
		if $PickupTimer.is_stopped():
			$PickupTimer.start()
	else:
		$PickupTimer.stop()
		progress_bar.visible = false
	var elapsed_time = $PickupTimer.wait_time - $PickupTimer.time_left
	progress_bar.value = elapsed_time / $PickupTimer.wait_time * progress_bar.max_value

func _physics_process(delta):
	match status:
		STATUS.LYING_AROUND:
			process_lying_around(delta)
		STATUS.PICKED_UP:
			process_picked_up(delta)
		STATUS.PUT_DOWN:
			process_put_down(delta)
		_:
			print("Furniture unknown status: ", status)

	$Control/StatsLabel.visible = HomeBase.show_stats
	$Control.set_rotation(-rotation) # always keep text upright

var sprite_by_name := {
	"painting_flowers": Vector2(0, 0),
	"painting_day": Vector2(16, 0),
	"painting_night": Vector2(32, 0),
	"sunflower": Vector2(48, 0),
	"sprout_flower": Vector2(64, 0),
	"blue_flower": Vector2(80, 0),
	"bed_green": Vector2(0, 16),
	"bed_blue": Vector2(9, 16),
	"bed_red": Vector2(18, 16),
	
	"cupboard": Vector2(32, 48),
}
var sprite_by_name_2 := {
	"bed_green": Vector2(0, 0),
	"bed_blue": Vector2(9, 0),
	"bed_red": Vector2(18, 0),
}
func set_sprite(furniture_name: String):
	$Sprite.region_rect.position = sprite_by_name.get(furniture_name, Vector2(-99, -99))
	$Sprite2.region_rect.position = sprite_by_name_2.get(furniture_name, Vector2(-99, -99))

var bonus_by_name := {
	"painting_flowers": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.50
	},
	"painting_day": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	},
	"painting_night": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	},
	"sunflower": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	},
	"sprout_flower": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	},
	"blue_flower": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	},
	"bed_green": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	},
	"bed_blue": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	},
	"bed_red": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	},
	"cupboard": {
		"type": HomeBase.BONUS_TYPE.PLAYER_SPEED,
		"amount": 0.0
	}
}
onready var bonus_type = bonus_by_name[furniture_name]["type"] # as HomeBase.BONUS_TYPE
onready var bonus_amount := bonus_by_name[furniture_name]["amount"] as float

func get_stat_text():
	var prefix = "+"
	var amount = String(bonus_amount * 100) + "%"
	var type = ""

	match bonus_type:
		HomeBase.BONUS_TYPE.NONE:
			amount = ""
			prefix = ""
		HomeBase.BONUS_TYPE.PLAYER_SPEED:
			type = "run speed"
		HomeBase.BONUS_TYPE.PRICE_REDUCTION:
			type = "prices"
			prefix = "-"
		_:
			type = "unknown"

	return prefix + amount + " " + type

func move_to_target(target: Vector2, delta, passed_speed: int = speed):
	var local_speed := passed_speed
	if global_position.distance_to(target) < 25:
		local_speed = 50
	if global_position.distance_to(target) < 2:
		return
	var direction := global_position.direction_to(target)
	var desired_velocity := direction * local_speed
	var change = (desired_velocity - _current_velocity) * drag_factor # change that slowly converges our velocity onto desired_velocity
	
	_current_velocity += change
	position += _current_velocity * delta
	look_at(global_position + _current_velocity)
