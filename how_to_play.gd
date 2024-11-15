extends CanvasLayer


@onready var screens: Control = %Screens
@onready var click_catch: TextureButton = %ClickCatch
@onready var fade_transition: ColorRect = %FadeTransition


func _ready() -> void:
	click_catch.pressed.connect(load_next_how_to_play)


func load_next_how_to_play() -> void:
	if screens.get_child_count() <= 1:
		fade_transition.fade_to_file("res://start_menu.tscn")
	var current_image: TextureRect = screens.get_child(-1)
	var tween: Tween = current_image.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(current_image, "modulate:a", 0, 0.5)
	await tween.finished
	current_image.queue_free()
