extends MarginContainer
class_name HowToPlay

@onready var back_button: Button = %BackButton
@onready var next_button: Button = %NextButton
@onready var player_back_animation: AnimatedSprite2D = %PlayerBackAnimation
@onready var enemy_back_animation: AnimatedSprite2D = %EnemyBackAnimation
@onready var player_next_animation: AnimatedSprite2D = %PlayerNextAnimation
@onready var enemy_next_animation: AnimatedSprite2D = %EnemyNextAnimation
@onready var player_step_1_animation: AnimatedSprite2D = %PlayerStep1Animation
@onready var player_step_2_animation: AnimatedSprite2D = %PlayerStep2Animation
@onready var enemy_step_2_animation: AnimatedSprite2D = %EnemyStep2Animation

var MAIN_SCENE: PackedScene = preload("res://main/main.tscn")

var _next_was_pressed = false
var _back_was_pressed = false
var _any_pressed = false:
	get:
		return _next_was_pressed or _back_was_pressed
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("disconnect_player"):
		SceneManager.scene_manager.load_scene(SceneManager.SceneType.TITLE)

func reset():
	_next_was_pressed = false
	_back_was_pressed = false

var loaded_scene = null

func _ready() -> void:
	player_step_1_animation.play("default")
	player_step_2_animation.play("hit")
	enemy_step_2_animation.play("hit")
	reset()
	next_button.grab_focus()
	loaded_scene = MAIN_SCENE.instantiate()


func _on_next_button_pressed() -> void:
	if _any_pressed:
		return
	_next_was_pressed = true
	player_next_animation.play("hit")
	enemy_next_animation.play("hit")
	var tween = create_tween()
	tween.tween_callback(_next).set_delay(0.4)

func _next() -> void:
	SceneManager.scene_manager.load_scene(SceneManager.SceneType.MAIN)


func _on_back_button_pressed() -> void:
	if _any_pressed:
		return
	_back_was_pressed = true
	player_back_animation.play("hit")
	enemy_back_animation.play("hit")
	var tween = create_tween()
	tween.tween_callback(_back).set_delay(0.4)

func _back() -> void:
	SceneManager.scene_manager.load_scene(SceneManager.SceneType.TITLE)


func _on_next_button_focus_entered() -> void:
	if _back_was_pressed:
		back_button.grab_focus()
		return
	if _next_was_pressed:
		return
	player_next_animation.show()
	enemy_next_animation.show()
	player_next_animation.play("default")
	enemy_next_animation.play("default")


func _on_next_button_focus_exited() -> void:
	if _any_pressed:
		return
	player_next_animation.hide()
	enemy_next_animation.hide()


func _on_back_button_focus_entered() -> void:
	if _next_was_pressed:
		next_button.grab_focus()
		return
	if _back_was_pressed:
		return
	player_back_animation.show()
	enemy_back_animation.show()
	player_back_animation.play("default")
	enemy_back_animation.play("default")


func _on_back_button_focus_exited() -> void:
	if _any_pressed:
		return
	player_back_animation.hide()
	enemy_back_animation.hide()
