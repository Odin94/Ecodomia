extends Node2D

func _ready():
	$AnimatedSprite.frame = 0

func _on_AnimatedSprite_animation_finished():
	queue_free()

func play():
	$AnimatedSprite.play()
