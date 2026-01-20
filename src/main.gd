extends Control
## Main scene script demonstrating AdvancedButton features.
##
## This script showcases 8 different configurations of the AdvancedButton
## component, including layout variations, toggles, and state handling.

#region Node References
@onready var btn1: AdvancedButton = $CenterContainer/GridContainer/Btn1
@onready var btn2: AdvancedButton = $CenterContainer/GridContainer/Btn2
@onready var btn3: AdvancedButton = $CenterContainer/GridContainer/Btn3
@onready var btn4: AdvancedButton = $CenterContainer/GridContainer/Btn4
@onready var btn5: AdvancedButton = $CenterContainer/GridContainer/Btn5
@onready var btn6: AdvancedButton = $CenterContainer/GridContainer/Btn6
@onready var btn7: AdvancedButton = $CenterContainer/GridContainer/Btn7
@onready var btn8: AdvancedButton = $CenterContainer/GridContainer/Btn8
#endregion

func _ready() -> void:
	# --- Example 1: Default Button ---
	if btn1:
		btn1.pressed.connect(func(): print("1. Default Button Pressed"))

	# --- Example 2: Texture Only ---
	if btn2:
		btn2.pressed.connect(func(): print("2. Texture Only Button Pressed"))

	# --- Example 3: Label Left ---
	if btn3:
		btn3.pressed.connect(func(): print("3. Label Left Button Pressed"))

	# --- Example 4: Label Top ---
	if btn4:
		btn4.pressed.connect(func(): print("4. Label Top Button Pressed"))

	# --- Example 5: Toggle Mode ---
	if btn5:
		# Update label immediately to match initial state (though it starts OFF)
		_update_toggle_label(btn5.button_pressed)
		
		btn5.toggled.connect(func(toggled_on: bool):
			print("5. Toggle Button: ", "ON" if toggled_on else "OFF")
			_update_toggle_label(toggled_on)
		)

	# --- Example 6: Toggle Lock ---
	if btn6:
		btn6.pressed.connect(func():
			if btn6.button_pressed:
				print("6. Toggle Lock: Locked! Right-click to reset.")
		)
		
		# Add manual reset capability since left-click won't untoggle it
		btn6.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				if btn6.button_pressed:
					btn6.button_pressed = false
					print("6. Toggle Lock: Reset via Right-Click script")
		)

	# --- Example 7: Disabled ---
	# Disabled buttons don't emit 'pressed', but we can still reference them
	if btn7:
		pass # It's just disabled visually

	# --- Example 8: Inside/Modulate ---
	if btn8:
		btn8.pressed.connect(func(): print("8. Inside Label Button Pressed"))


## Updates the text of the toggle button based on its state.
func _update_toggle_label(is_on: bool) -> void:
	if is_on:
		btn5.label_text = "5. Toggle: ON"
	else:
		btn5.label_text = "5. Toggle: OFF"
