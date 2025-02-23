@tool
class_name Guard
extends GenericCrowdNPC

@onready var armR := get_node("armR")
@onready var armL := get_node("armL")
@onready var gun := $gunAnchor
@onready var gun_model := get_node("gunAnchor/gun")

var guard_alerted = false
var dead = false

func _ready() -> void:
	super._ready()
	armR.modulate = color
	armL.modulate = color
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
	print(personal_suspicion)
	super.suspicious()

func alerted():
	print("ahhh")
	gun_model.visible = true
	guard_alerted = true
	gun.process_mode = Node.PROCESS_MODE_INHERIT
	if last_sus != personal_suspicion:
		last_sus = personal_suspicion
		suspicion_raised.emit(personal_suspicion)


func _process(_delta: float) -> void:
	if guard_alerted && !dead && !Engine.is_editor_hint():
		if y_dir > 0:
			gun.z_index = -2
		else:
			gun.z_index = 2
		gun.position = Vector2(0,-21)

		if x_dir > 0:
			armR.visible = true
			armL.visible = false
		elif x_dir < 0:
			armR.visible = false
			armL.visible = true
		else:
			if player.position.x > position.x:
				armR.visible = true
				armL.visible = false
			else:
				armR.visible = false
				armL.visible = true
				
		if !nav.is_navigation_finished():
			var direction = Vector2.ZERO
			direction = nav.get_next_path_position() - global_position
			direction = direction.normalized()
		
			velocity = direction*speed 
		else:
			velocity = Vector2(0,0)
			nav.target_position = position
			light_pivot.look_at(player.position)
			if last_sus != personal_suspicion:
				last_sus = personal_suspicion
				suspicion_raised.emit(personal_suspicion)
	if health <= 0: 
		armL.visible = false
		armL.visible = false
		gun.visible = false 
		dead = true

func _on_path_timer_timeout() -> void:
	nav.target_position = player.position
