extends CanvasLayer



signal transition_halfway
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func transition():
	animation_player.play("transition")
	await animation_player.animation_finished
	transition_halfway.emit()
	animation_player.play_backwards("transition")
	
