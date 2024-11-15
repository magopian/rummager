extends CanvasLayer


@onready var zone_top: TextureRect = %ZoneTop
@onready var zone_left: TextureRect = %ZoneLeft
@onready var zone_right: TextureRect = %ZoneRight
@onready var zone_bottom: TextureRect = %ZoneBottom


var viewport_rect: Vector2


func _ready() -> void:
	viewport_rect = get_viewport().get_visible_rect().size


func _process(_delta: float):
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var distance_to_left: float = clamp(mouse_pos.x, 0, viewport_rect.x / 2) / (viewport_rect.x / 2)
	var distance_to_top: float = clamp(mouse_pos.y, 0, viewport_rect.y / 2) / (viewport_rect.y / 2)
	var distance_to_right: float = clamp(viewport_rect.x - mouse_pos.x, 0, viewport_rect.x / 2)/ (viewport_rect.x / 2)
	var distance_to_bottom: float = clamp(viewport_rect.y - mouse_pos.y, 0, viewport_rect.y / 2)/ (viewport_rect.y / 2)
	zone_left.modulate.a = lerp(1, 0, distance_to_left)
	zone_top.modulate.a = lerp(1, 0, distance_to_top)
	zone_right.modulate.a = lerp(1, 0, distance_to_right)
	zone_bottom.modulate.a = lerp(1, 0, distance_to_bottom)


func slide_in(duration: float) -> void:
	for panel in get_children():
		Global.slide_in_screen(panel, duration)


func slide_out(duration: float) -> void:
	for panel in get_children():
		Global.slide_off_screen(panel, duration)
