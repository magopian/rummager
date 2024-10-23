extends Node

@export var level: int:
	get = get_level,
	set = set_level


@onready var user_prefs: UserPreferences


func _ready() -> void:
	user_prefs = UserPreferences.load_or_create()


func get_level() -> int:
	return user_prefs.level


func set_level(level: int) -> void:
	user_prefs.level = level
	user_prefs.save()
