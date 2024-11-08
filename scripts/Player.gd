extends KinematicBody2D

var velocity := Vector2()
var direction := Vector2()
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
	velocity = move_and_slide(velocity * 500)
	
