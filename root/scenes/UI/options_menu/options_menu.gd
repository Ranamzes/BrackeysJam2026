extends CanvasLayer

signal back_pressed

@onready var master_slider: HSlider = %MasterSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_slider: HSlider = %MusicSlider

@onready var back_button: SoundedButton = %BackButton



func _ready() -> void:
	back_button.pressed.connect(on_back_button_pressed)
	master_slider.value_changed.connect(on_audio_slider_value_changed.bind("Master"))
	music_slider.value_changed.connect(on_audio_slider_value_changed.bind("music"))
	sfx_slider.value_changed.connect(on_audio_slider_value_changed.bind("sfx"))
	update_display()
	
	
func update_display():
	sfx_slider.value = get_bus_volume_percent("sfx")
	music_slider.value = get_bus_volume_percent("music")
	master_slider.value = get_bus_volume_percent("Master")
	
	
func get_bus_volume_percent(bus_name:String) -> float:
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume)
	
	
func set_bus_volume_percent(bus_name:String, percent:float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index,volume)	

	
func on_back_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	back_pressed.emit()
	
	
func on_audio_slider_value_changed(value: float,bus_name: String):
	set_bus_volume_percent(bus_name,value)
