extends Node2D

var npcs: Array[Node]
var suspicion_level := 0.0
var sus_spoken := -1.0

func _ready(): 
	npcs = get_tree().get_nodes_in_group("NPCs")
	for npc in npcs: 
		npc.suspicion_raised.connect(_suspicion_raised_effect)

func _suspicion_raised_effect(amount):
	suspicion_level += amount
	pass # to be implemented
	
func _process(delta: float) -> void:
	match suspicion_level:
		0.0 when sus_spoken < 0:
			print("We are number one!")
			sus_spoken = 0
		2.0 when sus_spoken < 2:
			print("Two are better than one!")
			sus_spoken = 2
