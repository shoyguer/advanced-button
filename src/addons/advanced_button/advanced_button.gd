# MIT License
# Copyright (c) 2025 Lucas "Shoyguer" Melo

@tool
class_name AdvancedButton
extends BaseButton
## Deeply customizable simple button.
##
## Button with texture, stylebox, label and more customization options.


#region Properties

#region Constants & Enums
const DEFAULT_TEXTURE_SIZE := Vector2.ZERO
const LABEL_SETTINGS: LabelSettings = preload("res://addons/advanced_button/resources/label_settings.tres")
const NORMAL_STYLEBOX_RES: StyleBoxFlat = preload("res://addons/advanced_button/resources/normal_stylebox.tres")
const HOVER_STYLEBOX_RES: StyleBoxFlat = preload("res://addons/advanced_button/resources/hover_stylebox.tres")
const PRESSED_STYLEBOX_RES: StyleBoxFlat = preload("res://addons/advanced_button/resources/pressed_stylebox.tres")
const DISABLED_STYLEBOX_RES: StyleBoxFlat = preload("res://addons/advanced_button/resources/disabled_stylebox.tres")

const LABEL_PROPERTIES = [
	"label_text",
	"label_settings",
	"label_separation",
	"label_position",
	"label_horizontal_position",
	"label_vertical_position",
	"label_offset",
	"label_margin_left",
	"label_margin_top",
	"label_margin_right",
	"label_margin_bottom"
]

const TEXTURE_PROPERTIES = [
	"texture_size",
	"_reset_size_action",
	"normal_texture",
	"hover_texture",
	"pressed_texture",
	"disabled_texture"
]

const STYLEBOX_PROPERTIES = [
	"normal_stylebox",
	"hover_stylebox",
	"pressed_stylebox",
	"disabled_stylebox"
]

const MODULATE_PROPERTIES = [
	"normal_modulate",
	"hover_modulate",
	"pressed_modulate",
	"disabled_modulate"
]

## Label position options.
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

## Label horizontal position options.
enum LabelHorizontalPosition {
	## Label text aligned to the left
	LEFT,
	## Label text centered
	CENTER,
	## Label text aligned to the right
	RIGHT
}

## Label vertical position options.
enum LabelVerticalPosition {
	## Label text aligned to the top
	TOP,
	## Label text centered
	CENTER,
	## Label text aligned to the bottom
	BOTTOM
}
#endregion

## If enabled, a toggled (pressed) button cannot be untoggled by clicking, only by code.
@export var toggle_lock: bool = false: set = _set_toggle_lock
## Whether the button uses label text.
@export var use_label: bool = true: set = _set_use_label
## Whether the textures should be used.
@export var use_texture: bool = false: set = _set_use_texture
## Whether the styleboxes should be used.
@export var use_stylebox: bool = true: set = _set_use_stylebox
## Whether the modulation should be used.
@export var use_modulate: bool = false: set = _set_use_modulate

#region Label
@export_group("Label")
## The text displayed on the label.
@export var label_text: String = "Button": set = _set_label_text
## The settings for the label (font, color, shadow, etc).
@export var label_settings: LabelSettings = LABEL_SETTINGS: set = _set_label_settings

@export_subgroup("Label Positioning")
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

@export_subgroup("Label Margins")
## The left margin of the label.
@export var label_margin_left: int = 0: set = _set_label_margin_left
## The top margin of the label.
@export var label_margin_top: int = 0: set = _set_label_margin_top
## The right margin of the label.
@export var label_margin_right: int = 0: set = _set_label_margin_right
## The bottom margin of the label.
@export var label_margin_bottom: int = 0: set = _set_label_margin_bottom
#endregion

