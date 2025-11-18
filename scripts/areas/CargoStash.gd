extends Node2D

var stash := []
var stash_limit := 100

func _physics_process(_delta):
	# updates continuously to make sure cargos have the right location
	# since cargos determine when they're put down themselves, they all run in parallel
	# and race-condition for offset-locations
	# Could fix this by making cargo dumb and having an external script managing it.
	# TODO: Make cargo dumb (just a status) and manage in an external system
	for i in stash.size():
		var cargo = stash[i]
		cargo.cargo_stash_putdown_location = global_position + Vector2(0, -i * 5)


func add_cargo(cargo: Node2D):
	if stash.size() >= stash_limit:
		cargo.queue_free()
	else:
		stash.append(cargo)


func spend_cargo():
	if stash.size() > 0:
		return stash.pop_back()
	return null
