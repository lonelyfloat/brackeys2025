extends Camera2D

@onready var player = $"../Player"
@export var speed = 3

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = speed

func _physics_process(delta: float) -> void:
	position.x = player.position.x
	position.y = player.position.y
