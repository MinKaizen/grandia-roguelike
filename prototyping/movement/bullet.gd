extends Area3D

@export var speed: float = 10.0
@export var target_group = ''
var velocity := Vector3.ZERO

@export var hit_info := {
	'damage': 5,
}

@onready var animation = $AnimationPlayer

func _ready():
	set_process(false)
	self.connect('area_entered', func(area: Area3D):
		print('%s: area entered' % name)
		if target_group == '' or area.is_in_group(target_group):
			velocity = velocity.normalized() * 2.0
			area.take_hit(hit_info)
			animation.play('die')
			await animation.animation_finished
			queue_free()
	)

func init(direction: Vector3):
	velocity = speed * direction
	set_process(true)

func _physics_process(delta):
	global_position += velocity * delta

