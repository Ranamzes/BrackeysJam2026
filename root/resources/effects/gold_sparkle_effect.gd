@tool
class_name RichTextGoldSparkle
extends RichTextEffect

var bbcode = "gold_sparkle"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 2.5)

	var r = char_fx.glyph_index * 45.45 + char_fx.elapsed_time * freq * 2.0
	var t = sin(r) * 0.5 + 0.5

	var dark_gold = Color(0.6, 0.4, 0.0)
	var bright_gold = Color(1.0, 0.9, 0.3)

	char_fx.color = dark_gold.lerp(bright_gold, t)
	return true
