extends Node2D

onready var carrot_container := get_parent()
onready var animated_sprite := $AnimatedSprite
var processed_gates := []
var last_position_x: float = 0.0

# NOTE: Movement is in CarrotContainer!
func _ready():
	add_to_group("FeedRunPlayer")
	last_position_x = carrot_container.position.x

func _process(_delta):
	update_animation()
	
	var valid_gates := []
	for gate in processed_gates:
		valid_gates.append(gate)
	processed_gates = valid_gates

func update_animation():
	var current_x = carrot_container.position.x
	var move_direction = current_x - last_position_x
	
	if abs(move_direction) > 0.1:
		animated_sprite.animation = "running"
		if move_direction > 0:
			animated_sprite.flip_h = false
		elif move_direction < 0:
			animated_sprite.flip_h = true
	else:
		animated_sprite.animation = "idle"
	
	last_position_x = current_x

func _on_Area2D_area_entered(area):
	var gate = area.get_parent()
	if gate and gate.has_method("setAmountAndKind") and not processed_gates.has(gate) and gate.is_enabled:
		processed_gates.append(gate)
		var gate_amount = gate.amount
		var gate_kind = gate.kind
		gate.setAmountAndKind(0, gate_kind)
		gate.disable()
		
		# Disable the paired gate if it exists
		if gate.paired_gate and is_instance_valid(gate.paired_gate):
			gate.paired_gate.disable()
		
		if gate_kind == gate.KIND.MULT:
			carrot_container.call_deferred("multiply_carrots", gate_amount)
		else:
			carrot_container.call_deferred("spawn_carrots_amount", gate_amount)
