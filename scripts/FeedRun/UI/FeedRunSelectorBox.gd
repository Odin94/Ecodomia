extends PanelContainer

signal level_selected

var locked = false setget set_locked
var level_num = 1 setget set_level

onready var label = $Label
onready var lock = $MarginContainer

func set_locked(value):
	locked = value
	lock.visible = value
	label.visible = not value

func set_level(value):
	level_num = value
	label.text = str(level_num)

func _on_LevelBox_gui_input(event):
	if not event is InputEventMouseButton:
		return
	if locked:
		return
	if event.pressed:
		print("Clicked level ", level_num)
		emit_signal("level_selected", level_num)
