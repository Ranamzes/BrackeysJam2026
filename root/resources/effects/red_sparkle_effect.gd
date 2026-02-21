@tool
class_name RichTextRedSparkle
extends RichTextEffect

var bbcode = "red_sparkle"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 2.0)

	var r = char_fx.glyph_index * 45.45 + char_fx.elapsed_time * freq * 2.0
	var t = sin(r) * 0.5 + 0.5

	var dark_red = Color(0.4, 0.0, 0.0)
	var bright_red = Color(1.0, 0.2, 0.2)

	char_fx.color = dark_red.lerp(bright_red, t)
	return true
