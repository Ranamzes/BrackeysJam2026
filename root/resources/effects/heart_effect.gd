@tool
class_name RichTextHeart
extends RichTextEffect

var bbcode = "heart"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var scale: float = char_fx.env.get("scale", 4.0)
	var freq: float = char_fx.env.get("freq", 5.0)

	var x = char_fx.glyph_index * 1.5 - char_fx.elapsed_time * freq
	var beat = abs(cos(x)) * max(0.0, smoothstep(0.7, 1.0, sin(x))) * 2.5

	char_fx.color = Color.BLUE.lerp(Color.RED, beat)
	char_fx.offset.y -= beat * scale

	var _c = char_fx.glyph_index # pseudo character check
	# We can't strictly replace specific characters without logic that tracks strings
	# as glyph_index is not ASCII code but we can fake a heartbeat motion.
	return true
