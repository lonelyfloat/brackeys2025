extends Node2D

@export var damage := 100.0
@export var muzzle_velocity := 600.0
@export var clip_size := 4
@export var reload_time := 5.0
@export var fire_rate := 0.8
@export var bullet_lifetime := 5.0
@export var spread := 60.0


var loaded_ammo
var loaded = true
var bullet = preload("res://gameElements/fired_bullet.tscn")

@onready var sniber := $Sniber
@onready var ray := $Sniber/RayCast2D
@onready var me := $".."
@onready var spawnblt = $Sniber/bulletSpawnTarget


func _ready() -> void:
	loaded_ammo = clip_size

func _process(_delta: float) -> void:
	if get_global_mouse_position().x > me.position.x:
		sniber.scale.y = 0.13
	else:
		sniber.scale.y = -0.13
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("fire") && loaded && !ray.is_colliding():
		var shot = bullet.instantiate()
		shot.hit_damage = damage
		shot.speed = muzzle_velocity
		shot.lifetime = bullet_lifetime
		shot.rotation_degrees = rotation_degrees + randf_range(-spread,spread)
		shot.position = spawnblt.global_position
		me.get_parent().add_child(shot)
		me.recoil(muzzle_velocity, damage, shot.rotation)
		loaded_ammo -= 1
		me.suspicion_level = 100
		if loaded_ammo <= 0:
			reload(reload_time, true)
		else:
			reload(fire_rate, false)
	if Input.is_action_pressed("reload") && loaded:
		reload(reload_time, true)
		
func reload(seconds: float, loading: bool) -> void:
	loaded = false
	await get_tree().create_timer(seconds).timeout
	if loading:
		loaded_ammo = clip_size
	loaded = true
	me.suspicion_level = 4
