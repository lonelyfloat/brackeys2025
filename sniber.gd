extends Node2D

@onready var sniber := $Sniber
@onready var me := $".."

func _process(delta: float) -> void:
	if get_global_mouse_position().x > me.position.x:
		sniber.scale.y = 0.13
	else:
		sniber.scale.y = -0.13
	look_at(get_global_mouse_position())
