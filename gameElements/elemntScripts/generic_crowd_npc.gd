@tool
class_name GenericCrowdNPC
extends CharacterBody2D

@export var path: Array[Vector2]
@export var speed := 200
@export var light_texture_scale := 5
@export var view_cone_angle := 30.0
@export var ray_length := 300.0
@export var max_health := 500.0
@export var suspicion_threshold := 10
@export var initial_rotation := 0.0
@export var monitor_time := 1.5

@export var color: Color

@onready var sprite := get_node("Sprite2D")
@onready var ray := get_node("RayCast2D")
@onready var light_pivot := get_node("LightPivot")
@onready var light := get_node("LightPivot/PointLight2D")
@onready var collider := get_node("Area2D/CollisionShape2D")
@onready var knocked_timer := get_node("KnockedTimer")
@onready var nav := get_node("NavigationAgent2D")
var player

var current_path_idx := 0
var acceptable_pt_diff := 5 # this value will need to be adjusted as we go - represents 'how close' an npc can be to a point
var moving_path_forward := true
var move_dir: Vector2

var health := 10.0

var personal_suspicion := 0.0
var player_in_view := false
var sussing := false
var last_sus := 0.0
var found_guard

var x_dir := 0
var y_dir := 0
var animPlaying := false

var initial_position

var knocked := false

var knock_velocity := Vector2.ZERO
signal suspicion_raised(amount: float)

func _draw():
	if Engine.is_editor_hint():
		if path.size() > 1:
			for i in range(0, path.size() - 1):
				draw_line(path[i] - global_position, path[i+1] - global_position, Color(1,1,1,1))
		draw_line(Vector2.ZERO, ray_length * Vector2(cos(deg_to_rad(initial_rotation-view_cone_angle)), sin(deg_to_rad(initial_rotation-view_cone_angle))), Color(0,1,0,1))
		draw_line(Vector2.ZERO, ray_length * Vector2(cos(deg_to_rad(initial_rotation + view_cone_angle)), sin(deg_to_rad(initial_rotation + view_cone_angle))), Color(0,1,0,1))
		sprite.modulate = color

func config_light_texture() ->void: 
	light.texture_scale = light_texture_scale
	var angle = view_cone_angle
	var tex_size = ray_length/light_texture_scale
	var ltex = load("light_texture.tres")
	var half = ltex.duplicate()
	var w = int(tex_size * cos(deg_to_rad(angle)))
	var h = int(2 * tex_size * sin(deg_to_rad(angle)))
	var halfh = int(h/2.0)
	half.set_width(w)
	half.set_height(halfh)
	var halfimg = half.get_image()
	var flipped = halfimg.duplicate()
	flipped.flip_y()
	var wholeimg = Image.create_empty(w*2,h,true, halfimg.get_format())
	wholeimg.blit_rect(halfimg, Rect2i(0,0,w,halfh), Vector2i(w,0))
	wholeimg.blit_rect(flipped, Rect2i(0, 0, w, halfh), Vector2i(w,halfh))
	var itex := ImageTexture.create_from_image(wholeimg)
	light.texture = itex
	light_pivot.rotation = deg_to_rad(initial_rotation)

func _ready() -> void:
	initial_position = position
	ray.target_position = Vector2(0, ray_length)
	move_dir = Vector2(cos(deg_to_rad(initial_rotation)),sin(deg_to_rad(initial_rotation))) 
	sprite.modulate = color
	health = max_health
	player = get_tree().get_first_node_in_group("Player")
	config_light_texture()

func scan_ray(delta: float) -> void: 
	var view_angle = atan2(move_dir.y, move_dir.x)
	for i in range(int(floor(-view_cone_angle)), int(floor(view_cone_angle))):
		ray.target_position = ray_length * Vector2(cos(view_angle + deg_to_rad(i*1.0)),sin(view_angle + deg_to_rad(i*1.0))) 
		var object = ray.get_collider()
		if object != null && object.is_in_group("Player"):
			var pl = object.get_parent()
			player_in_view = true
			if pl.suspicion_level > 0: 
				personal_suspicion += pl.suspicion_level * delta
			break;

func move_along_path() -> void:
	if path.size() == 0:
		if (initial_position - position).length() > acceptable_pt_diff:
			velocity = (initial_position - position).normalized() * speed
		else: 
			velocity = Vector2.ZERO
		return
	if (position - path[current_path_idx]).length() > acceptable_pt_diff:
		velocity = (path[current_path_idx] - position).normalized() * speed
	else:
		velocity = Vector2.ZERO
		if current_path_idx == 0: 
			moving_path_forward = true
		if current_path_idx == path.size() - 1:
			moving_path_forward = false
		if moving_path_forward: 
			current_path_idx += 1
		else:
			current_path_idx -= 1

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		player_in_view = false
		if health > 0:
			if knocked:
				animPlaying = true
				velocity = knock_velocity
				if velocity.x < 0:
					sprite.play("knockedL")
				else:
					sprite.play("knockedR")
			else:
				if personal_suspicion == 0 || (personal_suspicion == last_sus && personal_suspicion < suspicion_threshold): 
					move_along_path()
				elif personal_suspicion < suspicion_threshold && personal_suspicion != last_sus: 
					suspicious() 
				elif personal_suspicion >= suspicion_threshold: 
					alerted()
				if velocity.normalized() != Vector2.ZERO:
					move_dir = velocity.normalized()
					light_pivot.rotation = lerp(light_pivot.rotation, atan2(move_dir.y, move_dir.x), 0.2)
			runAnims(velocity.normalized())
			scan_ray(delta)
			move_and_slide()
		if health <= 0: # when you're dead:
			light.enabled = false
			ray.enabled = false
			if !animPlaying: 
				sprite.play("die")
				animPlaying = true
				collider.position = Vector2(0, 28)
				collider.shape.set_height(60);

func suspicious():
	if !sussing:
		sussing = true
		await get_tree().create_timer(monitor_time).timeout
		if personal_suspicion < suspicion_threshold:
			last_sus = personal_suspicion
		move_along_path()
		sussing = false
	light_pivot.look_at(player.position)

func alerted():
	if found_guard == null:
		var nearest_guard_distance = position.distance_to(get_tree().get_first_node_in_group("Guards").position)
		for guard in get_tree().get_nodes_in_group("Guards"):
			if position.distance_to(guard.position) <= nearest_guard_distance:
				found_guard = guard
		
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

func _notification(what: int) -> void: 
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		queue_redraw()
		move_dir = Vector2(cos(deg_to_rad(initial_rotation)),sin(deg_to_rad(initial_rotation))) 
		config_light_texture()

func runAnims(input_vector: Vector2) -> void:
	if animPlaying:
		return

	if input_vector.x != 0 || y_dir == 0:
		y_dir = 0

	if(abs(input_vector.x) >= abs(input_vector.y)):
		if(input_vector.x > 0):
			sprite.play("moveR")
		elif(input_vector.x < 0):
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


func _on_knocked_timer_timeout() -> void:
	knocked = false
	animPlaying = false

func _on_area_entered(body: Node2D) -> void:
	if body.is_in_group("DamageBody"):
		health -= body.hit_damage
		body.queue_free()
		if health > 0:
			knocked_timer.start()
			knocked = true
			var normal = (position - body.position).normalized()
			knock_velocity = normal*speed

func _on_bounce_area_entered(body: Node2D) -> void: 
	if health > 0:
		knocked_timer.start()
		knocked = true
		var normal = (position - body.position).normalized()
		knock_velocity = normal*speed

func _on_path_timer_timeout() -> void:
	if found_guard != null:
		nav.target_position = found_guard.position
