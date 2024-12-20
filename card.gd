class_name Card extends RigidBody2D


signal clicked(card: Card)
signal left_screen(card: Card)


@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D
@onready var background: Sprite2D = %Background
@onready var pattern: Sprite2D = %Pattern
@onready var border: Sprite2D = %Border
@onready var dust_cloud: GPUParticles2D = %DustCloud
@onready var dust_trail: GPUParticles2D = %DustTrail
@onready var confetti: GPUParticles2D = %Confetti


@export var small_scale: Vector2 = Vector2(0.16, 0.16)
@export var medium_scale: Vector2 = Vector2(0.5, 0.5)
@export var big_scale: Vector2 = Vector2(1, 1)
@export var data: Dictionary
@export var to_find: bool = false


var held = false
var tween: Tween
var pop_text_scene: PackedScene = preload("res://pop_text.tscn")


static var charac_to_property: Dictionary = {
		"background_colors": "background_color",
		"colors": "color",
		"patterns": "pattern_sprite",
		"borders": "border_sprite",
	}


static var characteristics: Array = charac_to_property.keys()


func _ready() -> void:
	input_event.connect(_on_input_event)
	visible_on_screen_notifier_2d.screen_exited.connect(_on_exit_screen)
	compute_small_size(Global.viewport_size)
	get_viewport().physics_object_picking_sort = true
	init_from_data()


func compute_small_size(viewport_size: Vector2) -> void:
	var smallest_size: int = min(viewport_size.x, viewport_size.y)
	# smallest_size = 414 => small_scale = 0.16
	var scale_size: float = smallest_size * 0.16 / 414
	small_scale = Vector2(scale_size, scale_size)


func init_from_data() -> void:
	background.modulate = data["background_color"]
	pattern.texture = data["pattern_sprite"]
	pattern.modulate = data["color"]
	border.texture = data["border_sprite"]
	border.modulate = data["color"]


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)
			get_viewport().set_input_as_handled()


func _on_exit_screen() -> void:
	visible_on_screen_notifier_2d.queue_free()
	left_screen.emit(self)


func _physics_process(_delta) -> void:
	if held:
		global_transform.origin = get_global_mouse_position()


func pickup() -> void:
	if held:
		return
	freeze = true
	held = true


func zoom_in() -> void:
	show_big()
	hide_trail()


func show_big(speed: float = 0.15) -> void:
	collision_layer = 0
	scale_to(big_scale, speed)
	animate_card()


func animate_card() -> void:	
	tween = get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(self, "rotation_degrees", rotation_degrees + 5, 1)
	tween.tween_property(self, "rotation_degrees", rotation_degrees - 5, 1)


func show_small(speed: float = 0.15) -> void:
	scale_to(small_scale, speed, 1)
	if tween:
		tween.stop()


func show_medium() -> void:
	collision_layer = 0
	update_scale(medium_scale)
	freeze = true
	hide_dust()
	hide_trail()
	hide_confetti()
	animate_card()


func drop(impulse=Vector2.ZERO) -> void:
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false
		show_small()
		show_dust()
		show_trail()


func hide_dust() -> void:
	dust_cloud.emitting = false

func show_dust() -> void:
	dust_cloud.emitting = true


func hide_trail() -> void:
	dust_trail.emitting = false


func show_trail() -> void:
	dust_trail.emitting = true


func hide_confetti() -> void:
	confetti.emitting = false


func update_scale(new_scale: Vector2) -> void:
	for child in get_children():
		child.scale = new_scale


func scale_to(new_scale: Vector2, duration: float, updated_collision_layer: int = 1) -> Tween:
	var scale_tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	for child in get_children():
		scale_tween.tween_property(child, "scale", new_scale, duration)
	collision_layer = updated_collision_layer
	return scale_tween


func discard(force: float) -> void:
	var eject_angle: float = linear_velocity.angle() + PI
	var eject_position: Vector2 = global_position.clamp(Vector2.ZERO, Global.viewport_size)
	var eject_scale: float = force / 10
	linear_velocity = Vector2.ZERO
	confetti.global_position = eject_position
	confetti.scale = Vector2.ONE * eject_scale
	confetti.process_material.scale_max = eject_scale
	confetti.rotation = eject_angle
	confetti.emitting = true
	pop_number(force, eject_position, eject_angle)
	await confetti.finished
	call_deferred("queue_free")


func pop_number(force: float, eject_position: Vector2, eject_angle: float) -> void:
	var pop_text: PopText = pop_text_scene.instantiate()
	get_tree().root.add_child(pop_text)
	var score_percentage: float = Global.score % 100
	var score_pos: float = Global.viewport_size.x * score_percentage / 100
	await pop_text.pop(force, eject_position, eject_angle, Vector2(score_pos, Global.viewport_size.y))
	await get_tree().create_timer(2).timeout
	pop_text.call_deferred("queue_free")


func explode_out(interval: float = 0) -> Tween:
	if is_instance_valid(visible_on_screen_notifier_2d):
		visible_on_screen_notifier_2d.queue_free()
	var center: Vector2 = Global.viewport_size / 2
	var angle_from_center: float = center.angle_to_point(position)
	var max_size: float = max(Global.viewport_size.x, Global.viewport_size.y)
	var distance: Vector2 = Vector2(max_size, 0).rotated(angle_from_center)
	var new_pos: Vector2 = position + distance
	var explode_out_tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	explode_out_tween.tween_interval(interval)
	explode_out_tween.tween_property(self, "position", new_pos, 1)
	return explode_out_tween


func shuffle(pos: Vector2, interval: float = 0) -> Tween:
	var tween_shuffle: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_shuffle.tween_interval(interval)
	tween_shuffle.tween_property(self, "position", pos, 1)
	return tween_shuffle


func unshuffle(speed: float = 1, interval: float = 0) -> Tween:
	var center: Vector2 = Global.viewport_size / 2
	var unshuffle_tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	unshuffle_tween.tween_interval(interval)
	unshuffle_tween.tween_property(self, "position", center, speed)
	return unshuffle_tween

func get_force() -> float:
	var force: float = linear_velocity.length()
	# Smallest force accepted: 500. Max force: 5000. Anything above is bonus.
	# So multiply by 2, and divide by 1000 to get a "round percentage number":
	# 500 * 2 / 1000 = 1, 5000 * 2 / 1000 = 10. Ten cards at "max force" gives 100%.
	var normalized_force: float = force * 2 / 1000
	return normalized_force
