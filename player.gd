extends CharacterBody2D

@export var speed = 300.0
var speed_nerft = 1

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horz_direction := Input.get_axis("ui_left", "ui_right")
	var vert_direction := Input.get_axis("ui_up", "ui_down")
	
	
	if horz_direction || vert_direction:
		if abs(horz_direction) > .5 && abs(vert_direction) > .5:
			speed_nerft = 0.66
		else:
			speed_nerft = 1.0
		velocity.y = vert_direction * speed * speed_nerft
		velocity.x = horz_direction * speed * speed_nerft
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		

	move_and_slide()
