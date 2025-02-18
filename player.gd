extends CharacterBody2D

@export var speed = 300
@export var bounce_power := 1
@export var terminal_velocity := 2000

@onready var sprite := $AnimatedSprite2D

@onready var armR := $armR
@onready var armL := $armL
@onready var sniber := $SniberAnchor/Sniber


var bounce := false
var bouncing := false
var vel
var suspicion_level := 0.0

var animPlaying := false
var x_dir := 0
var y_dir := 0

var acceleration := 150
var normal_friction := 0.85
var bounce_friction := 0.96
var friction = normal_friction

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	runAnims(input_vector)
	
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

	if velocity.y > -speed/1.2:
		armR.z_index = 4
		armL.z_index = 4
		sniber.z_index = 1
	else:
		armR.z_index = -4
		armL.z_index = -4
		sniber.z_index = -1

	if(input_vector != Vector2.ZERO && !bouncing):
		if velocity.length() >= speed:
			velocity = input_vector.normalized() * velocity.length()
		else:
			velocity += input_vector * acceleration

	if bouncing: 
		friction = bounce_friction
	else: 
		friction = normal_friction
		
	if bounce:
		animPlaying = true
		velocity = vel*bounce_power
		bounce = false
		if velocity.x < 0:
			sprite.play("knockedL")
		else:
			sprite.play("knockedR")
	
	if(velocity.length() > terminal_velocity):
		velocity = terminal_velocity*velocity.normalized()
	var collision = move_and_collide(velocity * delta)

	velocity *= friction
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
	
func runAnims(input_vector) -> void:
	if animPlaying:
		return

	if input_vector.x != 0 || y_dir == 0:
		if(get_local_mouse_position().x > 0):
			x_dir = 1                       
		elif(get_local_mouse_position().x < 0):
			x_dir = -1
	

	if(abs(input_vector.x) >= abs(input_vector.y)):
		if(get_local_mouse_position().x > 0 && input_vector.x != 0):
			sprite.play("moveR")
		elif(get_local_mouse_position().x < 0 && input_vector.x != 0):
			sprite.play("moveL")
		elif(x_dir > 0):
			sprite.play("idleR")
		elif(x_dir < 0):
			sprite.play("idleL")
		elif(y_dir > 0):
			sprite.play("idleB")
		elif(y_dir < 0):
			sprite.play("idleF")
		else:
			sprite.play("idleF")
	else:
		x_dir = 0
		if(input_vector.y > 0):
			sprite.play("moveF")
			y_dir = -1
		elif(input_vector.y < 0):
			sprite.play("moveB")
			y_dir = 1
