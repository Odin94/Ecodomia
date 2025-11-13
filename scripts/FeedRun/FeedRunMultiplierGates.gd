extends Node2D

const MULTIPLIER_GATE_SCENE = preload("res://scenes/FeedRun/MultiplierGate.tscn")
const SPAWN_INTERVAL = 5.0
const GATE_X_POSITIONS = [425.0, 600.0]
const GATE_SCALE = Vector2(2.6, 2.0)
const INITIAL_Y_OFFSET = -32.0
const MIN_CARROT_ADD_AMOUNT = 5
const MAX_CARROT_ADD_AMOUNT = 20
const MIN_CARROT_MULT_AMOUNT = 2
const MAX_CARROT_MULT_AMOUNT = 5

var gates := []
var spawn_timer := 0.0
var scroll_speed: float

func _ready():
	scroll_speed = get_parent().SCROLL_SPEED
	spawn_gates()

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		spawn_gates()
	
	update_gate_positions(delta)
	remove_off_screen_gates()

func spawn_gates():
	var gate_pair := []
	
	for x_pos in GATE_X_POSITIONS:
		var gate = MULTIPLIER_GATE_SCENE.instance()
		gate.position = Vector2(x_pos, INITIAL_Y_OFFSET)
		gate.scale = GATE_SCALE
		var random_kind = gate.KIND.ADD if randi() % 2 == 0 else gate.KIND.MULT
		var random_amount
		if random_kind == gate.KIND.ADD:
			random_amount = randi() % (MAX_CARROT_ADD_AMOUNT - MIN_CARROT_ADD_AMOUNT + 1) + MIN_CARROT_ADD_AMOUNT
		else:
			random_amount = randi() % (MAX_CARROT_MULT_AMOUNT - MIN_CARROT_MULT_AMOUNT + 1) + MIN_CARROT_MULT_AMOUNT
		gate.setAmountAndKind(random_amount, random_kind)
		add_child(gate)
		gates.append(gate)
		gate_pair.append(gate)
	
	# Link the gates as pairs
	if gate_pair.size() == 2:
		gate_pair[0].setPairedGate(gate_pair[1])
		gate_pair[1].setPairedGate(gate_pair[0])

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
