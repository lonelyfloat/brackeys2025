extends CharacterBody2D

@export var speed = 300
@export var bounce_power := 1.0
@export var terminal_velocity := 2000
@export var max_health := 300.0
@export var gun_recoil := 1.0

@onready var sprite := $AnimatedSprite2D

@onready var armR := $armR
@onready var armL := $armL
@onready var sniber := $SniberAnchor/Sniber
@onready var gun := $SniberAnchor
@onready var momentum_timer := $MomentumTimer


var bounce := false
var bouncing := false
var vel
var suspicion_level := 0.0
var stowed_gun = true

var animPlaying := false
var x_dir := 0
var y_dir := 0

var acceleration := 150
var normal_friction := 0.85
var conserving_friction := 0.99
var friction = normal_friction

var conserving := false
var input_vector := Vector2.ZERO

var health := max_health

var collision: KinematicCollision2D

signal player_died()

func _physics_process(delta: float) -> void:
	input_vector = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	runAnims()

	if !stowed_gun:
		if suspicion_level < 5.0:
			suspicion_level = 5.0
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
	else:
		if suspicion_level < 50:
			suspicion_level = 1
		armR.visible = false
		armL.visible = false

	if(input_vector != Vector2.ZERO && !bouncing):
		if velocity.length() >= speed:
			velocity = input_vector * velocity.length()
		else:
			velocity += input_vector * acceleration
	if input_vector == Vector2.ZERO && momentum_timer.is_stopped(): 
		momentum_timer.start()

		
	if bounce:
		animPlaying = true
		velocity = vel*bounce_power
		bounce = false
		conserving = true
		if velocity.x < 0:
			sprite.play("knockedL")
		else:
			sprite.play("knockedR")

	if conserving: 
		friction = conserving_friction
	else: 
		friction = normal_friction
	
	if(velocity.length() > terminal_velocity):
		velocity = terminal_velocity*velocity.normalized()
	collision = move_and_collide(velocity*delta)
	if health > 0 && collision:
		var normal = collision.get_normal()
		vel = -2 * velocity.dot(normal) * normal + velocity
		bounce = true
		conserving = true
		bouncing = true
		bounce_time(0.33)
	velocity *= friction

func _process(_delta: float) -> void:
	if health <= 0:
		player_died.emit()
	if Input.is_action_just_pressed("stow"):
		stowed_gun = !stowed_gun
	if stowed_gun:
		gun.process_mode = Node.PROCESS_MODE_DISABLED
		if x_dir > 0:
			sniber.scale.y = -0.13
			gun.position = Vector2(0,50)
			gun.rotation_degrees = -115
			gun.z_index = -2
		elif x_dir < 0:
			sniber.scale.y = 0.13
			gun.position = Vector2(10,50)
			gun.rotation_degrees = -70
			gun.z_index = -2
		elif y_dir < 0:
			sniber.scale.y = 0.13
			gun.position = Vector2(-24,47)
			gun.rotation_degrees = -60
			gun.z_index = -2
		elif y_dir > 0:
			sniber.scale.y = -0.13
			gun.position = Vector2(24,44)
			gun.rotation_degrees = -121
			gun.z_index = 2
	else:
		gun.process_mode = Node.PROCESS_MODE_INHERIT
		if y_dir > 0:
			gun.z_index = -2
		else:
			gun.z_index = 2
			
		gun.position = Vector2(0,-21)

func bounce_time(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	bouncing = false
	animPlaying = false
	
func recoil(sped, damage, rot) -> void:
		vel = gun_recoil*Vector2(-damage*sped/1000 * cos(rot),-damage*sped/1000 * sin(rot))
		bounce = true
		conserving = true
		bounce_time(0.33)
	
func runAnims() -> void:
	if animPlaying:
		return

	if input_vector.x != 0 || y_dir == 0:
		y_dir = 0
		if(get_local_mouse_position().x > 0):
			x_dir = 1                       
		elif(get_local_mouse_position().x < 0):
			x_dir = -1
	
	if(abs(input_vector.x) >= abs(input_vector.y)):
		armR.z_index = 4
		armL.z_index = 4
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
			armR.z_index = -2
			armL.z_index = -2
		elif(y_dir < 0):
			sprite.play("idleF")
		else:
			sprite.play("idleF")
	else:
		x_dir = 0
		if(input_vector.y > 0):
			sprite.play("moveF")
			y_dir = -1
			armR.z_index = 4
			armL.z_index = 4
		elif(input_vector.y < 0):
			sprite.play("moveB")
			y_dir = 1
			armR.z_index = -2
			armL.z_index = -2


func _on_momentum_timer_timeout() -> void:
	if input_vector == Vector2.ZERO: 
		conserving = false
 
func _on_area_entered(body: Node2D) -> void: 
	if body.is_in_group("DamageBody"):
		health -= body.hit_damage
		body.queue_free()
