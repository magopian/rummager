@tool
extends TextureButton



"""
We only connect the background's button signals as it should be the 
bigger of the two buttons, and as such, we shouldn't lose any signal.
This avoids having signals sent multiple times for what we want to
behave as a single button.
"""

@onready var foreground: TextureButton = %Foreground


@export var background_texture: CompressedTexture2D
@export var foreground_texture: CompressedTexture2D
@export var background_texture_pressed: CompressedTexture2D
@export var foreground_texture_pressed: CompressedTexture2D
@export var background_color: Color
@export var foreground_color: Color
@export var foreground_hover_color: Color


func _ready() -> void:
	Global.palette_changed.connect(change_palette_to)
	if not background_color:
		background_color = Global.palettes.get_color(Global.palette, Palettes.COLORS.FG1)
	if not foreground_color:
		foreground_color = Global.palettes.get_color(Global.palette, Palettes.COLORS.BG1)
	if not foreground_hover_color:
		foreground_hover_color = Global.palettes.get_color(Global.palette, Palettes.COLORS.BG2)
	set_textures(self, background_texture if not button_pressed else background_texture_pressed)
	set_textures(foreground, foreground_texture if not button_pressed else foreground_texture_pressed)
	self_modulate = background_color
	foreground.modulate = foreground_color
	pressed.connect(_on_pressed)
	toggled.connect(_on_toggled)
	focus_entered.connect(_on_hover.bind(true))
	mouse_entered.connect(_on_hover.bind(true))
	focus_exited.connect(_on_hover.bind(false))
	mouse_exited.connect(_on_hover.bind(false))


func _on_pressed() -> void:
	# TODO: animate a squash and stretch
	pass


func _on_toggled(toggled_on: bool) -> void:
	set_textures(self, background_texture if not toggled_on else background_texture_pressed)
	set_textures(foreground, foreground_texture if not toggled_on else foreground_texture_pressed)


func _on_hover(hovering: bool) -> void:
	foreground.modulate = foreground_hover_color if hovering else foreground_color


func set_textures(button: TextureButton, texture: CompressedTexture2D) -> void:
	button.texture_normal = texture
	button.texture_pressed = texture
	button.texture_hover = texture
	button.texture_disabled = texture
	button.texture_focused = texture


func change_palette_to(palette: int) -> void:
	background_color = Global.palettes.get_color(palette, Palettes.COLORS.FG1)
	foreground_color = Global.palettes.get_color(palette, Palettes.COLORS.BG1)
	foreground_hover_color = Global.palettes.get_color(palette, Palettes.COLORS.BG2)
	self_modulate = background_color
	foreground.modulate = foreground_color
