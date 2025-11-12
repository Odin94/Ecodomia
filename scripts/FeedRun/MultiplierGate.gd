extends Node2D

enum KIND {ADD, MULT}

export var amount: int = 10
export var kind := KIND.ADD

var paired_gate: Node2D = null
var is_enabled: bool = true

onready var area := $Area2D

func _ready():
	add_to_group("multiplier_gates")

func setAmount(new_amount: int):
	amount = new_amount
	if amount == 0:
		$Label.text = ""
	else:
		$Label.text = "+ " + str(amount)

func setPairedGate(gate: Node2D):
	paired_gate = gate

func disable():
	if not is_enabled:
		return
	
	is_enabled = false
	if area:
		area.monitoring = false
		area.monitorable = false

func enable():
	if is_enabled:
		return
	
	is_enabled = true
	if area:
		area.monitoring = true
		area.monitorable = true
