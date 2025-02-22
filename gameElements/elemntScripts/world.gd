extends Node2D

func _on_target_dead(): 
    get_tree().change_scene_to_file("res://win_scene.tscn")

func _on_player_dead():
    get_tree().change_scene_to_file("res://dead_scene.tscn")
