extends Node2D

var stash := []

func _physics_process(delta):
	# TODO: This is just copied from cargo, but doens't have the same use case tbh
	# but maybe we still just slap it into a separate system that manges all moneys?
	for i in stash.size():
		var money = stash[i]
		money.target = global_position + Vector2(0, -i * 5)


func add_money(money: Node2D):
	stash.append(money)
	money.drop_off_area = self
