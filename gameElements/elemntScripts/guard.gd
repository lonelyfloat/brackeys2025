class_name Guard
extends GenericCrowdNPC

@onready var armR := get_node("armR")
@onready var armL := get_node("armL")
@onready var gun := get_node("gunAnchor")
@onready var gun_model := get_node("gunAnchor/gun")

var guard_alerted = false


func _ready() -> void:
	super._ready()
	armR.visible = false
	armL.visible = false
	gun_model.visible = false
	gun.process_mode = Node.PROCESS_MODE_DISABLED
	if x_dir > 0:
		gun_model.scale.y = -0.047
		gun.position = Vector2(0,50)
		gun.rotation_degrees = -115
		gun.z_index = -2
	elif x_dir < 0:
		gun_model.scale.y = 0.047
		gun.position = Vector2(10,50)
		gun.rotation_degrees = -70
		gun.z_index = -2
	elif y_dir < 0:
		gun_model.scale.y = 0.047
		gun.position = Vector2(-24,47)
		gun.rotation_degrees = -60
		gun.z_index = -2
	elif y_dir > 0:
		gun_model.scale.y = -0.047
		gun.position = Vector2(24,44)
		gun.rotation_degrees = -121
		gun.z_index = 2

func suspicious():
	#print("guard suspicious")
	pass

func alerted():
	gun_model.visible = true
	guard_alerted = true
	gun.process_mode = Node.PROCESS_MODE_INHERIT
	if y_dir > 0:
		gun.z_index = -2
	else:
		gun.z_index = 2
	gun.position = Vector2(0,-21)

func _process(_delta: float) -> void:
	if guard_alerted:
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
