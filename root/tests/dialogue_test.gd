extends Node

const DialogueVariantScript = preload("res://root/components/dialogue/dialogue_variant.gd")

func _ready() -> void:
	print("Starting DialogueVariant Tests...")

	# Verify ProgressionManager is present
	if not get_node("/root/ProgressionManager"):
		printerr("ERROR: ProgressionManager autoload not found!")
		get_tree().quit(1)
		return

	_test_no_conditions()
	_test_single_true_condition()
	_test_single_false_condition()
	_test_mixed_conditions()

	print("All tests passed!")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func _test_no_conditions() -> void:
	print("Test 1: No conditions")
	var variant = DialogueVariantScript.new()
	variant.start_title = "default"
	assert(variant.are_conditions_met() == true, "Should be true with no conditions")

func _test_single_true_condition() -> void:
	print("Test 2: Single True Condition")
	var variant = DialogueVariantScript.new()
	var cond: Dictionary[String, bool] = {"flag_a": true}
	variant.conditions = cond

	ProgressionManager.set_flag("flag_a", false)
	assert(variant.are_conditions_met() == false, "Should fail when flag false")

	ProgressionManager.set_flag("flag_a", true)
	assert(variant.are_conditions_met() == true, "Should pass when flag true")

func _test_single_false_condition() -> void:
	print("Test 3: Single False Condition")
	var variant = DialogueVariantScript.new()
	var cond: Dictionary[String, bool] = {"flag_b": false}
	variant.conditions = cond

	ProgressionManager.set_flag("flag_b", true)
	assert(variant.are_conditions_met() == false, "Should fail when flag true")

	ProgressionManager.set_flag("flag_b", false)
	assert(variant.are_conditions_met() == true, "Should pass when flag false")

func _test_mixed_conditions() -> void:
	print("Test 4: Mixed Conditions")
	var variant = DialogueVariantScript.new()
	var cond: Dictionary[String, bool] = {
		"flag_a": true,
		"flag_b": false
	}
	variant.conditions = cond

	# Case 1: Both correct
	ProgressionManager.set_flag("flag_a", true)
	ProgressionManager.set_flag("flag_b", false)
	assert(variant.are_conditions_met() == true, "Should pass with correct flags")

	# Case 2: One wrong (flag_b is true, should be false)
	ProgressionManager.set_flag("flag_b", true)
	assert(variant.are_conditions_met() == false, "Should fail if one condition mismatch")
