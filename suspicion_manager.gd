extends Node2D

var npcs: Array[Node]
var suspicion_level := 0

func _ready(): 
    npcs = get_tree().get_nodes_in_group("NPCs")
    for npc in npcs: 
        npc.suspicion_raised.connect(_suspicion_raised_effect)

func _suspicion_raised_effect(amount):
    suspicion_level += amount
    pass # to be implemented
    
