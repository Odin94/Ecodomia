extends Node2D

const BOUNCE_HEIGHT = 8.0
const BOUNCE_DURATION = 0.4
const PAUSE_DURATION = 0.2

const REPULSION_FORCE = 80.0
const DAMPING = 0.85
const MAX_VELOCITY = 120.0
const COLLISION_DISABLE_THRESHOLD = 300

var sprite_original_y: float
var shadow_original_scale: Vector2
var tween: Tween
var velocity := Vector2.ZERO
var overlapping_carrots := []
var attraction_target: Node2D = null
const ATTRACTION_SPEED = 300.0

onready var area := $Area2D
onready var sprite := $Sprite
onready var shadow := $Shadow
onready var carrot_container := get_parent()

func _ready():
	add_to_group("carrots")
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
	if attraction_target != null or not is_instance_valid(tween):
		return
	tween.interpolate_property(sprite, "position:y", sprite_original_y, sprite_original_y - BOUNCE_HEIGHT, BOUNCE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_method(self, "update_shadow_scale", sprite_original_y, sprite_original_y - BOUNCE_HEIGHT, BOUNCE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	yield (tween, "tween_all_completed")
	if attraction_target == null:
		bounce_down()

func bounce_down():
	if attraction_target != null or not is_instance_valid(tween):
		return
	tween.interpolate_property(sprite, "position:y", sprite_original_y - BOUNCE_HEIGHT, sprite_original_y, BOUNCE_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_method(self, "update_shadow_scale", sprite_original_y - BOUNCE_HEIGHT, sprite_original_y, BOUNCE_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield (tween, "tween_all_completed")
	if attraction_target != null:
		return
	yield (get_tree().create_timer(PAUSE_DURATION), "timeout")
	if attraction_target == null:
		bounce_up()

func update_shadow_scale(sprite_y: float):
	var bounce_progress = (sprite_original_y - sprite_y) / BOUNCE_HEIGHT
	var scale_factor = 1.0 - (bounce_progress * 0.3)
	shadow.scale = shadow_original_scale * scale_factor

func _process(delta):
	if attraction_target == null:
		apply_repulsion(delta)
		update_position(delta)
	else:
		move_towards_target(delta)

func apply_repulsion(delta):
	if not area or not area.monitoring:
		return
	if carrot_container.carrots.size() > COLLISION_DISABLE_THRESHOLD:
		return
	
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

func attract_to(target: Node2D):
	if attraction_target != null:
		return
	
	attraction_target = target
	
	if tween:
		tween.stop_all()
		tween.queue_free()
		tween = null
	
	velocity = Vector2.ZERO

func get_target_center(target: Node2D) -> Vector2:
	if not is_instance_valid(target):
		return global_position
	
	var target_center = target.global_position
	
	if target.has_method("get_node_name") and target.get_node_name() == "FeedRunChest":
		return target_center
	
	if target.has_node("AnimatedSprite"):
		var target_sprite = target.get_node("AnimatedSprite")
		if target_sprite.frames:
			var current_anim = target_sprite.animation if target_sprite.animation else "default"
			if target_sprite.frames.has_animation(current_anim):
				var frame = target_sprite.frames.get_frame(current_anim, target_sprite.frame)
				var sprite_height = frame.get_height() * target.scale.y
				target_center.y += sprite_height / 2.0
	
	return target_center

func move_towards_target(delta):
	if not is_instance_valid(attraction_target):
		attraction_target = null
		return
	
	var target_center = get_target_center(attraction_target)
	var direction = global_position.direction_to(target_center)
	var distance = global_position.distance_to(target_center)
	
	if distance < 5.0:
		if attraction_target.has_method("on_carrot_reached"):
			attraction_target.on_carrot_reached()
		queue_free()
		return
	
	var move_distance = ATTRACTION_SPEED * delta
	if move_distance > distance:
		move_distance = distance
	
	global_position += direction * move_distance
