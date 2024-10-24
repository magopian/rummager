extends CanvasLayer


@onready var texture_rect: TextureRect = %TextureRect


@export var images: Array[CompressedTexture2D]

func _ready() -> void:
	texture_rect.gui_input.connect(_on_gui_input)
	load_next_how_to_play()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		print("loading next")
		load_next_how_to_play()


func load_next_how_to_play() -> void:
	if images.size():
		texture_rect.texture = images.pop_front()
	else:
		get_tree().change_scene_to_file("res://start_menu.tscn")
