extends Node2D

var stash := []

func add_money(money: Node2D):
	stash.append(money)
	money.drop_off_area = self

func remove_money(money: Node2D):
	stash.erase(money)

func get_put_down_location(money):
	var index = stash.find(money)

	return global_position + Vector2(0, -index * 5)
