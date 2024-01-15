extends Node

signal next_turn
signal turn_input

var player: Node
var enemy: Node
var actors := []
var current_actor_index := 0
var actor: Node

func _ready():
	player = owner.get_node('Player')
	actors.append(player)
	enemy = owner.get_node('Enemy')
	actors.append(enemy)
	actor = actors[current_actor_index]
	self.connect("ready", self.do_turns)

func do_turns():
	while true:
		emit_signal('next_turn', actor)
		await actor.turn_ended
		current_actor_index = (current_actor_index + 1) % actors.size()
		actor = actors[current_actor_index]

func _unhandled_input(event):
	if event.is_action_pressed("Click"):
		print('Click!')
	var input_actor = actor
	emit_signal('turn_input', event, input_actor)
