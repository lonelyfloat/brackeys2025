@tool
class_name Target
extends GenericCrowdNPC

signal target_dead()

var dead := false

func _process(_delta: float) -> void:
    if !Engine.is_editor_hint() && !dead && self.health <= 0:
        target_dead.emit()
        dead = true
