class_name PickupObject
extends Area2D

@export var item_data : ItemData
@export var true_flags : Array[String]
##При подборе предмета проиграет анимацию с имени pickup
@export var anim_player : AnimationPlayer

func _ready() -> void:
	self.input_event.connect(_on_input_event)
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		pickup()

func pickup() ->  bool:
	for flag in true_flags:
		if !ProgressionManager.get_flag(flag):
			return false
	GlobalData.player_inventory.add_item(item_data)
	_on_mouse_exited()
	if anim_player:
		anim_player.play("pickup")
	self.queue_free()
	return true;

func _on_mouse_entered() -> void:
	#Тут будет изменять курсор мыши на хватательный
	pass

func _on_mouse_exited() -> void:
	#Здесь курсор мыши будет возвращаться в нормльное состояниее
	pass
