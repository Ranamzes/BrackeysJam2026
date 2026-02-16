extends Node

const DialogueTriggerScript = preload("res://root/components/dialogue/dialogue_trigger.gd")
const DialogueVariantScript = preload("res://root/components/dialogue/dialogue_variant.gd")

func _ready() -> void:
	print("Starting Sprite Interaction Tests...")
	_test_auto_setup()
	_test_pixel_perfect_logic()
	print("All Sprite Interaction tests passed!")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func _test_auto_setup() -> void:
	print("Test: Auto-setup for Sprite2D")
	var sprite = Sprite2D.new()
	sprite.name = "TestSprite"
	add_child(sprite)

	# Mock a texture
	var img = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	sprite.texture = ImageTexture.create_from_image(img)

	var trigger = DialogueTriggerScript.new()
	sprite.add_child(trigger)

	# Trigger manual setup (since we can't wait for deferred in this sync test easily without await)
	trigger._perform_auto_setup()

	var shape_found = false
	for child in trigger.get_children():
		if child is CollisionShape2D:
			assert(child.shape is RectangleShape2D, "Should create RectangleShape2D")
			assert(child.shape.size == Vector2(100, 100), "Size should match texture")
			shape_found = true
			break

	assert(shape_found, "Should have created a CollisionShape2D")
	print("  Auto-setup passed.")

func _test_pixel_perfect_logic() -> void:
	print("Test: Pixel-perfect clicking")
	var sprite = Sprite2D.new()
	add_child(sprite)

	# Create a 2x2 image: [Opaque, Transparent]
	#                     [Transparent, Opaque]
	var img = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	img.set_pixel(0, 0, Color(1, 1, 1, 1))
	img.set_pixel(1, 0, Color(1, 1, 1, 0))
	img.set_pixel(0, 1, Color(1, 1, 1, 0))
	img.set_pixel(1, 1, Color(1, 1, 1, 1))

	sprite.texture = ImageTexture.create_from_image(img)
	sprite.centered = false

	var trigger = DialogueTriggerScript.new()
	sprite.add_child(trigger)
	trigger.pixel_perfect = true

	# Test Opaque (0,0)
	assert(trigger._check_pixel_opaque(Vector2(0.5, 0.5)) == true, "Opaque pixel should pass")

	# Test Transparent (1,0)
	assert(trigger._check_pixel_opaque(Vector2(1.5, 0.5)) == false, "Transparent pixel should fail")

	# Test Opaque (1,1)
	assert(trigger._check_pixel_opaque(Vector2(1.5, 1.5)) == true, "Opaque pixel (corner) should pass")

	# Test Out of Bounds
	assert(trigger._check_pixel_opaque(Vector2(5, 5)) == false, "Out of bounds should fail")

	# Test Centered Sprite
	sprite.centered = true
	# (0,0) texture coordinate is now at local (-1,-1)
	assert(trigger._check_pixel_opaque(Vector2(-0.5, -0.5)) == true, "Opaque pixel (centered) should pass")
	assert(trigger._check_pixel_opaque(Vector2(0.5, -0.5)) == false, "Transparent pixel (centered) should fail")

	print("  Pixel-perfect logic passed.")
