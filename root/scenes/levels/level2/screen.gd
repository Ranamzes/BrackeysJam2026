extends Area2D

@export var textures_array:Array[Texture2D]
@onready var sprite:Sprite2D = $Sprite
@onready var stream_player_component:StreamPlayerComponent = $StreamPlayerComponent
@onready var stream_player_component2: StreamPlayerComponent = $StreamPlayerComponent2
@onready var timer: Timer = $Timer
var index = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_event(viewport: Node, event:InputEvent,shape_idx:int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and timer.is_stopped():
			index = (index+1) % textures_array.size()
			sprite.texture = textures_array[index]
			if index == 4:
				stream_player_component2.play_random()
			else:
				stream_player_component.play_random()
			timer.start(0.5)	
