extends Control


@onready var card_1: TextureButton = %Card1
@onready var card_2: TextureButton = %Card2

func _ready() -> void:
	Global.user_prefs.apply_preferences()
	card_1.pressed.connect(_on_card_pressed)
	card_2.pressed.connect(_on_card_pressed)
	card_1.change_palette_to(Global.get_next_palette())
	card_2.change_palette_to(Global.get_next_palette())


func _on_card_pressed() -> void:
	Global.change_palette()
	card_1.call_deferred("change_palette_to", Global.get_next_palette())
	card_2.call_deferred("change_palette_to", Global.get_next_palette())
