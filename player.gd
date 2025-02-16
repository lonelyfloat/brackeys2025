extends CharacterBody2D

@export var speed = 300
var speed_nerft = 1
var bounce = false
var vel

func _physics_process(delta: float) -> void:

	var horz_direction := Input.get_axis("ui_left", "ui_right")
	var vert_direction := Input.get_axis("ui_up", "ui_down")
	
	if (horz_direction || vert_direction) && !bounce:
		if abs(horz_direction) > .5 && abs(vert_direction) > .5:
			speed_nerft = 0.66
		else:
			speed_nerft = 1.0
		velocity.y = vert_direction * speed * speed_nerft
		velocity.x = horz_direction * speed * speed_nerft
	else:
		velocity.x = move_toward(velocity.x, 0, speed/30)
		velocity.y = move_toward(velocity.y, 0, speed/30)
		
	if bounce:
		velocity += vel;
		
	var collision = move_and_collide(velocity * delta)
	if collision:
		if fmod(collision.get_angle(),PI) > 0.77:
			vel = Vector2(velocity.x * -2,velocity.y)
		else:
			vel = Vector2(velocity.x,velocity.y * -2)
		bounce = true
		bounce_time(1)
		
func bounce_time(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	bounce = false
