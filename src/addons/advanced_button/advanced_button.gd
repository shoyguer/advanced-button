@tool
class_name GeneralButton
extends Control
## General use button.


#region Properties
## Emitted when button is pressed.
signal button_pressed(button: GeneralButton)

#region Constants & Enums
const DEFAULT_TEXTURE_SIZE := Vector2.ZERO

## Button visual states
enum ButtonState {
	NORMAL,
	HOVER,
	PRESSED,
	DISABLED
}

## Label position options
enum LabelPosition {
	## Label positioned below the texture
	BOTTOM,
	## Label positioned above the texture
	TOP,
	## Label positioned to the left of the texture
	LEFT,
	## Label positioned to the right of the texture
	RIGHT,
	## Label overlaid inside the texture
	INSIDE
}

## Label horizontal position options
enum LabelHorizontalPosition {
	## Label text aligned to the left
	LEFT,
	## Label text centered
	CENTER,
	## Label text aligned to the right
	RIGHT
}

## Label vertical position options
enum LabelVerticalPosition {
	## Label text aligned to the top
	TOP,
	## Label text centered
	CENTER,
	## Label text aligned to the bottom
	BOTTOM
}
#endregion

## The current visual state of the button.
@export var button_state := ButtonState.NORMAL: set = _set_button_state
## Whether the stylebox should change with interaction and disabled state.
@export var stylebox_interaction: bool = true: set = _set_stylebox_interaction
## Whether the textures should change with interaction and disabled state.
@export var texture_interaction: bool = false: set = _set_texture_interaction

## Whether the button is toggable.
@export var toggable: bool = false: set = _set_toggable
## If enabled, a toggled (pressed) button cannot be untoggled by clicking, only by code.
@export var toggle_lock: bool = false: set = _set_toggle_lock
## Whether the button is disabled.
@export var is_disabled: bool = false: set = _set_is_disabled

#region Label
@export_category("Label")
## Whether the texture has a label.
@export var has_label: bool = true: set = _set_has_label
## The text displayed on the label.
@export var label_text: String = "Button": set = _set_label_text
## The font used for the label text.
@export var label_font: Font = null: set = _set_label_font
## The color of the font.
@export var font_color := Color(1, 1, 1, 1): set = _set_font_color
## The font size of the label.
@export var font_size: int = 16: set = _set_font_size
## The color of the font outline.

@export_group("Label Effects")
## The outline size of the font.
@export var font_outline_size: int = 0: set = _set_font_outline_size
## The color of the font outline.
@export var font_outline_color := Color.BLACK: set = _set_font_outline_color
## Whether the label has a shadow.
@export var label_shadow: bool = false: set = _set_label_shadow
## The color of the font shadow.
@export var font_shadow_color := Color.BLACK: set = _set_font_shadow_color
## The offset of the font shadow.
@export var font_shadow_offset := Vector2.ONE: set = _set_font_shadow_offset
## The spread of the font shadow.
@export var font_shadow_spread: int = 0: set = _set_font_shadow_spread
@export_group("Label Positioning")
## The separation between the label and the texture.
@export var label_separation: int = 4: set = _set_label_separation
## The position of the label relative to the texture.
@export var label_position := LabelPosition.INSIDE: set = _set_label_position
## The horizontal position of the label text.
@export var label_horizontal_position := LabelHorizontalPosition.CENTER: set = _set_label_horizontal_position
## The vertical position of the label text.
@export var label_vertical_position := LabelVerticalPosition.CENTER: set = _set_label_vertical_position
## The offset of the label text.
@export var label_offset := Vector2.ZERO: set = _set_label_offset
#endregion

#region Appearance
@export_category("Appearance")

@export_subgroup("Textures")
## The fixed size of the texture.
@export var texture_size := Vector2.ZERO: set = _set_texture_size
@export_tool_button("Reset Size", "TextureRect") var reset_size_action = _reset_texture_size

