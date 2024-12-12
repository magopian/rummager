class_name UserPreferences extends Resource

enum AUDIO_BUS { MASTER }
@export var muted: bool = false
@export var level: int = 1
@export var palette: int = 0


const USER_PREFERENCES_FILE = "user://user_preferences.tres"


func save() -> void:
	ResourceSaver.save(self, "user://user_preferences.tres")
	apply_preferences()


func set_muted(new_muted: bool) -> void:
	muted = new_muted
	save()


func apply_preferences() -> void:
	AudioServer.set_bus_mute(AUDIO_BUS.MASTER, muted)


static func load_or_create() -> UserPreferences:
	var res: UserPreferences
	if ResourceLoader.exists(USER_PREFERENCES_FILE):
		res = load(USER_PREFERENCES_FILE)
	else:
		res = UserPreferences.new()
	return res
