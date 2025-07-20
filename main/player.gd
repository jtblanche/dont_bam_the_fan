class_name Player
extends Node

const FAKE_TOUCH_DEVICE_ID: int = -200
var _device_id: int = -1000
var is_active: bool = false
var is_play_guitar_pressed: bool = false
var is_play_guitar_consumed: bool = false
var is_attack_enemy_pressed: bool = false
var is_attack_enemy_consumed: bool = false
var player_name: String = ""
var player_index: int = -1
@export var color: Color = Color.WHITE

static func get_device_id(event: InputEvent) -> int:
	if event is InputEventScreenTouch:
		return FAKE_TOUCH_DEVICE_ID
	return event.device
var _game_in_progress: bool = false
func start_game() -> void:
	_game_in_progress = true
	if _device_id != FAKE_TOUCH_DEVICE_ID:
		return
	is_play_guitar_pressed = true
	is_play_guitar_consumed = true
	is_attack_enemy_pressed = true
	is_attack_enemy_consumed = true

func end_game() -> void:
	_game_in_progress = false

func activate(device_id: int) -> void:
	if is_active:
		return
	_device_id = device_id
	is_active = true

func deactivate() -> void:
	_device_id = -1000
	is_active = false

func consume_play_guitar_pressed() -> bool:
	if !is_play_guitar_pressed or is_play_guitar_consumed:
		return false
	is_play_guitar_consumed = true
	return true

func consume_attack_enemy_pressed() -> bool:
	if !is_attack_enemy_pressed or is_attack_enemy_consumed:
		return false
	is_attack_enemy_consumed = true
	return true

const RIGHT_SIDE_RATIO: float = 0.6
const LEFT_SIDE_RATIO: float = 1.0 - RIGHT_SIDE_RATIO

enum TouchInputResult {
	OFFSCREEN_TOUCH = -2,
	NOT_TOUCH = -1,
	RELEASED = 0,
	RIGHT_SIDE = 1,
	LEFT_SIDE = 2
}

static func get_touch_event(event: InputEvent, viewport_visible_rect: Rect2) -> TouchInputResult:
	if not (event is InputEventScreenTouch):
		return TouchInputResult.NOT_TOUCH
	if not event.is_pressed():
		return TouchInputResult.RELEASED
	if not viewport_visible_rect.has_point(event.position):
		return TouchInputResult.OFFSCREEN_TOUCH
	var touch_x_position = event.position.x
	var left_width = viewport_visible_rect.size.x * LEFT_SIDE_RATIO
	var left_start = viewport_visible_rect.position.x
	if touch_x_position >= left_start and touch_x_position < left_start + left_width:
		return TouchInputResult.LEFT_SIDE
	return TouchInputResult.RIGHT_SIDE

func _input(event: InputEvent) -> void:
	if !_game_in_progress:
		return
	var current_device_id = get_device_id(event)
	if !is_active or current_device_id != _device_id:
		return
	if current_device_id == FAKE_TOUCH_DEVICE_ID:
		var viewport_visible_rect: Rect2 = get_viewport().get_visible_rect()
		var touch_event: TouchInputResult = get_touch_event(event, viewport_visible_rect)
		match touch_event:
			TouchInputResult.LEFT_SIDE:
				if !is_play_guitar_pressed:
					is_play_guitar_pressed = true
			TouchInputResult.RIGHT_SIDE:
				if !is_attack_enemy_pressed:
					is_attack_enemy_pressed = true
			TouchInputResult.RELEASED:
				if is_play_guitar_pressed:
					is_play_guitar_pressed = false
					is_play_guitar_consumed = false
				if is_attack_enemy_pressed:
					is_attack_enemy_pressed = false
					is_attack_enemy_consumed = false
		return
	if !is_play_guitar_pressed and event.is_action_pressed("play_guitar"):
		is_play_guitar_pressed = true
	if is_play_guitar_pressed and event.is_action_released("play_guitar"):
		is_play_guitar_pressed = false
		is_play_guitar_consumed = false
	if !is_attack_enemy_pressed and event.is_action_pressed("attack_enemy"):
		is_attack_enemy_pressed = true
	if is_attack_enemy_pressed and event.is_action_released("attack_enemy"):
		is_attack_enemy_pressed = false
		is_attack_enemy_consumed = false

func _on_device_connections_changed(device_id: int, connected: bool):
	if device_id != _device_id:
		return
	if !is_active and connected:
		is_active = true
		return
	if is_active and !connected:
		is_active = false
		return

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_device_connections_changed)
