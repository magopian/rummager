extends CheckButton

@onready var user_prefs: UserPreferences


func _ready() -> void:
	Global.user_prefs.apply_preferences()
	toggled.connect(Global.user_prefs.set_muted)
	button_pressed = Global.user_prefs.muted