#region Appearance
@export_group("Textures")
## The fixed size of the texture.
@export var texture_size := Vector2.ZERO: set = _set_texture_size
## Button used for reseting texture size to default.
@export_tool_button("Set default size", "TextureRect") var _reset_size_action = _reset_texture_size
## The texture used when the texture is in its normal state.
@export var normal_texture: Texture2D = null: set = _set_normal_texture
## The texture used when the texture is hovered.
@export var hover_texture: Texture2D = null: set = _set_hover_texture
## The texture used when the texture is pressed.
@export var pressed_texture: Texture2D = null: set = _set_pressed_texture
## The texture used when the texture is disabled.
@export var disabled_texture: Texture2D = null: set = _set_disabled_texture

@export_group("Style Boxes")
## The stylebox used when the button is in its normal state.
@export var normal_stylebox: StyleBox = NORMAL_STYLEBOX_RES: set = _set_normal_stylebox
## The stylebox used when the button is hovered.
@export var hover_stylebox: StyleBox = HOVER_STYLEBOX_RES: set = _set_hover_stylebox
## The stylebox used when the button is pressed.
@export var pressed_stylebox: StyleBox = PRESSED_STYLEBOX_RES: set = _set_pressed_stylebox
## The stylebox used when the button is disabled.
@export var disabled_stylebox: StyleBox = DISABLED_STYLEBOX_RES: set = _set_disabled_stylebox

@export_group("Modulation")
## The modulation used when the button is in its normal state.
@export var normal_modulate: Color = Color.WHITE: set = _set_normal_modulate
## The modulation used when the button is hovered.
@export var hover_modulate: Color = Color.WHITE: set = _set_hover_modulate
## The modulation used when the button is pressed.
@export var pressed_modulate: Color = Color.WHITE: set = _set_pressed_modulate
## The modulation used when the button is disabled.
@export var disabled_modulate: Color = Color.WHITE: set = _set_disabled_modulate
#endregion

var _texture_rect := Rect2()
var _label_rect := Rect2()
var _cached_label_size := Vector2.ZERO
#endregion


func _validate_property(property: Dictionary) -> void:
	if not use_label:
		if property.name in LABEL_PROPERTIES:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if not use_texture:
		if property.name in TEXTURE_PROPERTIES:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if not use_stylebox:
		if property.name in STYLEBOX_PROPERTIES:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if not use_modulate:
		if property.name in MODULATE_PROPERTIES:
			property.usage = PROPERTY_USAGE_NO_EDITOR


func _ready() -> void:
	normal_texture = normal_texture
	hover_texture = hover_texture
	pressed_texture = pressed_texture
	disabled_texture = disabled_texture

	texture_size = texture_size
	
	_update_cached_label_size()
	queue_redraw()


## Calculates the minimum size required for the button
func _get_minimum_size() -> Vector2:
	var max_min_size = Vector2.ZERO
	
	# Define states to check
	var states = [
		{"tex": normal_texture, "sb": normal_stylebox},
		{"tex": hover_texture, "sb": hover_stylebox},
		{"tex": pressed_texture, "sb": pressed_stylebox},
		{"tex": disabled_texture, "sb": disabled_stylebox}
	]
	
	for i in range(states.size()):
		var state = states[i]
		var tex = state.tex
		var sb = state.sb
		
		# Fallback logic
		if i > 0: # Hover, Pressed, Disabled
			if tex == null: tex = normal_texture
			if sb == null: sb = normal_stylebox
		
		# 1. Texture Size
		var tex_size = DEFAULT_TEXTURE_SIZE
		if use_texture:
			if tex: tex_size = tex.get_size()
			if texture_size != Vector2.ZERO: tex_size = texture_size
		
		# 2. StyleBox Margins
		var sb_margins = Vector2.ZERO
		if use_stylebox and sb:
			sb_margins.x = sb.get_margin(SIDE_LEFT) + sb.get_margin(SIDE_RIGHT)
			sb_margins.y = sb.get_margin(SIDE_TOP) + sb.get_margin(SIDE_BOTTOM)
		
		# 3. Content Size
		var content_size = tex_size
		
		if use_label:
			var label_size = _cached_label_size
			label_size += Vector2(label_margin_left + label_margin_right, label_margin_top + label_margin_bottom)
			
			var padding = float(label_separation) if (use_texture and tex_size != Vector2.ZERO) else 0.0
			
			match label_position:
				LabelPosition.BOTTOM, LabelPosition.TOP:
					content_size = Vector2(max(tex_size.x, label_size.x), tex_size.y + padding + label_size.y)
				LabelPosition.LEFT, LabelPosition.RIGHT:
					content_size = Vector2(tex_size.x + padding + label_size.x, max(tex_size.y, label_size.y))
				LabelPosition.INSIDE:
					content_size = tex_size.max(label_size)
		
		max_min_size = max_min_size.max(content_size + sb_margins)
	
	return max_min_size


