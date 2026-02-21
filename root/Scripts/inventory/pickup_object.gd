class_name PickupObject
extends Area2D

@export var item_data : ItemData
@export var true_flags : Array[String]
@export var hide_object:bool = false
##При подборе предмета проиграет анимацию с имени pickup
@export var anim_player : AnimationPlayer

func _ready() -> void:
	if ProgressionManager.get_flag(item_data.id+"_picked_up"):
		call_deferred( "queue_free_parent")
	self.input_event.connect(_on_input_event)
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	update_state()
	ProgressionManager.progression_data.changed.connect(update_state)

	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		pickup()

func pickup() ->  bool:
	if !check_flags():
		return false
	GlobalData.player_inventory.add_item(item_data)
	ProgressionManager.set_flag(item_data.id+"_picked_up",true)
	_on_mouse_exited()
	if anim_player:
		anim_player.play("pickup")
	call_deferred( "queue_free_parent")
	return true;

func _on_mouse_entered() -> void:
	#Тут будет изменять курсор мыши на хватательный
	pass

func _on_mouse_exited() -> void:
	#Здесь курсор мыши будет возвращаться в нормльное состояниее
	pass
func queue_free_parent():
	get_parent().queue_free()

func update_state():
	if !hide_object:
		var parent = get_parent()
		if parent is Node2D:
			if check_flags():
				parent.visible=true
			else:
				parent.visible = false	

func check_flags()->bool:
	for flag in true_flags:
		if !ProgressionManager.get_flag(flag):
			return false
	return true				
