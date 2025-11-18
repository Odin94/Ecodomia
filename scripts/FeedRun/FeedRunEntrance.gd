extends Node2D

onready var area = $Area2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		var feed_run_ui = body.get_node_or_null("FeedRunSelectorUI")
		if feed_run_ui:
			feed_run_ui.visible = true

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		var feed_run_ui = body.get_node_or_null("FeedRunSelectorUI")
		if feed_run_ui:
			feed_run_ui.visible = false
