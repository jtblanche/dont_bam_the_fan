@tool
extends MarginContainer
class_name PlayerArea

@onready var player_sprite: Sprite2D = %PlayerSprite
@onready var player_animation_tree: AnimationTree = %PlayerAnimationTree
@onready var player_animation_player: AnimationPlayer = %PlayerAnimationPlayer
@onready var status_animation_player: AnimationPlayer = %StatusAnimationPlayer
@onready var score_label: Label = %Score
@onready var status_text: RichTextLabel = %"Status Text"
@onready var background_color_rect: ColorRect = %BackgroundColorRect
@onready var enemy_area: MarginContainer = %EnemyArea

var enemy_container: EnemyContainer = null

const ENEMY_CONTAINER: PackedScene = preload("res://Scenes/EnemyArea/enemy_container.tscn")

var enemy_pool: Array[EnemyContainer] = []

var _is_running: bool = false
var _is_active: bool = false:
	get:
		return player != null

@export var player: Player = null:
	get:
		return player
	set(new_player):
		if _is_running:
			return
		player = new_player
		if _is_active:
			_set_player_ready()
		else:
			_set_player_waiting()

var score: int = 0:
	get:
		return score
	set(new_score):
		score = new_score
		if score_label != null:
			update_score_label()

func update_score_label() -> void:
	score_label.text = str(score)
		
func _set_player_ready() -> void:
	if _is_running:
		return
	status_text.remove_theme_color_override("default_color")
	status_text.add_theme_color_override("default_color", player.color)
	var start_placeholder_text: String = str(player.player_name, " Ready!")
	if player.player_index == 0:
		start_placeholder_text += "\nPress Start/Enter\nto Begin Game"
		status_text.remove_theme_font_size_override("normal_font_size")
		status_text.add_theme_font_size_override("normal_font_size", 60)
	else:
		status_text.remove_theme_font_size_override("normal_font_size")
		status_text.add_theme_font_size_override("normal_font_size", 80)
	status_text.text = start_placeholder_text
		
func _set_player_waiting() -> void:
	if _is_running:
		return
	status_text.remove_theme_color_override("default_color")
	var start_placeholder_text: String = "Press\nStart/Enter\nto Join!"
	status_text.text = start_placeholder_text

func game_active() -> void:
	if !_is_running:
		return
	get_new_enemy_container_from_pool()
	status_animation_player.play("to_playing")
	
	

func game_inactive() -> void:
	if !_is_running:
		return

func start_game() -> void:
	if _is_running:
		return
	_is_player_attacking = false
	_is_running = true
	score_label.show()
	status_text.hide()
	score = 0
	if _is_active:
		game_active()
	else:
		game_inactive()

func end_game() -> void:
	if !_is_running:
		return
	_is_player_attacking = false
	_is_running = false
	if enemy_container != null:
		enemy_container.hit()
	status_text.show()
	if _is_active:
		status_animation_player.play("to_waiting")
		_set_player_ready()
	else:
		_set_player_waiting()

var _is_player_attacking: bool = false

func player_start_attack() -> void:
	_is_player_attacking = true
	
var _is_player_serenading: bool = false

func player_start_serenade() -> void:
	_is_player_serenading = true
	
func hit_player_serenade() -> void:
	if enemy_container.was_interacted:
		return
	enemy_container.serenade()
	match enemy_container.enemy_status:
		EnemyContainer.EnemyStatus.FRIENDLY:
			status_animation_player.play("success")
			score = score + 1
		EnemyContainer.EnemyStatus.ENEMY:
			status_animation_player.play("error")
			score = score - 1
	get_new_enemy_container_from_pool()
	
func finish_player_serenade() -> void:
	_is_player_serenading = false
	match enemy_container.enemy_status:
		EnemyContainer.EnemyStatus.FRIENDLY:
			return
		EnemyContainer.EnemyStatus.ENEMY:
			return

	
func hit_player_attack() -> void:
	if enemy_container.was_interacted:
		return
	enemy_container.hit()
	match enemy_container.enemy_status:
		EnemyContainer.EnemyStatus.FRIENDLY:
			status_animation_player.play("error")
			score = score -1
		EnemyContainer.EnemyStatus.ENEMY:
			status_animation_player.play("success")
			score = score + 1
	get_new_enemy_container_from_pool()

func finish_player_attack() -> void:
	_is_player_attacking = false
	match enemy_container.enemy_status:
		EnemyContainer.EnemyStatus.FRIENDLY:
			return
		EnemyContainer.EnemyStatus.ENEMY:
			return

func _ready() -> void:
	_set_player_waiting()
	status_animation_player.play("waiting")
	enemy_pool.clear()
	
	for index in range(5):
		var new_enemy_container = ENEMY_CONTAINER.instantiate()
		new_enemy_container.completed.connect(return_enemy_container_to_pool)
		return_enemy_container_to_pool(new_enemy_container)
		# Get the AnimationNodeStateMachinePlayback object
		
	var state_machine_playback = player_animation_tree.get("parameters/playback")

	# Connect the signals
	state_machine_playback.animation_node_entered.connect(_on_animation_node_entered)
	state_machine_playback.animation_node_exited.connect(_on_animation_node_exited)

func _on_animation_node_entered(node: String):
	# 'node' contains the name of the newly entered animation node
	print("Entered animation node:", node)
	# You can add your logic here based on the new state

func _on_animation_node_exited(node: String):
	# 'node' contains the name of the animation node that was exited
	print("Exited animation node:", node)
	# You can add your logic here based on the previous state

func get_new_enemy_container_from_pool():
	enemy_container = enemy_pool.pop_front()
	enemy_area.add_child(enemy_container)
	enemy_container.is_in_scene = true
	enemy_container.score = score
	enemy_container.start()

func return_enemy_container_to_pool(old_enemy_container: EnemyContainer):
	if !enemy_pool.has(old_enemy_container):
		if old_enemy_container.is_in_scene:
			enemy_area.remove_child(old_enemy_container)
		old_enemy_container.is_in_scene = false
		enemy_pool.append(old_enemy_container)


func _process(_delta: float) -> void:
	if !_is_running or !_is_active or (enemy_container != null and enemy_container.was_interacted) or _is_player_attacking or _is_player_serenading:
		return
	var attacked = player.consume_attack_enemy_pressed()
	var performed = player.consume_play_guitar_pressed()
	match enemy_container.enemy_status:
		EnemyContainer.EnemyStatus.FRIENDLY:
			if attacked:
				player_start_attack()
				return
			if performed:
				player_start_serenade()
				return
		EnemyContainer.EnemyStatus.ENEMY:
			if performed:
				player_start_serenade()
				return
			if attacked:
				player_start_attack()
				return
	