## The texture used when the texture is in its normal state.
@export var normal_texture: Texture2D = null: set = _set_normal_texture
## The texture used when the texture is hovered.
@export var hover_texture: Texture2D = null: set = _set_hover_texture
## The texture used when the texture is pressed.
@export var pressed_texture: Texture2D = null: set = _set_pressed_texture
## The texture used when the texture is disabled.
@export var disabled_texture: Texture2D = null: set = _set_disabled_texture

@export_subgroup("Style Boxes")
## The stylebox used when the button is in its normal state.
@export var normal_stylebox: StyleBox = null: set = _set_normal_stylebox
## The stylebox used when the button is hovered.
@export var hover_stylebox: StyleBox = null: set = _set_hover_stylebox
## The stylebox used when the button is pressed.
@export var pressed_stylebox: StyleBox = null: set = _set_pressed_stylebox
## The stylebox used when the button is disabled.
@export var disabled_stylebox: StyleBox = null: set = _set_disabled_stylebox
#endregion

var _texture_rect := Rect2()
var _label_rect := Rect2()
var _cached_label_size := Vector2.ZERO
#endregion


#region Lifecycle
func _ready() -> void:
	normal_texture = normal_texture
	hover_texture = hover_texture
	pressed_texture = pressed_texture
	disabled_texture = disabled_texture

	button_state = button_state
	is_disabled = is_disabled
	toggable = toggable
	texture_size = texture_size
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	resized.connect(_calculate_layout)
	
	_update_cached_label_size()
	_calculate_layout()


## Calculates the minimum size required for the button
func _get_minimum_size() -> Vector2:
	var tex_size = DEFAULT_TEXTURE_SIZE
	var texture_to_draw = _get_current_texture()
	
	if texture_to_draw:
		tex_size = texture_to_draw.get_size()
	
	if texture_size != Vector2.ZERO:
		tex_size = texture_size
	
	if not has_label:
		return tex_size
	
	var label_size = _cached_label_size
	var padding = float(label_separation)
	
	match label_position:
		LabelPosition.BOTTOM, LabelPosition.TOP:
			return Vector2(max(tex_size.x, label_size.x), tex_size.y + padding + label_size.y)
		LabelPosition.LEFT, LabelPosition.RIGHT:
			return Vector2(tex_size.x + padding + label_size.x, max(tex_size.y, label_size.y))
		LabelPosition.INSIDE:
			return tex_size.max(label_size)
	
	return tex_size


## Calculates layout and draws everything
func _draw() -> void:
	# Draw stylebox
	if stylebox_interaction:
		_draw_stylebox()
	
	# Draw texture
	if texture_interaction:
		_draw_texture()
	
	# Draw label
	if has_label:
		_draw_label()
#endregion


