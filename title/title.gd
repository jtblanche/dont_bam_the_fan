extends MarginContainer
class_name TitlePage

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
@onready var player_start_animation: AnimatedSprite2D = %PlayerStartAnimation
@onready var enemy_start_animation: AnimatedSprite2D = %EnemyStartAnimation
@onready var player_quit_animation: AnimatedSprite2D = %PlayerQuitAnimation
@onready var enemy_quit_animation: AnimatedSprite2D = %EnemyQuitAnimation

var _start_was_pressed = false
var _quit_was_pressed = false
var _any_pressed = false:
	get:
		return _start_was_pressed or _quit_was_pressed
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("disconnect_player"):
		quit_button.grab_focus()

func reset():
	_start_was_pressed = false
	_quit_was_pressed = false

var loaded_scene = null

func _ready() -> void:
	reset()
	start_button.grab_focus()


func _on_start_button_pressed() -> void:
	if _any_pressed:
		return
	_start_was_pressed = true
	player_start_animation.play("hit")
	enemy_start_animation.play("hit")
	var tween = create_tween()
	tween.tween_callback(_start).set_delay(0.4)

func _start() -> void:
	SceneManager.scene_manager.load_scene(SceneManager.SceneType.HOW_TO_PLAY)


func _on_quit_button_pressed() -> void:
	if _any_pressed:
		return
	_quit_was_pressed = true
	player_quit_animation.play("hit")
	enemy_quit_animation.play("hit")
	var tween = create_tween()
	tween.tween_callback(_quit).set_delay(0.4)

func _quit() -> void:
	get_tree().quit()


func _on_start_button_focus_entered() -> void:
	if _quit_was_pressed:
		quit_button.grab_focus()
		return
	if _start_was_pressed:
		return
	player_start_animation.show()
	enemy_start_animation.show()
	player_start_animation.play("default")
	enemy_start_animation.play("default")


func _on_start_button_focus_exited() -> void:
	if _any_pressed:
		return
	player_start_animation.hide()
	enemy_start_animation.hide()


func _on_quit_button_focus_entered() -> void:
	if _start_was_pressed:
		start_button.grab_focus()
		return
	if _quit_was_pressed:
		return
	player_quit_animation.show()
	enemy_quit_animation.show()
	player_quit_animation.play("default")
	enemy_quit_animation.play("default")


func _on_quit_button_focus_exited() -> void:
	if _any_pressed:
		return
	player_quit_animation.hide()
	enemy_quit_animation.hide()
