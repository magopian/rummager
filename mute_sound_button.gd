extends CheckButton

@onready var user_prefs: UserPreferences


func _ready() -> void:
	user_prefs = UserPreferences.load_or_create()
	user_prefs.apply_preferences()
	toggled.connect(user_prefs.set_muted)
	button_pressed = user_prefs.muted