#region Layout & Drawing
## Calculates the positions of texture and label based on layout
func _calculate_layout() -> void:
	var tex_size = DEFAULT_TEXTURE_SIZE
	var texture_to_draw = _get_current_texture()
	
	if texture_to_draw:
		tex_size = texture_to_draw.get_size()
		
	if texture_size != Vector2.ZERO:
		tex_size = texture_size
	
	# Padding between texture and label
	var padding = float(label_separation)

	# Calculate label size if needed
	var label_size = Vector2.ZERO
	
	if has_label:
		label_size = _cached_label_size
	
	var total_size = Vector2.ZERO
	
	match label_position:
		LabelPosition.BOTTOM:
			_texture_rect = Rect2(Vector2.ZERO, tex_size)
			# Label gets full width of the button, positioned below texture
			_label_rect = Rect2(Vector2(0, tex_size.y + padding), Vector2(size.x, label_size.y))
			total_size = Vector2(tex_size.x, tex_size.y + padding + label_size.y)
			
		LabelPosition.TOP:
			# Label gets full width of the button, positioned above texture
			_label_rect = Rect2(Vector2.ZERO, Vector2(size.x, label_size.y))
			_texture_rect = Rect2(Vector2(0, label_size.y + padding), tex_size)
			total_size = Vector2(tex_size.x, label_size.y + padding + tex_size.y)
			
		LabelPosition.LEFT:
			_label_rect = Rect2(Vector2.ZERO, Vector2(label_size.x, tex_size.y))
			_texture_rect = Rect2(Vector2(label_size.x + padding, 0), tex_size)
			total_size = Vector2(label_size.x + padding + tex_size.x, tex_size.y)
			
		LabelPosition.RIGHT:
			_texture_rect = Rect2(Vector2.ZERO, tex_size)
			_label_rect = Rect2(Vector2(tex_size.x + padding, 0), Vector2(label_size.x, tex_size.y))
			total_size = Vector2(tex_size.x + padding + label_size.x, tex_size.y)
			
		LabelPosition.INSIDE:
			_texture_rect = Rect2(Vector2.ZERO, tex_size)
			_label_rect = Rect2(Vector2.ZERO, tex_size)
			total_size = tex_size
	
	# Center content in the node, but keep labels aligned to boundaries
	var offset = (size - total_size) / 2.0
	_texture_rect.position += offset
	_label_rect.position += offset
	
	# For BOTTOM/TOP labels, align to left boundary and use full width
	if label_position == LabelPosition.BOTTOM or label_position == LabelPosition.TOP:
		_label_rect.position.x = 0
		_label_rect.size.x = size.x
		
		if label_position == LabelPosition.BOTTOM:
			_label_rect.size.y = size.y - _label_rect.position.y
		elif label_position == LabelPosition.TOP:
			var bottom_limit = _texture_rect.position.y - padding
			_label_rect.position.y = 0
			_label_rect.size.y = max(0, bottom_limit)
	
	# For LEFT/RIGHT labels, align to top boundary and use full height
	if label_position == LabelPosition.LEFT or label_position == LabelPosition.RIGHT:
		_label_rect.position.y = 0
		_label_rect.size.y = size.y
	
	# Clamp positions to stay within control boundaries
	_texture_rect.position = _texture_rect.position.max(Vector2.ZERO)
	_label_rect.position = _label_rect.position.max(Vector2.ZERO)
	
	# Clamp sizes to not exceed control boundaries
	_texture_rect.size = _texture_rect.size.min(size - _texture_rect.position)
	_label_rect.size = _label_rect.size.min(size - _label_rect.position)


func _update_cached_label_size() -> void:
	var font = label_font if label_font else ThemeDB.fallback_font
	var _font_size = font_size if font_size > 0 else ThemeDB.fallback_font_size
	
	if not font or label_text.is_empty():
		_cached_label_size = Vector2.ZERO
		return
	
	var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)
	_cached_label_size = Vector2(text_size.x, font.get_height(_font_size))


func _draw_stylebox() -> void:
	var stylebox = _get_current_stylebox()
	if stylebox:
		stylebox.draw(get_canvas_item(), Rect2(Vector2.ZERO, size))


func _draw_texture() -> void:
	var texture_to_draw = _get_current_texture()
	if not texture_to_draw: return
	
	draw_set_transform(_texture_rect.position)
	draw_texture_rect(texture_to_draw, Rect2(Vector2.ZERO, _texture_rect.size), false)
	draw_set_transform(Vector2.ZERO)


func _draw_label() -> void:
	if not has_label: return
	
	var font = label_font if label_font else ThemeDB.fallback_font
	var _font_size = font_size if font_size > 0 else ThemeDB.fallback_font_size
	
	var color = font_color
	var text_pos = _label_rect.position
	
	# Standard single-line drawing
	var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)
	var text_height = font.get_height(_font_size)
	var text_ascent = font.get_ascent(_font_size)
	
	# Adjust for vertical position on label rect
	match label_vertical_position:
		LabelVerticalPosition.TOP:
			text_pos.y = _label_rect.position.y + text_ascent
		LabelVerticalPosition.BOTTOM:
			text_pos.y = _label_rect.position.y + _label_rect.size.y - text_height + text_ascent
		LabelVerticalPosition.CENTER:
			text_pos.y += (_label_rect.size.y - text_height) / 2.0 + text_ascent
	
	# Adjust for horizontal position on label rect
	match label_horizontal_position:
		LabelHorizontalPosition.LEFT:
			text_pos.x = _label_rect.position.x
		LabelHorizontalPosition.RIGHT:
			text_pos.x = _label_rect.position.x + _label_rect.size.x - text_size.x
		LabelHorizontalPosition.CENTER:
			text_pos.x = _label_rect.position.x + (_label_rect.size.x - text_size.x) / 2.0
			
	text_pos += label_offset
	
	# Shadow drawing
	if label_shadow and font_shadow_color.a > 0:
		draw_set_transform(font_shadow_offset, 0.0, Vector2.ONE)
		
		# Draw shadow spread
		if font_shadow_spread > 0:
			draw_string_outline(
				font,
				text_pos,
				label_text,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1, _font_size,
				font_shadow_spread,
				font_shadow_color
			)
			
		# Draw shadow base
		draw_string(
			font,
			text_pos,
			label_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1, _font_size,
			font_shadow_color
		)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Outline drawing
	if font_outline_size > 0:
		draw_string_outline(
			font,
			text_pos,
			label_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1, _font_size,
			font_outline_size,
			font_outline_color
		)
	
	# Draw main text with LEFT alignment since we've already positioned it
	draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size, color)
