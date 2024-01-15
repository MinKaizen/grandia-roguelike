extends CharacterBody3D

@onready var timer = $Timer
@onready var health = $Health
@onready var current_label = $CenterContainer/HBoxContainer/VBoxContainer/Labels/Current
@onready var max_label = $CenterContainer/HBoxContainer/VBoxContainer/Labels/Max
@onready var damage_button = $CenterContainer/HBoxContainer/VBoxContainer/Buttons/DamageButton
@onready var heal_button = $CenterContainer/HBoxContainer/VBoxContainer/Buttons/HealButton
@onready var increase_max_button = $CenterContainer/HBoxContainer/VBoxContainer/Buttons2/IncreaseMAX
@onready var reduce_max_button = $CenterContainer/HBoxContainer/VBoxContainer/Buttons2/ReduceMAX
@onready var log = $CenterContainer/HBoxContainer/Log

func _ready():
	current_label.text = str(health.get_health())
	max_label.text = str(health.get_max_health())
	
	damage_button.connect('pressed', func():
		clear_log()
		var amount = random_amount()
		append_log('Damage: %d' % amount)
		health.reduce_health(amount)
	)
	heal_button.connect('pressed', func():
		clear_log()
		var amount = random_amount()
		append_log('Heal: %d' % amount)
		health.increase_health(amount)
	)
	
	health.connect('health_reduced', func(amount):
		current_label.text = str(health.get_health())
		append_log('Health Reduced: %d' % amount)
		append_log('Remaining: %d' % health.get_health())
	)
	health.connect('health_increased', func(amount):
		current_label.text = str(health.get_health())
		append_log('Health Increased: %d' % amount)
		append_log('Remaining: %d' % health.get_health())
	)

	health.connect('health_empty', func():
		append_log('Dead!')
	)
	health.connect('overkill', func(amount: int):
		append_log('Overkill: %d' % amount)
	)

	health.connect('health_full', func():
		append_log('Health full!')
	)
	health.connect('overheal', func(amount: int):
		append_log('Overheal: %d' % amount)
	)
	
	increase_max_button.connect('pressed', func():
		clear_log()
		var amount = random_amount()
		health.increase_max_health(amount)
		append_log('increase_max_health: %d' % amount)
		max_label.text = str(health.get_max_health())
	)
	reduce_max_button.connect('pressed', func(): 
		clear_log()
		var amount = random_amount()
		health.reduce_max_health(amount)
		append_log('reduce_max_health: %d' % amount)
		max_label.text = str(health.get_max_health())
	)

func random_amount() -> int:
	return randi_range(1, 30)

func clear_log():
	log.text = ''

func append_log(text: String):
	if log.text == '':
		log.text = text
	else:
		log.text = log.text + '\n' + text
