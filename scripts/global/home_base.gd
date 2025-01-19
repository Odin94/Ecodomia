extends Node

var show_stats := true

enum BONUS_TYPE {NONE, PLAYER_SPEED, PRICE_REDUCTION}

var bonus_speed_percent := 0.0
var price_reduction_percent := 0.0

var placed_furniture := []

func _ready():
	pass

func place_furniture(furniture: Node2D):
	placed_furniture.append(furniture)
	match furniture.bonus_type:
		BONUS_TYPE.NONE:
			pass
		BONUS_TYPE.PLAYER_SPEED:
			bonus_speed_percent += furniture.bonus_amount
		BONUS_TYPE.PRICE_REDUCTION:
			price_reduction_percent += furniture.bonus_amount
		_:
			print("Home_base unknown furniture bonus_type: ", furniture.bonus_type, " for furniture ", furniture.furniture_name)


func remove_furniture(furniture: Node2D):
	var i = get_index_by_name(furniture, placed_furniture)
	if i == -1:
		return
		
	placed_furniture.remove(i)
	match furniture.bonus_type:
		BONUS_TYPE.NONE:
			pass
		BONUS_TYPE.PLAYER_SPEED:
			bonus_speed_percent -= furniture.bonus_amount
		BONUS_TYPE.PRICE_REDUCTION:
			price_reduction_percent -= furniture.bonus_amount
		_:
			print("Home_base unknown furniture bonus_type: ", furniture.bonus_type, " for furniture ", furniture.furniture_name)

func get_placed_furniture():
	return "hi this is a placeholder :)"


func _physics_process(_delta):
	show_stats = Input.is_action_pressed("alt")

func get_index_by_name(node: Node2D, array: Array) -> int:
	var i = 0
	for arr_node in array:
		if arr_node.name == node.name:
			return i
		i += 1
	return -1
