extends Node2D

func _on_target_dead(): 
	get_tree().change_scene_to_file("res://win_scene.tscn")

func _on_player_player_died() -> void:
	get_tree().change_scene_to_file("res://dead_scene.tscn")

func _process(_delta: float) -> void: 
	if !Engine.is_editor_hint() && Input.is_action_just_released("quit_game"):
		get_tree().change_scene_to_file("res://main_menu.tscn")
