class_name TransitionEffects
extends Node

@export var sounds : Array[AudioStream]

func play_sound() -> void :
	if ! sounds.is_empty() :
		AudioService.play_sound(sounds, &"SFX", [-12, -6], [0.5, 1.2])
