extends CanvasLayer


@onready var zone_bottom: TextureRect = %ZoneBottom


func _ready() -> void:
	var tween: Tween = zone_bottom.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.set_loops(0)
	tween.tween_property(zone_bottom, "modulate:a", 0.3, 0.5)
	tween.tween_property(zone_bottom, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1)


func slide_in(duration: float) -> void:
	for panel in get_children():
		Global.slide_in_screen(panel, duration)


func slide_out(duration: float) -> void:
	for panel in get_children():
		Global.slide_off_screen(panel, duration)
