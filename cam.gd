extends Camera2D

@onready var player = $"../Player"
@export var speed = 5
@export var max_dist = 10

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = speed

func _physics_process(delta: float) -> void:
	position.x = move_toward(position.x, player.position.x, speed)
	position.y = move_toward(position.y, player.position.y, speed)
