extends Control

onready var grid = $GridContainer

func _ready():
	for i in range(grid.get_child_count()):
		var box = grid.get_child(i)
		if box.has_method("set_level"):
			box.set_level(i + 1)
			if box.has_signal("level_selected"):
				box.connect("level_selected", self, "_on_level_selected")

func _on_level_selected(level_num: int):
	StageMover.enter_feedrun(level_num)
