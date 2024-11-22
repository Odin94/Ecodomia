extends KinematicBody2D

export(Array, Vector2) var way_points := [global_position]

var way_point_index := 0
var index_direction = 1

var speed = 50

var is_chilling := false

var collected_cargo := []


func process_collecting(delta):
	if is_chilling:
		return
	move_to_target(way_points[way_point_index], delta)
	if global_position.distance_to(way_points[way_point_index]) < 2:
		way_point_index += index_direction
		if way_point_index >= way_points.size() or way_point_index < 0:
			is_chilling = true
			$AnimatedSprite.play("stand down")
			yield (get_tree().create_timer(1.5), "timeout")
			is_chilling = false
			index_direction = -index_direction
			if index_direction == 1:
				way_point_index = 0
			else:
				way_point_index = way_points.size() - 1


func _physics_process(delta):
	process_collecting(delta)


func move_to_target(target: Vector2, delta):
	var velocity = Vector2.ZERO
	if global_position.distance_to(target) < 2:
		$AnimatedSprite.play("stand left")
		return
	velocity = global_position.direction_to(target)

	if velocity.x > 0:
		$AnimatedSprite.play("walk right")
	elif velocity.x < 0:
		$AnimatedSprite.play("walk left")
	elif velocity.y > 0:
		$AnimatedSprite.play("walk down")
	elif velocity.y < 0:
		$AnimatedSprite.play("walk up")
	else:
		$AnimatedSprite.play("stand down")
	

	move_and_slide(velocity * speed)


func add_cargo(cargo):
	collected_cargo.append(cargo)

func remove_cargo(cargo):
	collected_cargo.erase(cargo)

func get_pickup_location(cargo):
	var index = collected_cargo.size()
	for i in collected_cargo.size():
		var inventory_item = collected_cargo[i]
		if cargo == inventory_item:
			index = i

	if $AnimatedSprite.animation == "walk left":
		return global_position + Vector2(10, -10 - index * 5)
	return global_position + Vector2(-10, -10 - index * 5)