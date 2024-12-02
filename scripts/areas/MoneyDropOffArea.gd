extends Node2D

var stash := []
var stash_limit := 100

func add_money(money: Node2D):
	money.drop_off_area = self
	if stash.size() >= stash_limit:
		money.queue_free()
	else:
		stash.append(money)


func remove_money(money: Node2D):
	stash.erase(money)

func get_put_down_location(money):
	var index = stash.find(money)

	return global_position + Vector2(0, -index * 5)
