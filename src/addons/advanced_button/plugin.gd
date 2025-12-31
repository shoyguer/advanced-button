@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("AdvancedButton", "BaseButton", preload("advanced_button.gd"), preload("advanced_button.svg"))


func _exit_tree() -> void:
	remove_custom_type("AdvancedButton")
