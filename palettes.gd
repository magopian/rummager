class_name Palettes extends Resource


@export var palettes: Array[Dictionary]


enum COLORS {BG1, BG2, FG1, FG2}
static var background_colors: Array[COLORS] = [COLORS.BG1, COLORS.BG2]
static var foreground_colors: Array[COLORS] = [COLORS.FG1, COLORS.FG2]


func get_color(index: int, color: COLORS) -> Color:
	return palettes[index][color]


func get_random_bg(index: int) -> Color:
	return palettes[index][background_colors.pick_random()]


func get_random_fg(index: int) -> Color:
	return palettes[index][background_colors.pick_random()]
