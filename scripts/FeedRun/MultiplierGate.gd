extends Node2D

enum KIND {ADD, MULT}

export var amount: int = 10
export var kind := KIND.ADD

var paired_gate: Node2D = null
var is_enabled: bool = true

onready var area := $Area2D

func _ready():
	add_to_group("multiplier_gates")


func setAmountAndKind(new_amount: int, new_kind):
	amount = new_amount
	kind = new_kind
	if amount == 0:
		$Label.text = ""
	else:
		var prefix = "x " if kind == KIND.MULT else "+ "
		$Label.text = prefix + str(amount)

func setPairedGate(gate: Node2D):
	paired_gate = gate

func disable():
	if not is_enabled:
		return
	
	is_enabled = false
	if area:
		area.monitoring = false
		area.set_deferred("monitorable", false)

func enable():
	if is_enabled:
		return
	
	is_enabled = true
	if area:
		area.monitoring = true
		area.set_deferred("monitorable", true)
