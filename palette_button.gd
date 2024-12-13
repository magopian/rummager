extends Control


@onready var card_1: TextureButton = %Card1
@onready var card_2: TextureButton = %Card2


var tween: Tween


func _ready() -> void:
	Global.user_prefs.apply_preferences()
	card_1.pressed.connect(_on_card_pressed)
	card_2.pressed.connect(_on_card_pressed)
	pivot_offset = size / 2
	animate_palette_switching()


func animate_palette_switching() -> void:
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(2)
	tween.tween_callback(change_palette_to.bind(Global.get_next_palette()))
	tween.parallel().tween_property(self, "rotation_degrees", 5, 0.2)
	tween.tween_property(self, "rotation_degrees", -5, 0.4)
	tween.tween_property(self, "rotation_degrees", 0, 0.2)
	tween.tween_callback(change_palette_to.bind(Global.palette))
	tween.set_loops()


func _on_card_pressed() -> void:
	Global.change_palette()
	animate_palette_switching()


func change_palette_to(palette: int) -> void:
	card_1.change_palette_to(palette)
	card_2.change_palette_to(palette)
