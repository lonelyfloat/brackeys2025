extends Node2D



func _on_texture_button_2_button_down() -> void:
	get_tree().quit()


func _on_texture_button_button_down() -> void:
	get_tree().change_scene_to_file("res://basicTestScene.tscn")
