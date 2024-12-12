extends Node


@export var background_color: Palettes.COLORS = Palettes.COLORS.BG1
@export var background_hover_color: Palettes.COLORS = Palettes.COLORS.BG2
@export var foreground_color: Palettes.COLORS = Palettes.COLORS.FG1


var parent: Node


func _ready() -> void:
	parent = get_parent()
	Global.palette_changed.connect(change_palette_to)
	change_palette_to(Global.palette)


func change_palette_to(palette: int) -> void:
	parent.set("theme_override_colors/default_color", Global.palettes.get_color(palette, background_color))
	parent.set("theme_override_colors/font_outline_color", Global.palettes.get_color(palette, foreground_color))
	parent.set("theme_override_colors/font_hover_pressed_color", Global.palettes.get_color(palette, background_hover_color))
	parent.set("theme_override_colors/font_hover_color", Global.palettes.get_color(palette, background_hover_color))
	parent.set("theme_override_colors/font_pressed_color", Global.palettes.get_color(palette, background_hover_color))
	parent.set("theme_override_colors/font_focus_color", Global.palettes.get_color(palette, background_hover_color))
	parent.set("theme_override_colors/font_color", Global.palettes.get_color(palette, background_color))
	parent.set("theme_override_colors/font_outline_color", Global.palettes.get_color(palette, foreground_color))
