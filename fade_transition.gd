extends ColorRect


@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

@export var transition_time: float = 0.5

func fade_in() -> void:
	modulate.a = 1
	show()
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0, transition_time)
	await tween.finished
	hide()


func fade_out(sound: AudioStream = null) -> void:
	var audio: AudioStreamPlayer
	if sound:
		audio = play_sound(sound)
	modulate.a = 0
	show()
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 1, transition_time)
	await tween.finished
	if sound and audio.playing:
		await audio.finished


func fade_to_file(file: String, sound: AudioStream = null) -> void:
	var scene: PackedScene = load(file)
	var node: Node = scene.instantiate()
	fade_to_node(node, sound)


func fade_to_node(node: Node, sound: AudioStream = null) -> void:
	await fade_out(sound)
	get_tree().root.add_child(node)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = node


func play_sound(sound: AudioStream) -> AudioStreamPlayer:
	audio_stream_player.stream = sound
	audio_stream_player.play()
	return audio_stream_player
