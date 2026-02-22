extends Node2D

@onready var trigger_zone:Area2D = %TriggerZone
@onready var pointer:Pointer = %Pointer
@onready var timer:Timer = %Timer
@onready var success_audio: StreamPlayerComponent = $SuccessAudio
@onready var fail_audio: StreamPlayerComponent = $FailAudio
@onready var end_audio: StreamPlayerComponent = $EndAudio
@export var letters: Array[Sprite2D]
var current_level = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(on_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && event.pressed:
			timer.start(1.5)
			if(trigger_zone.get_overlapping_areas().size()>0):
				if(current_level<5):
					key_down()
					success_audio.play_random()
					letters[current_level].visible=true
				current_level += 1
			else:
				if(current_level<5):
					fail_audio.play_random()	
		
			pointer.hide_pointer(5+6*current_level)

func on_timeout():
	if current_level<5:
		pointer.change_texture(current_level)
		pointer.reveal_pointer() 
	else:
		$GameZone.visible = false
		end_audio.play_random()
		ProgressionManager.set_flag("typing_solved",true)

func key_down():
	var keys = get_tree().get_nodes_in_group("keys")
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var key:Sprite2D = keys[rand.randi_range(0,keys.size()-1)]
	var tween = create_tween()
	tween.tween_property(key ,"position:y",key.position.y+15,0.35)
	tween.tween_callback(key_up.bind(key))
	
func key_up(key:Sprite2D):
	var tween = create_tween()
	tween.tween_property(key ,"position:y",key.position.y-15,0.35)
