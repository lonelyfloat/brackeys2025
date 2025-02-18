extends CharacterBody2D

@export var speed = 300

@onready var sprite := $AnimatedSprite2D

var speed_nerft = 1
var bounce := false
var bouncing := false
var vel
var suspicion_level := 0.0

var animPlaying := false
var x_dir := 0
var y_dir := 0


func _physics_process(delta: float) -> void:
	var horz_direction := Input.get_axis("ui_left", "ui_right")
	var vert_direction := Input.get_axis("ui_up", "ui_down")
	
	#ignore this atrocius code until the performance becomes a problem
	if(abs(horz_direction) >= abs(vert_direction)) && !animPlaying:
		if(horz_direction > 0):
			sprite.play("moveR")
			x_dir = 1
		elif(horz_direction < 0):
			sprite.play("moveL")
			x_dir = -1
		elif(x_dir > 0):
			sprite.play("idleR")
		elif(x_dir < 0):
			sprite.play("idleL")
		else:
			sprite.play("idleF")
	elif (!animPlaying):
		if(vert_direction > 0):
			sprite.play("moveF")
			y_dir = -1
		elif(vert_direction < 0):
			sprite.play("moveB")
			y_dir = 1
		elif(y_dir > 0):
			sprite.play("idleF")
		elif(y_dir < 0):
			sprite.play("idleF")
		else:
			sprite.play("idleB")
	
	if (horz_direction || vert_direction) && !bouncing:
		if abs(horz_direction) > .5 && abs(vert_direction) > .5:
			speed_nerft = 0.66
		else:
			speed_nerft = 1.0
		velocity.y = vert_direction * speed * speed_nerft
		velocity.x = horz_direction * speed * speed_nerft
	else:
		velocity.x = move_toward(velocity.x, 0, speed/30.)
		velocity.y = move_toward(velocity.y, 0, speed/30.)
		
	if bounce:
		animPlaying = true
		velocity = vel
		bounce = false
		if velocity.x < 0:
			sprite.play("knockedL")
		else:
			sprite.play("knockedR")
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		if fmod(collision.get_angle(),PI) > 0.77:
			vel = Vector2(velocity.x * -1,velocity.y)
		else:
			vel = Vector2(velocity.x,velocity.y * -1)
		bounce = true
		bouncing = true
		bounce_time(0.33)

func bounce_time(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	bouncing = false
	animPlaying = false
