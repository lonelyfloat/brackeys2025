extends RigidBody2D

var hit_damage := 5
var speed := 500.0
var lifetime := 3.0
@export var fade_curve: Curve

@onready var sprite := $Bullet
@onready var timer := $Timer


func _ready() -> void:
	timer.start(lifetime)
	apply_central_impulse(Vector2(cos(rotation), sin(rotation)) * speed)
	time()
func _process(_delta: float) -> void:
	sprite.modulate.a = fade_curve.sample(1 - (timer.time_left/lifetime))

	
func time() -> void:
	await timer.timeout
	queue_free()
