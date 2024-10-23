class_name UserPreferences extends Resource

enum AUDIO_BUS { MASTER }
@export var muted: bool = false
@export var level: int = 1


func save() -> void:
	ResourceSaver.save(self, "user://user_preferences.tres")
	apply_preferences()


func set_muted(new_muted: bool) -> void:
	muted = new_muted
	save()


func apply_preferences() -> void:
	print("applying preferences")
	AudioServer.set_bus_mute(AUDIO_BUS.MASTER, muted)


static func load_or_create() -> UserPreferences:
	var res: UserPreferences = load("user://user_preferences.tres") as UserPreferences
	if !res:
		res = UserPreferences.new()
	return res
