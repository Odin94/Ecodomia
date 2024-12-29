extends Node2D

export var furniture_name: String
onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var progress_bar := $Control/ProgressBar

enum STATUS {LYING_AROUND, PICKING_UP, PICKED_UP, PUT_DOWN}
var status = STATUS.LYING_AROUND

var pick_up_distance := 50
var speed := 200
var drag_factor := 0.25
var _current_velocity := Vector2.ZERO

func _ready():
	set_sprite(furniture_name)

func _on_PickupTimer_timeout():
	status = STATUS.PICKING_UP
	progress_bar.visible = false

func process_lying_around(delta):
	if global_position.distance_to(player.global_position) < pick_up_distance and not player.held_furniture:
		progress_bar.visible = true
		if $PickupTimer.is_stopped():
			$PickupTimer.start()
	else:
		$PickupTimer.stop()
		progress_bar.visible = false
	var elapsed_time = $PickupTimer.wait_time - $PickupTimer.time_left
	progress_bar.value = elapsed_time / $PickupTimer.wait_time * progress_bar.max_value


func process_picking_up(delta):
	var target = player.get_pickup_location(self)
	move_to_target(target, delta)
	
	if global_position.distance_to(target) < 5:
		player.held_furniture = self
		status = STATUS.PICKED_UP


func process_picked_up(delta):
	move_to_target(player.get_pickup_location(self), delta)

func put_down(location: Vector2):
	status = STATUS.PUT_DOWN


func _physics_process(delta):
	match status:
		STATUS.LYING_AROUND:
			process_lying_around(delta)
		STATUS.PICKING_UP:
			process_picking_up(delta)
		STATUS.PICKED_UP:
			process_picked_up(delta)
		STATUS.PUT_DOWN:
			pass
		_:
			print("Cargo unknown status: ", status)

var furniture_sprite_by_number := {
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
var furniture_sprite_by_number_2 := {
	"bed_green": Vector2(0, 0),
	"bed_blue": Vector2(9, 0),
	"bed_red": Vector2(18, 0),
}
func set_sprite(furniture_name: String):
	$Sprite.region_rect.position = furniture_sprite_by_number.get(furniture_name, Vector2(-99, -99))
	$Sprite2.region_rect.position = furniture_sprite_by_number_2.get(furniture_name, Vector2(-99, -99))


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