## Calculates layout and draws everything
func _draw() -> void:
	_calculate_layout()
	
	# Draw stylebox
	if use_stylebox:
		_draw_stylebox()
	
	# Draw texture
	if use_texture:
		_draw_texture()
	
	# Draw label
	if use_label:
		_draw_label()


func _toggled(toggled_on: bool) -> void:
	if toggle_lock and not toggled_on:
		set_pressed_no_signal(true)


#region Layout & Drawing
## Calculates the positions of texture and label based on layout
func _calculate_layout() -> void:
	var tex_size = DEFAULT_TEXTURE_SIZE
	
	if use_texture:
		var texture_to_draw = _get_current_texture()
		
		if texture_to_draw:
			tex_size = texture_to_draw.get_size()
			
		if texture_size != Vector2.ZERO:
			tex_size = texture_size
	
	# Padding between texture and label
	var padding = float(label_separation) if use_texture else 0.0

	# Calculate label size if needed
	var label_text_size = Vector2.ZERO
	var label_full_size = Vector2.ZERO
	
	if use_label:
		label_text_size = _cached_label_size
		label_full_size = label_text_size + Vector2(label_margin_left + label_margin_right, label_margin_top + label_margin_bottom)
	
	var total_content_size = Vector2.ZERO
	
	# Temporary rects relative to content origin (0,0)
	var temp_tex_rect = Rect2(Vector2.ZERO, tex_size)
	var temp_label_rect = Rect2(Vector2.ZERO, label_full_size)
	
	match label_position:
		LabelPosition.BOTTOM:
			temp_tex_rect.position = Vector2.ZERO
			temp_label_rect.position = Vector2(0, tex_size.y + padding)
			
			total_content_size = Vector2(max(tex_size.x, label_full_size.x), tex_size.y + padding + label_full_size.y)
			
			temp_tex_rect.position.x = (total_content_size.x - tex_size.x) / 2.0
			temp_label_rect.position.x = (total_content_size.x - label_full_size.x) / 2.0
			
		LabelPosition.TOP:
			temp_label_rect.position = Vector2.ZERO
			temp_tex_rect.position = Vector2(0, label_full_size.y + padding)
			
			total_content_size = Vector2(max(tex_size.x, label_full_size.x), label_full_size.y + padding + tex_size.y)
			
			temp_tex_rect.position.x = (total_content_size.x - tex_size.x) / 2.0
			temp_label_rect.position.x = (total_content_size.x - label_full_size.x) / 2.0
			
		LabelPosition.LEFT:
			temp_label_rect.position = Vector2.ZERO
			temp_tex_rect.position = Vector2(label_full_size.x + padding, 0)
			
			total_content_size = Vector2(label_full_size.x + padding + tex_size.x, max(tex_size.y, label_full_size.y))
			
			temp_tex_rect.position.y = (total_content_size.y - tex_size.y) / 2.0
			temp_label_rect.position.y = (total_content_size.y - label_full_size.y) / 2.0
			
		LabelPosition.RIGHT:
			temp_tex_rect.position = Vector2.ZERO
			temp_label_rect.position = Vector2(tex_size.x + padding, 0)
			
			total_content_size = Vector2(tex_size.x + padding + label_full_size.x, max(tex_size.y, label_full_size.y))
			
			temp_tex_rect.position.y = (total_content_size.y - tex_size.y) / 2.0
			temp_label_rect.position.y = (total_content_size.y - label_full_size.y) / 2.0
			
		LabelPosition.INSIDE:
			total_content_size = tex_size.max(label_full_size)
			temp_tex_rect.position = (total_content_size - tex_size) / 2.0
			temp_label_rect.position = (total_content_size - label_full_size) / 2.0
	
	# Get stylebox margins
	var sb_margin_left = 0.0
	var sb_margin_top = 0.0
	var sb_margin_right = 0.0
	var sb_margin_bottom = 0.0
	
	var sb = _get_current_stylebox()
	if use_stylebox and sb:
		sb_margin_left = sb.get_margin(SIDE_LEFT)
		sb_margin_top = sb.get_margin(SIDE_TOP)
		sb_margin_right = sb.get_margin(SIDE_RIGHT)
		sb_margin_bottom = sb.get_margin(SIDE_BOTTOM)
	
	var available_size = size - Vector2(sb_margin_left + sb_margin_right, sb_margin_top + sb_margin_bottom)
	var content_origin = Vector2(sb_margin_left, sb_margin_top)
	
	# Center total content in available space
	var offset = (available_size - total_content_size) / 2.0
	var final_origin = content_origin + offset
	
	_texture_rect = temp_tex_rect
	_texture_rect.position += final_origin
	
	_label_rect = temp_label_rect
	_label_rect.position += final_origin
	
	# Expand label rect to fill available space for alignment, respecting margins
	if label_position == LabelPosition.BOTTOM or label_position == LabelPosition.TOP:
		_label_rect.position.x = content_origin.x
		_label_rect.size.x = available_size.x
		
		if label_position == LabelPosition.BOTTOM:
			var top_limit = _texture_rect.position.y + _texture_rect.size.y + padding
			_label_rect.position.y = top_limit
			_label_rect.size.y = max(label_full_size.y, (content_origin.y + available_size.y) - top_limit)
		elif label_position == LabelPosition.TOP:
			var bottom_limit = _texture_rect.position.y - padding
			_label_rect.position.y = content_origin.y
			_label_rect.size.y = max(label_full_size.y, bottom_limit - content_origin.y)
	
	if label_position == LabelPosition.LEFT or label_position == LabelPosition.RIGHT:
		_label_rect.position.y = content_origin.y
		_label_rect.size.y = available_size.y
	
	# Apply label margins to get the inner text rect
	_label_rect.position.x += label_margin_left
	_label_rect.position.y += label_margin_top
	_label_rect.size.x = max(0, _label_rect.size.x - (label_margin_left + label_margin_right))
	_label_rect.size.y = max(0, _label_rect.size.y - (label_margin_top + label_margin_bottom))
	
	# Clamp positions to stay within control boundaries (optional, but good for safety)
	# _texture_rect.position = _texture_rect.position.max(Vector2.ZERO)
	# _label_rect.position = _label_rect.position.max(Vector2.ZERO)



