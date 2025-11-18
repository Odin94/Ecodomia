extends Node

var feedrun_level_num: int = 1

const FEEDRUN_SCENE_PATH = "res://scenes/FeedRun/FeedRun.tscn"
const MAINMAP_SCENE = "res://scenes/MainMap.tscn"

func enter_feedrun(level_num: int):
	feedrun_level_num = level_num
	call_deferred("_do_enter_feedrun", level_num)

func _do_enter_feedrun(level_num: int):
	var feedrun_scene = load(FEEDRUN_SCENE_PATH) as PackedScene
	var feedrun_instance = feedrun_scene.instance()
	feedrun_instance.level_name = "feedrun_level_" + str(level_num)
	
	var tree = get_tree()
	
	_cleanup_scene_nodes(tree)
	
	var old_scene = tree.current_scene
	if old_scene:
		tree.root.remove_child(old_scene)
		old_scene.queue_free()
	
	tree.root.add_child(feedrun_instance)
	tree.current_scene = feedrun_instance

func enter_mainmap():
	call_deferred("_do_enter_mainmap")

func _do_enter_mainmap():
	var tree = get_tree()
	
	_cleanup_scene_nodes(tree)
	
	var old_scene = tree.current_scene
	if old_scene:
		tree.root.remove_child(old_scene)
		old_scene.queue_free()
	tree.change_scene(MAINMAP_SCENE)

func _cleanup_scene_nodes(tree: SceneTree):
	var root = tree.root
	_cleanup_nodes_by_script(root, "res://scripts/Money.gd")
	_cleanup_nodes_by_script(root, "res://scripts/Cargo.gd")

func _cleanup_nodes_by_script(root: Node, script_path: String):
	var nodes_to_free = []
	for child in _get_all_children(root):
		if child.get_script() and child.get_script().resource_path == script_path:
			nodes_to_free.append(child)
	
	for node in nodes_to_free:
		if is_instance_valid(node):
			node.queue_free()

func _get_all_children(node: Node) -> Array:
	var children = [node]
	for child in node.get_children():
		children += _get_all_children(child)
	return children
