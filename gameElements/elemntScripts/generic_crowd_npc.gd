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

@export var texture: Texture2D:
    set(new_texture):
        texture = new_texture
        if(sprite):
            sprite.texture = texture

@onready var sprite := get_node("Sprite2D")
@onready var ray := get_node("RayCast2D")
@onready var light_pivot := get_node("LightPivot")
@onready var light := get_node("LightPivot/PointLight2D")

var current_path_idx := 0
var acceptable_pt_diff := 15 # this value will need to be adjusted as we go - represents 'how close' an npc can be to a point
var moving_path_forward := true
var move_dir := Vector2.ZERO

var health = max_health

var personal_suspicion := 0.0

signal suspicion_raised(amount: float)

func _draw():
    if Engine.is_editor_hint():
        if path.size() > 1:
            for i in range(0, path.size() - 1):
                draw_line(path[i] - global_position, path[i+1] - global_position, Color(1,1,1,1))
        draw_line(Vector2.ZERO, ray_length * Vector2(cos(deg_to_rad(initial_rotation-view_cone_angle)), sin(deg_to_rad(initial_rotation-view_cone_angle))), Color(0,1,0,1))
        draw_line(Vector2.ZERO, ray_length * Vector2(cos(deg_to_rad(initial_rotation + view_cone_angle)), sin(deg_to_rad(initial_rotation + view_cone_angle))), Color(0,1,0,1))


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
    var wholeimg = Image.create_empty(w,h,true, halfimg.get_format())
    wholeimg.blit_rect(halfimg, Rect2i(0,0,w,halfh), Vector2i(0,0))
    wholeimg.blit_rect(flipped, Rect2i(0, 0, w, halfh), Vector2i(0,halfh))
    var itex := ImageTexture.create_from_image(wholeimg)
    light.texture = itex
    light.position.x = light.texture.get_width() * light_texture_scale / 2.0
    light_pivot.rotation = deg_to_rad(initial_rotation)

func _ready() -> void:
    ray.target_position = Vector2(0, ray_length)
    sprite.texture = texture
    config_light_texture()

func scan_ray(delta: float) -> void: 
    var view_angle = atan2(move_dir.y, move_dir.x)
    for i in range(int(floor(-view_cone_angle)), int(floor(view_cone_angle))):
        ray.target_position = ray_length * Vector2(cos(view_angle + deg_to_rad(i*1.0)),sin(view_angle + deg_to_rad(i*1.0))) 
        var object = ray.get_collider()
        if object != null && object.is_in_group("Player"):
            if object.suspicion_level > 0: 
                personal_suspicion += object.suspicion_level * delta
                suspicion_raised.emit(object.suspicion_level * delta)
            break;

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

func _physics_process(delta: float) -> void:
    if not Engine.is_editor_hint():
        if health > 0:
            if personal_suspicion == 0: 
                move_along_path()
            if personal_suspicion < suspicion_threshold: 
                suspicious() 
            if personal_suspicion >= suspicion_threshold: 
                alerted()
            move_dir = velocity.normalized()
            if move_dir != Vector2.ZERO:
                light_pivot.rotation = lerp(light_pivot.rotation, atan2(move_dir.y, move_dir.x), 0.2)
            scan_ray(delta)
            var collision = move_and_collide(velocity * delta)
            if collision: 
                if collision.get_collider().is_in_group("DamageBody"):
                    health -= collision.get_collider().hit_damage
        if health <= 0: # when you're dead:
            light.enabled = false
            ray.enabled = false

func suspicious():
    pass

func alerted():
    pass

func _notification(what: int) -> void: 
    if what == NOTIFICATION_EDITOR_POST_SAVE:
        queue_redraw()
        config_light_texture()