func _update_cached_label_size() -> void:
	var font = ThemeDB.fallback_font
	var font_size = ThemeDB.fallback_font_size
	
	if label_settings:
		if label_settings.font:
			font = label_settings.font
		if label_settings.font_size > 0:
			font_size = label_settings.font_size
	
	if not font or label_text.is_empty():
		_cached_label_size = Vector2.ZERO
		return
	
	var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	_cached_label_size = Vector2(text_size.x, font.get_height(font_size))


func _draw_stylebox() -> void:
	var stylebox = _get_current_stylebox()
	if stylebox:
		stylebox.draw(get_canvas_item(), Rect2(Vector2.ZERO, size))


func _draw_texture() -> void:
	var texture_to_draw = _get_current_texture()
	if not texture_to_draw: return
	
	var modulate_color = Color.WHITE
	if use_modulate:
		modulate_color = _get_current_modulate()
	
	draw_set_transform(_texture_rect.position)
	draw_texture_rect(texture_to_draw, Rect2(Vector2.ZERO, _texture_rect.size), false, modulate_color)
	draw_set_transform(Vector2.ZERO)


func _draw_label() -> void:
	if not use_label: return
	
	var font = ThemeDB.fallback_font
	var font_size = ThemeDB.fallback_font_size
	var font_color = Color.WHITE
	var outline_size = 0
	var outline_color = Color.BLACK
	var shadow_size = 0
	var shadow_color = Color.BLACK
	var shadow_offset = Vector2.ONE
	
	if label_settings:
		if label_settings.font:
			font = label_settings.font
		if label_settings.font_size > 0:
			font_size = label_settings.font_size
		font_color = label_settings.font_color
		outline_size = label_settings.outline_size
		outline_color = label_settings.outline_color
		shadow_size = label_settings.shadow_size
		shadow_color = label_settings.shadow_color
		shadow_offset = label_settings.shadow_offset
	
	if use_modulate:
		var mod = _get_current_modulate()
		font_color *= mod
		outline_color *= mod
		shadow_color *= mod
	
	var text_pos = _label_rect.position
	
	# Standard single-line drawing
	var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var text_height = font.get_height(font_size)
	var text_ascent = font.get_ascent(font_size)
	
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
	if shadow_size > 0 and shadow_color.a > 0:
		draw_set_transform(shadow_offset, 0.0, Vector2.ONE)
		
		# Draw shadow spread (using outline for spread effect if size > 0)
		draw_string_outline(
			font,
			text_pos,
			label_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1, font_size,
			shadow_size,
			shadow_color
		)
			
		# Draw shadow base
		draw_string(
			font,
			text_pos,
			label_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1, font_size,
			shadow_color
		)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Outline drawing
	if outline_size > 0:
		draw_string_outline(
			font,
			text_pos,
			label_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1, font_size,
			outline_size,
			outline_color
		)
	
	# Draw main text with LEFT alignment since we've already positioned it
	draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, font_color)
