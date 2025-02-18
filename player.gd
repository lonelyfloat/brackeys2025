extends CharacterBody2D

@export var speed = 300
@export var bounce_power := 1
@export var terminal_velocity := 500

@onready var sprite := $AnimatedSprite2D

var speed_nerft = 1
var bounce := false
var bouncing := false
var vel
var suspicion_level := 0.0

var animPlaying := false
var x_dir := 0
var y_dir := 0

var acceleration := 70
var friction := 0.9

func _physics_process(delta: float) -> void:
	velocity *= friction
	var horz_direction := Input.get_axis("move_left", "move_right")
	var vert_direction := Input.get_axis("move_up", "move_down")
	var input_vector = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	
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
	

	velocity += input_vector * acceleration
	if bounce:
		animPlaying = true
		velocity = vel
		bounce = false
		if velocity.x < 0:
			sprite.play("knockedL")
		else:
			sprite.play("knockedR")
	
	if(velocity.length() > terminal_velocity):
		velocity = terminal_velocity*velocity.normalized()
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
