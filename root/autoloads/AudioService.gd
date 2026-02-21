extends Node

var current_music_player: AudioStreamPlayer
var _stream_history: Dictionary = {}

## Воспроизводит звук глобально (не обрывается при смене сцен).
## Возвращает созданный AudioStreamPlayer или null при ошибке.
##
## Параметр [param stream] может быть:
## - Одним файлом [code]AudioStream[/code].
## - Массивом файлов [code]Array[AudioStream][/code]. В этом случае звуки будут играться
##   случайно, не повторяясь, пока не проиграются все доступные варианты (как во FMOD).
##
## Параметры [param volume_db] и [param pitch_scale] могут быть:
## - Точным числом (float).
## - Диапазоном в виде массива: [code][-10.0, -5.0][/code].
## - Диапазоном в виде Vector2: [code]Vector2(0.8, 1.2)[/code].
## При передаче диапазона будет выбрано случайное значение.
##
## [b]Примеры использования:[/b]
## [codeblock]
## # Обычное воспроизведение:
## AudioService.play_sound(preload("res://sound.ogg"), &"SFX")
##
## # Статичная громкость (-5 дБ) и pitch (1.2):
## AudioService.play_sound(preload("res://sound.ogg"), &"SFX", -5.0, 1.2)
##
## # Случайные значения из массивов [min, max] (наиболее удобно):
## AudioService.play_sound(
##     preload("res://footstep.ogg"),
##     &"SFX",
##     [-12.0, -8.0], # Случайная громкость от -12 до -8 дБ
##     [0.8, 1.2]     # Случайный pitch от 0.8 до 1.2
## )
##
## # Случайный звук из массива (без повторов, как во FMOD):
## var steps = [preload("step1.ogg"), preload("step2.ogg"), preload("step3.ogg")]
## AudioService.play_sound(steps, &"SFX")
## [/codeblock]
func play_sound(stream: Variant, bus: StringName, volume_db: Variant = 0.0, pitch_scale: Variant = 1.0) -> AudioStreamPlayer:
	var actual_stream: AudioStream = null

	if stream is AudioStream:
		actual_stream = stream
	elif stream is Array and not stream.is_empty():
		# Логика FMOD: случайный звук без повторений
		if not _stream_history.has(stream) or _stream_history[stream].is_empty():
			var pool = stream.duplicate()
			pool.shuffle()
			_stream_history[stream] = pool
		actual_stream = _stream_history[stream].pop_back()

	if actual_stream == null:
		push_warning("AudioService: stream is null or invalid")
		return null

	var player = AudioStreamPlayer.new()
	player.stream = actual_stream
	player.bus = bus

	if volume_db is Array and volume_db.size() >= 2:
		player.volume_db = randf_range(volume_db[0], volume_db[1])
	elif volume_db is Vector2:
		player.volume_db = randf_range(volume_db.x, volume_db.y)
	else:
		player.volume_db = volume_db

	if pitch_scale is Array and pitch_scale.size() >= 2:
		player.pitch_scale = randf_range(pitch_scale[0], pitch_scale[1])
	elif pitch_scale is Vector2:
		player.pitch_scale = randf_range(pitch_scale.x, pitch_scale.y)
	else:
		player.pitch_scale = pitch_scale

	add_child(player)
	player.play()

	# Автоматически удаляем ноду после завершения проигрывания
	player.finished.connect(player.queue_free)

	return player

## Плавно запускает фоновую музыку с кроссфейдом.
## Если та же музыка уже играет, ничего не произойдет.
## Если играла другая музыка, она плавно заглушится за [param fade_duration] секунд.
##
## [b]Пример использования:[/b]
## [codeblock]
## AudioService.play_music(
##     preload("res://music/theme.ogg"),
##     &"Music",
##     1.5,   # Длительность перехода в секундах
##     -10.0  # Целевая громкость трека
## )
## [/codeblock]
func play_music(stream: AudioStream, bus: StringName, fade_duration: float = 1.0, volume_db: float = 0.0) -> void:
	if stream == null:
		push_warning("AudioService: music stream is null")
		return

	# Если та же самая песня уже играет, ничего не делаем
	if current_music_player != null and current_music_player.stream == stream and current_music_player.playing:
		return

	var new_player = AudioStreamPlayer.new()
	new_player.stream = stream
	new_player.bus = bus
	new_player.volume_db = -80.0 # Начинаем с тишины для фейда
	add_child(new_player)
	new_player.play()

	var tween = create_tween()

	# Если уже есть играющая музыка, плавно её заглушаем
	if current_music_player != null:
		var old_player = current_music_player
		tween.tween_property(old_player, "volume_db", -80.0, fade_duration) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		# Удаляем старый плеер после фейдаута
		tween.tween_callback(old_player.queue_free)

	# Плавно увеличиваем громкость новой музыки
	tween.parallel().tween_property(new_player, "volume_db", volume_db, fade_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	current_music_player = new_player

## Плавно останавливает играющую музыку за время [param fade_duration].
##
## [b]Пример использования:[/b]
## [codeblock]
## AudioService.stop_music(2.0) # Плавно увести звук в тишину за 2 секунды
## [/codeblock]
func stop_music(fade_duration: float = 1.0) -> void:
	if current_music_player == null:
		return

	var player_to_stop = current_music_player
	current_music_player = null

	var tween = create_tween()
	tween.tween_property(player_to_stop, "volume_db", -80.0, fade_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(player_to_stop.queue_free)
