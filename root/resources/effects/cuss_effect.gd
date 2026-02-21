@tool
class_name RichTextCuss
extends RichTextEffect

var bbcode = "cuss"
const CHARS = ["@", "#", "$", "%", "&", "!", "*", "?"]

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Cuss randomizes glyphs, wait we can't do that simply anymore in Godot 4
	# without manually rebuilding the text.
	# The built-in effect does jitter
	var freq = char_fx.env.get("freq", 10.0)
	var scale = char_fx.env.get("scale", 2.0)

	var t = char_fx.elapsed_time * freq + char_fx.glyph_index * 12.3
	char_fx.offset.y += sin(t) * scale
	char_fx.offset.x += cos(t * 1.5) * scale

	char_fx.color = Color.RED.lerp(Color.WHITE, sin(t) * 0.5 + 0.5)

	return true
