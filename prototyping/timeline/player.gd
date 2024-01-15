extends CharacterBody3D

signal act_finished
@export var player_controlled: bool = false
@onready var timeline = get_tree().root.get_node('Timeline')

func _ready():
	$TimelineActor.connect('state_changed', func(state: TimelineActor.STATE):
		if state == TimelineActor.STATE.ACT:
#			await get_tree().create_timer(2).timeout 
			print('%s: acted!' % name)
			emit_signal('act_finished')
	)
