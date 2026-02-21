@tool
class_name RichTextJump
extends RichTextEffect

var bbcode = "jump"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var scale: float = char_fx.env.get("scale", 8.0)
	var freq: float = char_fx.env.get("freq", 5.0)

	var time = char_fx.elapsed_time * freq
	var y = abs(sin(time + char_fx.glyph_index * 0.5)) * scale

	char_fx.offset.y -= y
	return true
