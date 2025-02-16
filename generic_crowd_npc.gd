@tool
extends CharacterBody2D


@export var path: Array[Vector2]
@export var speed: float


@export var texture: Texture2D:
    set(new_texture):
        texture = new_texture
        if(sprite):
            sprite.texture = texture

@onready var sprite := get_node("Sprite2D")

var current_path_idx := 0
var acceptable_pt_diff := 15 # this value will need to be adjusted as we go - represents 'how close' an npc can be to a point
var moving_path_forward := true

func _draw():
    if Engine.is_editor_hint() && path.size() > 1:
        for i in range(0, path.size() - 1):
            draw_line(path[i] - global_position, path[i+1] - global_position, Color(1,1,1,1))

func _ready() -> void:
    sprite.texture = texture

func move_along_path() -> void:
    if path.size() == 0:
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

func _physics_process(_delta: float) -> void:
    if not Engine.is_editor_hint():
        move_along_path()
        move_and_slide()

func _notification(what: int) -> void: 
    if what == NOTIFICATION_EDITOR_POST_SAVE:
        queue_redraw()
