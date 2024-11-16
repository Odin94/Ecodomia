extends KinematicBody2D

var velocity := Vector2()
var direction := Vector2()

var speed := 200

func read_input():
	velocity = Vector2()
	direction = Vector2()
	if Input.is_action_pressed("up"):
		velocity.y -=1
		direction.y = -1
	if Input.is_action_pressed("down"):
		velocity.y =1
		direction.y = 1
	if Input.is_action_pressed("left"):
		velocity.x -=1
		direction.x = -1
	if Input.is_action_pressed("right"):
		velocity.x +=1
		direction.x = 1

	velocity = velocity.normalized() # prevent diagonal movement from being twice as fast

func _physics_process(delta):
	read_input()

	if velocity.x != 0:
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.animation = "running"
	else:
		$AnimatedSprite.animation = "idle"
	
	velocity = move_and_slide(velocity * speed)

	