#endregion


#region State Helpers
## Gets the current texture based on button state
func _get_current_texture() -> Texture2D:
	match button_state:
		ButtonState.NORMAL:
			return normal_texture
		ButtonState.HOVER:
			return hover_texture if hover_texture else normal_texture
		ButtonState.PRESSED:
			return pressed_texture if pressed_texture else normal_texture
		ButtonState.DISABLED:
			return disabled_texture if disabled_texture else normal_texture
	return normal_texture


## Gets the current stylebox based on button state
func _get_current_stylebox() -> StyleBox:
	match button_state:
		ButtonState.NORMAL:
			return normal_stylebox
		ButtonState.HOVER:
			return hover_stylebox if hover_stylebox else normal_stylebox
		ButtonState.PRESSED:
			return pressed_stylebox if pressed_stylebox else normal_stylebox
		ButtonState.DISABLED:
			return disabled_stylebox if disabled_stylebox else normal_stylebox
	return normal_stylebox


## Toggles the button between PRESSED and NORMAL states (for toggable buttons).
func toggle() -> void:
	if not toggable or is_disabled: return
	
	if button_state == ButtonState.PRESSED:
		button_state = ButtonState.NORMAL
	else:
		button_state = ButtonState.PRESSED
	button_pressed.emit(self)
#endregion


#region Input Handlers
func _on_mouse_entered() -> void:
	if is_disabled: return
	if button_state == ButtonState.NORMAL:
		button_state = ButtonState.HOVER


func _on_mouse_exited() -> void:
	if is_disabled: return
	if button_state == ButtonState.HOVER:
		button_state = ButtonState.NORMAL


## Handles mouse input for button functionality.
func _on_gui_input(event: InputEvent) -> void:
	if is_disabled: return
	
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if toggable:
				# For toggable buttons, toggle on release
				if not mouse_event.pressed:
					# If toggle_lock is enabled and button is pressed, don't allow untoggle by click
					if toggle_lock and button_state == ButtonState.PRESSED: return
					
					if button_state == ButtonState.PRESSED:
						button_state = ButtonState.NORMAL
					else:
						button_state = ButtonState.PRESSED
					button_pressed.emit(self)
			else:
				# For non-toggable buttons, show pressed while held down
				if mouse_event.pressed:
					button_state = ButtonState.PRESSED
				elif button_state == ButtonState.PRESSED:
					button_state = ButtonState.HOVER
					button_pressed.emit(self)
#endregion


#region Setters
func _set_toggable(value: bool) -> void:
	toggable = value


func _set_toggle_lock(value: bool) -> void:
	toggle_lock = value


func _reset_texture_size() -> void:
	if normal_texture:
		self.texture_size = normal_texture.get_size()
		return
	
	self.texture_size = Vector2.ZERO


func _set_texture_size(value: Vector2) -> void:
	texture_size = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_is_disabled(value: bool) -> void:
	is_disabled = value
	if is_disabled:
		button_state = ButtonState.DISABLED
		return
	
	button_state = ButtonState.NORMAL