#endregion


#region State Helpers
## Gets the current texture based on button state
func _get_current_texture() -> Texture2D:
	match get_draw_mode():
		DRAW_NORMAL:
			return normal_texture
		DRAW_HOVER:
			return hover_texture if hover_texture else normal_texture
		DRAW_PRESSED, DRAW_HOVER_PRESSED:
			return pressed_texture if pressed_texture else normal_texture
		DRAW_DISABLED:
			return disabled_texture if disabled_texture else normal_texture
	return normal_texture


## Gets the current stylebox based on button state
func _get_current_stylebox() -> StyleBox:
	match get_draw_mode():
		DRAW_NORMAL:
			return normal_stylebox
		DRAW_HOVER:
			return hover_stylebox if hover_stylebox else normal_stylebox
		DRAW_PRESSED, DRAW_HOVER_PRESSED:
			return pressed_stylebox if pressed_stylebox else normal_stylebox
		DRAW_DISABLED:
			return disabled_stylebox if disabled_stylebox else normal_stylebox
	return normal_stylebox


## Gets the current modulation based on button state
func _get_current_modulate() -> Color:
	match get_draw_mode():
		DRAW_NORMAL:
			return normal_modulate
		DRAW_HOVER:
			return hover_modulate
		DRAW_PRESSED, DRAW_HOVER_PRESSED:
			return pressed_modulate
		DRAW_DISABLED:
			return disabled_modulate
	return normal_modulate
#endregion


#region Setters
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



func _set_use_stylebox(value: bool) -> void:
	use_stylebox = value
	notify_property_list_changed()
	queue_redraw()


func _set_use_texture(value: bool) -> void:
	use_texture = value
	notify_property_list_changed()
	queue_redraw()


