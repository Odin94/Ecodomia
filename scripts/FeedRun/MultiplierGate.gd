extends Node2D

enum KIND {ADD, MULT}

export var amount: int = 10
export var kind := KIND.ADD

func _ready():
	add_to_group("multiplier_gates")

func setAmount(new_amount: int):
	amount = new_amount
	$Label.text = "+ " + str(amount)
