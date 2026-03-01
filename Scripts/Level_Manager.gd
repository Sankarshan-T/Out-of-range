extends Node

func _on_start_pressed() -> void:
	Dialogic.start("tolevel1")
	await Dialogic.timeline_ended
	navigate_to_level("res://Scenes/Levels/level_1.tscn")

func navigate_to_level(path: String) -> void:
	if path == "":
		print("Error: No path provided to LevelManager!")
		return
		
	get_tree().call_deferred("change_scene_to_file", path)
