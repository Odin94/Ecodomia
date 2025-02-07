extends Node

class_name Dash

var min_dash_speed := 200
var max_dash_speed := 1500
var current_dash_speed := 1500
var is_dashing := false
var dash_direction := Vector2(0, 0)

var max_dashes := 2
var current_dashes := 2

var dash_timer: Timer
var dash_duration := .3
var tween: Tween

func _init(parent: Node):
	add_child(tween)
	dash_timer = Timer.new()
	dash_timer.one_shot = true
	dash_timer.wait_time = dash_duration
	dash_timer.connect("timeout", self, "stop_dashing_after_timeout")

	parent.add_child(dash_timer)

	tween = Tween.new()
	parent.add_child(tween)

func dash():
	if not is_dashing:
		current_dashes -= 1
		recover_dash_after_timeout()
		is_dashing = true
		dash_timer.start()
		stop_dashing_after_timeout()
		
		tween.stop_all() # Stop any existing tweens
		tween.interpolate_property(
			self, "current_dash_speed", # Property to animate
			max_dash_speed, min_dash_speed, # From max to min
			dash_duration, # Time it takes
			Tween.TRANS_QUAD, # Quadratic easing
			Tween.EASE_OUT # Ease-out (fast start, slow end)
		)
		tween.start()


func cancel_dash():
	is_dashing = false
	current_dash_speed = max_dash_speed
	tween.stop_all()


func recover_dash_after_timeout():
	# TODO: Put this on an actual timer that you can use to display remaining cooldown on screen?
	yield (Engine.get_main_loop().create_timer(2), "timeout")
	current_dashes = min(max_dashes, current_dashes + 1)


func stop_dashing_after_timeout():
	yield (Engine.get_main_loop().create_timer(.4), "timeout")
	is_dashing = false
	current_dash_speed = max_dash_speed
