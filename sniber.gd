extends Node2D

@onready var sniber := $Sniber
@onready var me := $".."

func _process(delta: float) -> void:
	if get_global_mouse_position().x > me.position.x:
		sniber.flip_v = false
	else:
		sniber.flip_v = true
		
	look_at(get_global_mouse_position())
