extends AudioStreamPlayer

@export var theme: AudioStream
@export var win_music: AudioStream


func _ready() -> void:
	play_theme()


func play_theme() -> void:
	stream = theme
	play()


func play_win() -> void:
	stream = win_music
	play()
