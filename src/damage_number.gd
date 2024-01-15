extends Control

@export_range(0.1, 2.0) var duration: float = 1.0
@export_range(10, 1000) var distance: int = 200
@export_range(0, 300) var height: int = 100

func init(number: int, world_position: Vector3, camera: Camera3D):
	$Pivot/Label.text = str(number)
	self.position = camera.unproject_position(world_position) + height * Vector2.UP
	$AnimationPlayer.play('scale_bounce')
	await $AnimationPlayer.animation_finished
	self.queue_free()
