extends Control


@onready var menu_icon: TextureButton = %MenuIcon


func _ready() -> void:
	Global.user_prefs.apply_preferences()
	menu_icon.toggled.connect(Global.user_prefs.set_muted)
	menu_icon.button_pressed = Global.user_prefs.muted
