class_name Player
extends Node

var _device_id: int = -1000
var is_active: bool = false
var is_play_guitar_pressed: bool = false
var is_play_guitar_consumed: bool = false
var is_attack_enemy_pressed: bool = false
var is_attack_enemy_consumed: bool = false
var player_name: String = ""
var player_index: int = -1
@export var color: Color = Color.WHITE

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

func _input(event: InputEvent) -> void:
	if !is_active or event.device != _device_id:
		return
	if !is_play_guitar_pressed and event.is_action_pressed("play_guitar"):
		is_play_guitar_pressed = true
		print("play guitar event device: ", event.device)
		print("action strength: ", event.get_action_strength("play_guitar"))
	if is_play_guitar_pressed and event.is_action_released("play_guitar"):
		is_play_guitar_pressed = false
		is_play_guitar_consumed = false
		print("release play guitar event device: ", event.device)
		print("action strength: ", event.get_action_strength("play_guitar"))
	if !is_attack_enemy_pressed and event.is_action_pressed("attack_enemy"):
		is_attack_enemy_pressed = true
		print("attack enemy event device: ", event.device)
		print("action strength: ", event.get_action_strength("attack_enemy"))
	if is_attack_enemy_pressed and event.is_action_released("attack_enemy"):
		is_attack_enemy_pressed = false
		is_attack_enemy_consumed = false
		print("release attack enemy event device: ", event.device)
		print("action strength: ", event.get_action_strength("attack_enemy"))

func _on_device_connections_changed(device_id: int, connected: bool):
	print("device connections have changed: ")
	print("device: ", device_id)
	print("connected: ", connected, "\n")
	if device_id != _device_id:
		return
	if !is_active and connected:
		print("activated player")
		is_active = true
		return
	if is_active and !connected:
		print("deactivated player")
		is_active = false
		return

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_device_connections_changed)
