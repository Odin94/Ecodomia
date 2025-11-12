extends Node2D

const BOUNCE_HEIGHT = 8.0
const BOUNCE_DURATION = 0.4
const PAUSE_DURATION = 0.2

const REPULSION_FORCE = 80.0
const DAMPING = 0.85
const MAX_VELOCITY = 120.0

var sprite_original_y: float
var shadow_original_scale: Vector2
var tween: Tween
var velocity := Vector2.ZERO
var overlapping_carrots := []

onready var area := $Area2D
onready var sprite := $Sprite
onready var shadow := $Shadow

func _ready():
	sprite_original_y = sprite.position.y
	shadow_original_scale = shadow.scale
	start_bounce_animation()

func start_bounce_animation():
	if tween:
		tween.queue_free()
	
	tween = Tween.new()
	add_child(tween)
	bounce_up()

func bounce_up():
	tween.interpolate_property(sprite, "position:y", sprite_original_y, sprite_original_y - BOUNCE_HEIGHT, BOUNCE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_method(self, "update_shadow_scale", sprite_original_y, sprite_original_y - BOUNCE_HEIGHT, BOUNCE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	yield (tween, "tween_all_completed")
	bounce_down()

func bounce_down():
	tween.interpolate_property(sprite, "position:y", sprite_original_y - BOUNCE_HEIGHT, sprite_original_y, BOUNCE_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_method(self, "update_shadow_scale", sprite_original_y - BOUNCE_HEIGHT, sprite_original_y, BOUNCE_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield (tween, "tween_all_completed")
	yield (get_tree().create_timer(PAUSE_DURATION), "timeout")
	bounce_up()

func update_shadow_scale(sprite_y: float):
	var bounce_progress = (sprite_original_y - sprite_y) / BOUNCE_HEIGHT
	var scale_factor = 1.0 - (bounce_progress * 0.3)
	shadow.scale = shadow_original_scale * scale_factor

func _process(delta):
	apply_repulsion(delta)
	update_position(delta)

func apply_repulsion(delta):
	var repulsion_force := Vector2.ZERO
	
	for carrot in overlapping_carrots:
		if not is_instance_valid(carrot):
			overlapping_carrots.erase(carrot)
			continue
		
		var distance = global_position.distance_to(carrot.global_position)
		if distance > 0:
			var direction = (global_position - carrot.global_position).normalized()
			var force_strength = REPULSION_FORCE / max(distance, 1.0)
			repulsion_force += direction * force_strength
	
	velocity += repulsion_force * delta
	velocity = velocity.clamped(MAX_VELOCITY)

func update_position(delta):
	position += velocity * delta
	velocity *= DAMPING

func _exit_tree():
	if tween:
		tween.queue_free()

func _on_Area2D_area_entered(other_area):
	var carrot = other_area.get_parent()
	if carrot != self and carrot.is_in_group("carrots"):
		if not overlapping_carrots.has(carrot):
			overlapping_carrots.append(carrot)

func _on_Area2D_area_exited(other_area):
	var carrot = other_area.get_parent()
	if carrot != self:
		overlapping_carrots.erase(carrot)
