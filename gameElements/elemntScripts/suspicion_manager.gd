extends Node2D

@export var text : RichTextLabel
@export var info_UI : Node
@export var alarmLevel := 20


var npcs: Array[Node]
var suspicion_level := 0.0
var sus_spoken := -1.0

func _ready(): 
	npcs = get_tree().get_nodes_in_group("NPCs")
	for npc in npcs: 
		npc.suspicion_raised.connect(_suspicion_raised_effect)

func _suspicion_raised_effect(amount):
	suspicion_level += amount
	if suspicion_level > alarmLevel:
		npcs = get_tree().get_nodes_in_group("NPCs")
		for npc in npcs: 
			npc.personal_suspicion = suspicion_level
	
func _process(_delta: float) -> void:
	match suspicion_level:
		0.0 when sus_spoken < 0:
			info_UI.visible = true
			text.text = "OK agent 46, the mission is simple. All you need to do is locate the target, Jimmy Red Legs, and take him out with a well placed bullet. Just press 'E' to ready your weapon - but be careful, it will also make you more suspicious. Then take aim with the mouse and 'left click' to fire. Good luck agent, I know you'll take care of your first mission with ease."
			if(Input.is_action_just_released("accept")):
				info_UI.visible = false
				sus_spoken = 0
		5.0 when sus_spoken < 2:
			info_UI.visible = true
			text.text = "Agent! Our spies have found that this facility is crawling with guards. Stay cautious and avoid their gunfire."
			if(Input.is_action_just_released("accept")):
				info_UI.visible = false
				sus_spoken = 2
		15.0 when sus_spoken < 3:
			info_UI.visible = true
			text.text = "Agent, I've recieved reports that you're 'blasting the roof off of there'. Remember your task, and don't forget your place."
			if(Input.is_action_just_released("accept")):
				info_UI.visible = false
				sus_spoken = 3
		20.0 when sus_spoken < 4: 
			info_UI.visible = true
			text.text = "Agent? What on god's green earth are you doing out there? If I didn't know better, I'd think you were alerting them on purpose."
			if(Input.is_action_just_released("accept")):
				info_UI.visible = false
				sus_spoken = 3
