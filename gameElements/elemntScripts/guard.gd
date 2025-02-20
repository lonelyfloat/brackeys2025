class_name Guard
extends GenericCrowdNPC

@onready var armR := $armR
@onready var armL := $armL

func suspicious():
	#print("guard suspicious")
	pass

func alert():
	#print("guard alert")
	pass

func _process(_delta: float) -> void:
	if x_dir > 0:
		armR.visible = true
		armL.visible = false
	elif x_dir < 0:
		armR.visible = false
		armL.visible = true
	else:
		if get_global_mouse_position().x > position.x:
			armR.visible = true
			armL.visible = false
		else:
			armR.visible = false
			armL.visible = true
