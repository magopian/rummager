extends Node




func next_level() -> String:
	match Global.level:
		1:
			if Global.user_prefs.tutorial_started:
				return "res://levels/level_validate_discard_bonus_target.tscn"
			else:
				# TODO: remove this, it's not its place (not needed when we don't have a custom tutorial anymore)
				Global.user_prefs.tutorial_started = true
				Global.user_prefs.save()
				return "res://tutorial_1_memorize.tscn"
		_:
			return "res://levels/level_validate_discard_bonus_target.tscn"
