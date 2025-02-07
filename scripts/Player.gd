extends KinematicBody2D

var velocity := Vector2()
var direction := Vector2()

var dash_skill = Dash.new(self)

var original_speed := 200.0
var speed := 200.0
var current_dash_speed = dash_skill.current_dash_speed

var collected_cargo := []
var collected_money := []
var held_furniture = null # set by Furniture

func move(delta: float):
	if not dash_skill.is_dashing:
		velocity = Vector2()
		direction = Vector2()
		if Input.is_action_pressed("up"):
			velocity.y -= 1
			direction.y = -1
		if Input.is_action_pressed("down"):
			velocity.y = 1
			direction.y = 1
		if Input.is_action_pressed("left"):
			velocity.x -= 1
			direction.x = -1
		if Input.is_action_pressed("right"):
			velocity.x += 1
			direction.x = 1

		velocity = velocity.normalized() # prevent diagonal movement from being twice as fast

	if velocity.length() != 0:
		if velocity.x > 0:
			$AnimatedSprite.flip_h = false
		elif velocity.x < 0:
			$AnimatedSprite.flip_h = true
		if dash_skill.is_dashing:
			$AnimatedSprite.animation = "default"
		else:
			$AnimatedSprite.animation = "running"
	else:
		$AnimatedSprite.animation = "idle"

	# dash
	if Input.is_action_just_pressed("FurnitureInteraction") and dash_skill.current_dashes > 0 and velocity.length() > 0:
		dash_skill.dash()
	
	if dash_skill.is_dashing:
		var collision = get_last_slide_collision()
		if collision and collision.normal == -direction:
			dash_skill.cancel_dash()
		move_and_slide(velocity * dash_skill.current_dash_speed)
	else:
		move_and_slide(velocity * speed)
	

func _physics_process(delta):
	speed = original_speed * (1 + HomeBase.bonus_speed_percent)
	move(delta)


func add_cargo(cargo):
	collected_cargo.append(cargo)

func remove_cargo(cargo):
	collected_cargo.erase(cargo)

func add_money(money):
	collected_money.append(money)

func remove_money(money):
	collected_money.erase(money)

func take_money():
	if collected_money.empty():
		return null
	return collected_money.pop_front()

func get_pickup_location(cargo_or_money):
	var inventory_size = collected_cargo.size() + collected_money.size()
	var index = inventory_size
	for i in inventory_size:
		var inventory_item
		if i < collected_cargo.size():
			inventory_item = collected_cargo[i]
		else:
			inventory_item = collected_money[i - collected_cargo.size()]
		if cargo_or_money == inventory_item:
			index = i

	if $AnimatedSprite.flip_h:
		return global_position + Vector2(10, -10 - index * 5)
	return global_position + Vector2(-10, -10 - index * 5)
