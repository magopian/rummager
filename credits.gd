extends CanvasLayer


@onready var menu_button: Button = %MenuButton
@onready var click_catch: TextureButton = %ClickCatch
@onready var fade_transition: ColorRect = %FadeTransition


func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	click_catch.pressed.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	fade_transition.fade_to_file("res://start_menu.tscn")