func _set_stylebox_interaction(value: bool) -> void:
	stylebox_interaction = value
	queue_redraw()


func _set_texture_interaction(value: bool) -> void:
	texture_interaction = value
	queue_redraw()


func _set_button_state(value: ButtonState) -> void:
	button_state = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


#region Appearance
func _set_normal_stylebox(value: StyleBox) -> void:
	if normal_stylebox == value: return
	if normal_stylebox and normal_stylebox.changed.is_connected(queue_redraw):
		normal_stylebox.changed.disconnect(queue_redraw)
	normal_stylebox = value
	if normal_stylebox and not normal_stylebox.changed.is_connected(queue_redraw):
		normal_stylebox.changed.connect(queue_redraw)
	queue_redraw()


func _set_hover_stylebox(value: StyleBox) -> void:
	if hover_stylebox == value: return
	if hover_stylebox and hover_stylebox.changed.is_connected(queue_redraw):
		hover_stylebox.changed.disconnect(queue_redraw)
	hover_stylebox = value
	if hover_stylebox and not hover_stylebox.changed.is_connected(queue_redraw):
		hover_stylebox.changed.connect(queue_redraw)
	queue_redraw()


func _set_pressed_stylebox(value: StyleBox) -> void:
	if pressed_stylebox == value: return
	if pressed_stylebox and pressed_stylebox.changed.is_connected(queue_redraw):
		pressed_stylebox.changed.disconnect(queue_redraw)
	pressed_stylebox = value
	if pressed_stylebox and not pressed_stylebox.changed.is_connected(queue_redraw):
		pressed_stylebox.changed.connect(queue_redraw)
	queue_redraw()


func _set_disabled_stylebox(value: StyleBox) -> void:
	if disabled_stylebox == value: return
	if disabled_stylebox and disabled_stylebox.changed.is_connected(queue_redraw):
		disabled_stylebox.changed.disconnect(queue_redraw)
	disabled_stylebox = value
	if disabled_stylebox and not disabled_stylebox.changed.is_connected(queue_redraw):
		disabled_stylebox.changed.connect(queue_redraw)
	queue_redraw()


func _set_normal_texture(value: Texture2D) -> void:
	normal_texture = value
	if normal_texture:
		texture_size = normal_texture.get_size()

	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_hover_texture(value: Texture2D) -> void:
	hover_texture = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_pressed_texture(value: Texture2D) -> void:
	pressed_texture = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_disabled_texture(value: Texture2D) -> void:
	disabled_texture = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()
#endregion


#region Label
func _set_has_label(value: bool) -> void:
	has_label = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_label_position(value: LabelPosition) -> void:
	label_position = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_label_text(value: String) -> void:
	label_text = value
	_update_cached_label_size()
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_label_font(value: Font) -> void:
	label_font = value
	_update_cached_label_size()
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_font_color(value: Color) -> void:
	font_color = value
	queue_redraw()


func _set_font_size(value: int) -> void:
	font_size = max(0, value)
	_update_cached_label_size()
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_font_outline_color(value: Color) -> void:
	font_outline_color = value
	queue_redraw()


func _set_font_outline_size(value: int) -> void:
	font_outline_size = max(0, value)
	queue_redraw()


func _set_label_shadow(value: bool) -> void:
	label_shadow = value
	queue_redraw()


func _set_font_shadow_color(value: Color) -> void:
	font_shadow_color = value
	queue_redraw()


func _set_font_shadow_offset(value: Vector2) -> void:
	font_shadow_offset = value
	queue_redraw()


func _set_font_shadow_spread(value: int) -> void:
	font_shadow_spread = max(0, value)
	queue_redraw()


func _set_label_separation(value: int) -> void:
	label_separation = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_label_horizontal_position(value: LabelHorizontalPosition) -> void:
	label_horizontal_position = value
	queue_redraw()


func _set_label_vertical_position(value: LabelVerticalPosition) -> void:
	label_vertical_position = value
	queue_redraw()


func _set_label_offset(value: Vector2) -> void:
	label_offset = value
	queue_redraw()
#endregion
#endregion
