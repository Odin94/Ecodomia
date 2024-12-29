extends KinematicBody2D

var velocity := Vector2()
var direction := Vector2()

var speed := 200

var collected_cargo := []
var collected_money := []
var held_furniture = null # set by Furniture

func walk():
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
		$AnimatedSprite.animation = "running"
	else:
		$AnimatedSprite.animation = "idle"
		
	velocity = move_and_slide(velocity * speed)
	

func _physics_process(_delta):
	walk()

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
