extends CanvasLayer

signal back_pressed

@onready var master_slider = %MasterSlider
@onready var sfx_slider = %SFXSlider
@onready var music_slider = %MusicSlider

@onready var reset_button: TextureButton = %ResetButton
@onready var apply_button: TextureButton = %ApplyButton

@onready var master_icon: TextureButton = %MasterIconButton
@onready var music_icon: TextureButton = %MusicIconButton
@onready var sfx_icon: TextureButton = %SFXIconButton

var tex_sound_on = preload("res://root/assets/atlases/ui_buttons.sprites/sound_2.tres")
var tex_sound_off = preload("res://root/assets/atlases/ui_buttons.sprites/sound_1.tres")
var tex_music_on = preload("res://root/assets/atlases/ui_buttons.sprites/music_button_on.tres")
var tex_music_off = preload("res://root/assets/atlases/ui_buttons.sprites/music_button_off.tres")

const CONFIG_PATH = "user://settings.cfg"

var initial_volumes: Dictionary = {}
var pre_mute_volumes: Dictionary = {
	"Master": 1.0,
	"music": 1.0,
	"sfx": 1.0
}

func _ready() -> void:
	print("[Options] Initializing Menu. Checking sliders...")
	if not master_slider: print("[Options] ERROR: MasterSlider not found!")
	if not sfx_slider: print("[Options] ERROR: SFXSlider not found!")
	if not music_slider: print("[Options] ERROR: MusicSlider not found!")

	# Load settings from file or use defaults (1.0 = 100%)
	_load_settings()

	# Cache initial volumes
	initial_volumes["Master"] = get_bus_volume_percent("Master")
	initial_volumes["music"] = get_bus_volume_percent("music")
	initial_volumes["sfx"] = get_bus_volume_percent("sfx")
	print("[Options] Initial volumes cached: ", initial_volumes)

	reset_button.pressed.connect(on_reset_button_pressed)
	apply_button.pressed.connect(on_apply_button_pressed)

	master_slider.value_changed.connect(on_audio_slider_value_changed.bind("Master"))
	music_slider.value_changed.connect(on_audio_slider_value_changed.bind("music"))
	sfx_slider.value_changed.connect(on_audio_slider_value_changed.bind("sfx"))

	master_icon.pressed.connect(on_icon_pressed.bind("Master"))
	music_icon.pressed.connect(on_icon_pressed.bind("music"))
	sfx_icon.pressed.connect(on_icon_pressed.bind("sfx"))

	update_display()

func _load_settings():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)

	if err == OK:
		print("[Options] Settings loaded from ", CONFIG_PATH)
		set_bus_volume_percent("Master", config.get_value("Audio", "Master", 1.0))
		set_bus_volume_percent("music", config.get_value("Audio", "music", 1.0))
		set_bus_volume_percent("sfx", config.get_value("Audio", "sfx", 1.0))
	else:
		print("[Options] No settings found at ", CONFIG_PATH, ", using defaults 1.0")
		# Default everything to 100%
		set_bus_volume_percent("Master", 1.0)
		set_bus_volume_percent("music", 1.0)
		set_bus_volume_percent("sfx", 1.0)

func _save_settings():
	var config = ConfigFile.new()
	# Load existing file to not overwrite other settings if they exist later
	config.load(CONFIG_PATH)

	var m = get_bus_volume_percent("Master")
	var mu = get_bus_volume_percent("music")
	var s = get_bus_volume_percent("sfx")

	print("[Options] SAVING: Master=", m, " music=", mu, " sfx=", s)

	config.set_value("Audio", "Master", m)
	config.set_value("Audio", "music", mu)
	config.set_value("Audio", "sfx", s)

	var err = config.save(CONFIG_PATH)
	if err != OK:
		print("[Options] CRITICAL SAVE ERROR: ", err)
	else:
		print("[Options] SAVE SUCCESSFUL to ", CONFIG_PATH)


func update_display():
	sfx_slider.value = get_bus_volume_percent("sfx")
	music_slider.value = get_bus_volume_percent("music")
	master_slider.value = get_bus_volume_percent("Master")

	update_icons()


func on_icon_pressed(bus_name: String):
	var current_vol = get_bus_volume_percent(bus_name)
	if current_vol > 0.0:
		# Mute: store current and set to 0
		pre_mute_volumes[bus_name] = current_vol
		set_bus_volume_percent(bus_name, 0.0)
	else:
		# Unmute: restore from pre_mute_volumes
		var restore_vol = pre_mute_volumes.get(bus_name, 1.0)
		if restore_vol <= 0.0: restore_vol = 1.0
		set_bus_volume_percent(bus_name, restore_vol)

	update_display()


func update_icons():
	master_icon.texture_normal = tex_sound_off if master_slider.value <= 0.0 else tex_sound_on
	sfx_icon.texture_normal = tex_sound_off if sfx_slider.value <= 0.0 else tex_sound_on
	music_icon.texture_normal = tex_music_off if music_slider.value <= 0.0 else tex_music_on


func get_bus_volume_percent(bus_name: String) -> float:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1: return 1.0

	if AudioServer.is_bus_mute(bus_index):
		return 0.0

	var volume = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume)


func set_bus_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1: return

	if percent <= 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		var volume = linear_to_db(percent)
		AudioServer.set_bus_volume_db(bus_index, volume)


func on_apply_button_pressed():
	# Save changes to disk and close
	_save_settings()
	close_menu()


func on_reset_button_pressed():
	# Revert and close without saving
	for bus in initial_volumes:
		set_bus_volume_percent(bus, initial_volumes[bus])
	close_menu()


func close_menu():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	back_pressed.emit()


func on_audio_slider_value_changed(value: float, bus_name: String):
	set_bus_volume_percent(bus_name, value)
	update_icons()
