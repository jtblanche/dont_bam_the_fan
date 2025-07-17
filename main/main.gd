extends MarginContainer
class_name MainScene

@onready var player_1: Player = %Player1
@onready var player_2: Player = %Player2
@onready var player_3: Player = %Player3
@onready var player_4: Player = %Player4
@onready var time_label: Label = %TimeLabel
@onready var milliseconds_label: Label = %MillisecondsLabel
@onready var time_panel: PanelContainer = %TimePanel
@onready var score_margin_container: MarginContainer = %ScoreMarginContainer
@onready var score_alignment: VBoxContainer = %ScoreAlignment

@onready var game: SummerGameGame = %Game

const TOTAL_TIME := 60.0 # 2 minutes in seconds
var time_left := 0.0

func _process(delta: float) -> void:
	if time_left > 0.0:
		time_left = max(0.0, time_left - delta)
		update_label()
	else:
		time_left = 0.0
		update_label()
		game.end_game()
		connection_changes_allowed = true
		update_label_positioning()

func update_label() -> void:
	if time_left >= 60.0:
		var minutes := int(time_left) / 60
		var seconds := int(time_left) % 60
		time_label.text = "%d:%02d" % [minutes, seconds]
	elif time_left >= 10.0:
		var seconds := int(time_left) % 60
		time_label.text = "%02d" % seconds
	else:
		var seconds := int(time_left)
		var milliseconds := int((time_left - seconds) * 100)
		time_label.text = "%d:" % seconds
		milliseconds_label.text = "%02d" % milliseconds
		
func update_label_positioning() -> void:
	if connection_changes_allowed:
		time_panel.hide()
		return
	time_panel.show()
	time_label.remove_theme_font_size_override("font_size")
	milliseconds_label.remove_theme_font_size_override("font_size")
	score_margin_container.remove_theme_constant_override("margin_bottom")
	if active_players.size() <= 1:
		time_label.add_theme_font_size_override("font_size", 300)
		milliseconds_label.add_theme_font_size_override("font_size", 200)
		score_margin_container.add_theme_constant_override("margin_bottom", -20)
		score_alignment.alignment = BoxContainer.ALIGNMENT_END
		return
	time_label.add_theme_font_size_override("font_size", 150)
	milliseconds_label.add_theme_font_size_override("font_size", 100)
	score_alignment.alignment =BoxContainer.ALIGNMENT_CENTER

var connection_changes_allowed: bool = true

var available_players: Array[Player] = []
var active_players: Array[Player] = []
var device_to_player_lookup: Dictionary[int, Player] = {}
#var player_to_device_lookup: Dictionary[Player, int] = {}

func _reset_players():
	var player1 = active_players[0] if active_players.size() >= 1 else null
	if player1 != null:
		player1.player_name = "Player 1"
		player1.player_index = 0
	game.player1 = player1
	var player2 = active_players[1] if active_players.size() >= 2 else null
	if player2 != null:
		player2.player_name = "Player 2"
		player2.player_index = 1
	game.player2 = player2
	var player3 = active_players[2] if active_players.size() >= 3 else null
	if player3 != null:
		player3.player_name = "Player 3"
		player3.player_index = 2
	game.player3 = player3
	var player4 = active_players[3] if active_players.size() >= 4 else null
	if player4 != null:
		player4.player_name = "Player 4"
		player4.player_index = 3
	game.player4 = player4

func _check_input_for_disconnects(event: InputEvent):
	if !event.is_action_pressed("disconnect_player"):
		return
	if active_players.size() <= 0 :
		SceneManager.scene_manager.load_scene(SceneManager.SceneType.TITLE)
		return
	var device_id: int = event.device
	if !device_to_player_lookup.has(device_id):
		return
	print("disconnecting player...")
	var player: Player = device_to_player_lookup.get(device_id)
	player.deactivate()
	active_players.remove_at(active_players.find(player))
	_reset_players()
	available_players.append(player)
	device_to_player_lookup.erase(device_id)
	#player_to_device_lookup.erase(player)
		

func _check_input_for_connects(event: InputEvent):
	var device_id: int = event.device
	if active_players.size() >= 4 or device_to_player_lookup.has(event.device):
		return
	if event.is_action_pressed("connect_player"):
		print("connecting player...")
		var player: Player = available_players.pop_back()
		player.activate(device_id)
		active_players.append(player)
		device_to_player_lookup.set(device_id, player)
		_reset_players()
		#player_to_device_lookup.set(player, device_id)
		

func _check_for_start_game(event: InputEvent):
	var device_id: int = event.device
	if active_players.size() <= 0 or !device_to_player_lookup.has(device_id):
		return
	var player: Player = device_to_player_lookup.get(device_id)
	var active_player_index: int = active_players.find(player)
	if active_player_index != 0:
		return
	if event.is_action_pressed("start_game"):
		if connection_changes_allowed:
			print("stopping connection changes.")
			time_left = TOTAL_TIME
			milliseconds_label.text = ""
			update_label()
			game.start_game()
			connection_changes_allowed = false
			update_label_positioning()
		#else:
			#print("re-enabling connection changes.")
			#time_left = 0.0
			#update_label()
			#game.end_game()
			#connection_changes_allowed = true

func _check_connection_changes(event: InputEvent):
	if !connection_changes_allowed:
		_check_for_start_game(event)
		return
	_check_input_for_disconnects(event)
	_check_for_start_game(event)
	_check_input_for_connects(event)

func _input(event: InputEvent) -> void:
	_check_connection_changes(event)

func _reset() -> void:
	available_players.clear()
	available_players.append_array([player_4, player_3, player_2, player_1])
	active_players.clear()
	_reset_players()
	device_to_player_lookup.clear()
	time_left = 0.0
	update_label()
	update_label_positioning()
	#player_to_device_lookup.clear()
	

func _ready() -> void:
	_reset()
