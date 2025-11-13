extends Node2D

var gates := []
var scroll_speed: float

func _ready():
	scroll_speed = get_parent().SCROLL_SPEED

func _process(delta):
	update_gate_positions(delta)
	remove_off_screen_gates()

func update_gate_positions(delta):
	for gate in gates:
		if is_instance_valid(gate):
			gate.position.y += scroll_speed * delta

func remove_off_screen_gates():
	var viewport_height = get_viewport().get_visible_rect().size.y
	var removal_threshold = viewport_height + 100
	
	for i in range(gates.size() - 1, -1, -1):
		var gate = gates[i]
		if not is_instance_valid(gate) or gate.position.y > removal_threshold:
			if is_instance_valid(gate):
				gate.queue_free()
			gates.remove(i)