func _set_use_modulate(value: bool) -> void:
	use_modulate = value
	notify_property_list_changed()
	queue_redraw()



#region Appearance
func _on_stylebox_changed() -> void:
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_normal_stylebox(value: StyleBox) -> void:
	if normal_stylebox == value: return
	if normal_stylebox and normal_stylebox.changed.is_connected(_on_stylebox_changed):
		normal_stylebox.changed.disconnect(_on_stylebox_changed)
	normal_stylebox = value
	if normal_stylebox and not normal_stylebox.changed.is_connected(_on_stylebox_changed):
		normal_stylebox.changed.connect(_on_stylebox_changed)
	_on_stylebox_changed()


func _set_hover_stylebox(value: StyleBox) -> void:
	if hover_stylebox == value: return
	if hover_stylebox and hover_stylebox.changed.is_connected(_on_stylebox_changed):
		hover_stylebox.changed.disconnect(_on_stylebox_changed)
	hover_stylebox = value
	if hover_stylebox and not hover_stylebox.changed.is_connected(_on_stylebox_changed):
		hover_stylebox.changed.connect(_on_stylebox_changed)
	_on_stylebox_changed()


func _set_pressed_stylebox(value: StyleBox) -> void:
	if pressed_stylebox == value: return
	if pressed_stylebox and pressed_stylebox.changed.is_connected(_on_stylebox_changed):
		pressed_stylebox.changed.disconnect(_on_stylebox_changed)
	pressed_stylebox = value
	if pressed_stylebox and not pressed_stylebox.changed.is_connected(_on_stylebox_changed):
		pressed_stylebox.changed.connect(_on_stylebox_changed)
	_on_stylebox_changed()


func _set_disabled_stylebox(value: StyleBox) -> void:
	if disabled_stylebox == value: return
	if disabled_stylebox and disabled_stylebox.changed.is_connected(_on_stylebox_changed):
		disabled_stylebox.changed.disconnect(_on_stylebox_changed)
	disabled_stylebox = value
	if disabled_stylebox and not disabled_stylebox.changed.is_connected(_on_stylebox_changed):
		disabled_stylebox.changed.connect(_on_stylebox_changed)
	_on_stylebox_changed()


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


func _set_normal_modulate(value: Color) -> void:
	normal_modulate = value
	queue_redraw()


func _set_hover_modulate(value: Color) -> void:
	hover_modulate = value
	queue_redraw()


func _set_pressed_modulate(value: Color) -> void:
	pressed_modulate = value
	queue_redraw()


func _set_disabled_modulate(value: Color) -> void:
	disabled_modulate = value
	queue_redraw()
#endregion


#region Label
func _set_use_label(value: bool) -> void:
	use_label = value
	notify_property_list_changed()
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


func _set_label_settings(value: LabelSettings) -> void:
	if label_settings == value: return
	if label_settings and label_settings.changed.is_connected(queue_redraw):
		label_settings.changed.disconnect(queue_redraw)
		label_settings.changed.disconnect(_update_cached_label_size)
		label_settings.changed.disconnect(_calculate_layout)
		label_settings.changed.disconnect(update_minimum_size)
	
	label_settings = value
	
	if label_settings:
		if not label_settings.changed.is_connected(queue_redraw):
			label_settings.changed.connect(queue_redraw)
			label_settings.changed.connect(_update_cached_label_size)
			label_settings.changed.connect(_calculate_layout)
			label_settings.changed.connect(update_minimum_size)
	
	_update_cached_label_size()
	_calculate_layout()
	update_minimum_size()
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


func _set_label_margin_left(value: int) -> void:
	label_margin_left = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_label_margin_top(value: int) -> void:
	label_margin_top = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_label_margin_right(value: int) -> void:
	label_margin_right = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()


func _set_label_margin_bottom(value: int) -> void:
	label_margin_bottom = value
	_calculate_layout()
	update_minimum_size()
	queue_redraw()
#endregion
#endregion
