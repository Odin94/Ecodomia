extends KinematicBody2D

var velocity := Vector2()
var direction := Vector2()

var speed := 200

var collected_cargo := []
var collected_money := []

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
	

func update_cargo():
	var updated_cargo = []
	for cargo in collected_cargo:
		if cargo.status == cargo.STATUS.PICKED_UP:
			updated_cargo.append(cargo)
	return updated_cargo

func move_cargo(delta):
	for i in collected_cargo.size():
		var cargo = collected_cargo[i]
		cargo.move_to_target(get_pickup_location(cargo), delta)

func _physics_process(delta):
	walk()
	collected_cargo = update_cargo()
	move_cargo(delta)


func add_money(money):
	collected_money.append(money)

func remove_money(money):
	collected_money.erase(money)

func get_pickup_location(cargo_or_money):
	var inventory_size = collected_cargo.size() + collected_money.size()
	var index = inventory_size
	for i in collected_cargo.size() + collected_money.size():
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
