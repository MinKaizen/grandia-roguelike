extends CharacterBody3D

@export var timeline_speed = 20.0
@export var player_controlled: bool = false

@onready var timeline = get_tree().root.get_node('Timeline')

func _ready():
	pass

func _physics_process(delta):
	pass

func _on_time_to_act():
	print('%s: acted!' % name)
