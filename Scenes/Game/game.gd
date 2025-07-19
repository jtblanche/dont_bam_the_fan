@tool
extends MarginContainer
class_name SummerGameGame

@onready var player_top_box_1: PlayerBox = %PlayerTopBox1
@onready var player_top_box_2: PlayerBox = %PlayerTopBox2
@onready var player_bottom_box_1: PlayerBox = %PlayerBottomBox1
@onready var player_bottom_box_2: PlayerBox = %PlayerBottomBox2
@onready var top_box_left_margin: MarginContainer = %TopBoxLeftMargin
@onready var top_box_right_margin: MarginContainer = %TopBoxRightMargin
@onready var bottom_box_left_margin: MarginContainer = %BottomBoxLeftMargin
@onready var bottom_box_right_margin: MarginContainer = %BottomBoxRightMargin
@onready var top_box: HBoxContainer = %TopBox
@onready var bottom_box: HBoxContainer = %BottomBox
@onready var add_player_bottom_container: MarginContainer = %AddPlayerBottomContainer

@onready var music_player: AudioStreamPlayer = %MusicPlayer

var _player_boxes: Array[PlayerBox] = []

const ON_VOLUME = -10.375
const QUIET_VOLUME = -100

@export var solo_player: int = -1:
	get:
		return solo_player
	set(new_solo_player):
		solo_player = new_solo_player
		_update_solo()

@export var player1: Player = null:
	get:
		return player1
	set(new_player1):
		player1 = new_player1
		_update_player_boxes()

@export var player2: Player = null:
	get:
		return player2
	set(new_player2):
		player2 = new_player2
		_update_player_boxes()

@export var player3: Player = null:
	get:
		return player3
	set(new_player3):
		player3 = new_player3
		_update_player_boxes()

@export var player4: Player = null:
	get:
		return player4
	set(new_player4):
		player4 = new_player4
		_update_player_boxes()

func _update_solo() -> void:
	if solo_player < 0 or solo_player > 3:
		for player_box in _player_boxes:
			player_box.enter_normal()
		return
	var supporting_corner: PlayerBox.Corner = _player_boxes[solo_player].corner
	for player_box in _player_boxes:
		if player_box.corner == supporting_corner:
			player_box.enter_solo()
		else:
			player_box.enter_supporting(supporting_corner)

@export var border_size: int = 2:
	get:
		return border_size
	set(new_border_size):
		border_size = new_border_size
		_update_border_size()

var previous_player_count: int = -1
func _update_player_boxes():
	if bottom_box_right_margin == null:
		return
	player_top_box_1.corner = PlayerBox.Corner.TOP_LEFT
	# set player 1:
	player_top_box_1.player = player1
	
	# update player 1 box visibility:
	player_top_box_1.show()
	top_box.show()
	
	bottom_box_left_margin.size_flags_stretch_ratio = 11
	bottom_box_right_margin.size_flags_stretch_ratio = 11
	if player1 == null: # 0 Players Have Locked In
		if previous_player_count == 0:
			return
		previous_player_count = 0
		# update player 1 box margins:
		top_box_left_margin.hide()
		top_box_right_margin.hide()
		
		# set all other player to empty.
		player_top_box_2.player = null
		# assumes that player and 4 are null too.
		player_bottom_box_1.player = null
		player_bottom_box_2.player = null
		
		# update other player boxes' visibility:
		player_top_box_2.hide()
		bottom_box.hide()
		
		# Add Player Visibility:
		add_player_bottom_container.hide()
	elif player2 == null: # 1 Player Has Locked In
		if previous_player_count == 1:
			return
		previous_player_count = 1
		# update player 1 box margins:
		top_box_left_margin.show()
		top_box_right_margin.show()
		
		# set all other player to empty.
		player_top_box_2.player = null
		# assumes that player and 4 are null too.
		player_bottom_box_1.player = null
		player_bottom_box_2.player = null
		
		# update other player boxes' visibility:
		player_top_box_2.hide()
		bottom_box.hide()
		
		# Add Player Visibility:
		add_player_bottom_container.show()
		top_box_left_margin.size_flags_stretch_ratio = 2
		top_box_right_margin.size_flags_stretch_ratio = 2
	elif player3 == null: # 2 Players Have Locked In
		if previous_player_count == 2:
			return
		previous_player_count = 2
		# set player 2:
		player_bottom_box_1.player = player2
		
		# update shown players boxes' visibility:
		# player 1 margins:
		top_box_left_margin.show()
		top_box_right_margin.show()
		
		# player 2 box and margins:
		bottom_box.show()
		bottom_box_left_margin.show()
		bottom_box_right_margin.show()
		
		# player 2:
		player_bottom_box_1.show()
		
		# set all other player to empty.
		player_top_box_2.player = null
		# assumes that player and 4 are null too.
		player_bottom_box_2.player = null
		
		# update other player boxes' visibility:
		player_top_box_2.hide()
		player_bottom_box_2.hide()
		
		# Add Player Visibility:
		add_player_bottom_container.show()
		top_box_left_margin.size_flags_stretch_ratio = 11
		top_box_right_margin.size_flags_stretch_ratio = 11
	elif player4 == null: # 3 Players Have Locked In
		if previous_player_count == 3:
			return
		previous_player_count = 3
		# set player 2:
		player_top_box_2.player = player2
		# set player 3:
		player_bottom_box_1.player = player3
		
		# update player 1 and 2 box margins:
		top_box_left_margin.show()
		top_box_right_margin.show()
		
		# player 2:
		player_top_box_2.show()
		
		# player 3 box and margins:
		player_bottom_box_1.show()
		bottom_box_left_margin.show()
		bottom_box_right_margin.show()
		
		# player 3:
		bottom_box.show()
		
		# clears player 4:
		player_bottom_box_2.player = null
		
		# Add Player Visibility:
		add_player_bottom_container.show()
		top_box_left_margin.size_flags_stretch_ratio = 2
		top_box_right_margin.size_flags_stretch_ratio = 2
	else: # 4 Players Have Locked In
		if previous_player_count == 4:
			return
		previous_player_count = 4
		# set player 2:
		player_top_box_2.player = player2
		# set player 3:
		player_bottom_box_1.player = player3
		# set player 3:
		player_bottom_box_2.player = player4
		
		# update player 1 and 2 box margins:
		top_box_left_margin.hide()
		top_box_right_margin.hide()
		
		# player 2:
		player_top_box_2.show()
		
		# update player 3 and 4 box and margins:
		bottom_box.show()
		bottom_box_left_margin.hide()
		bottom_box_right_margin.hide()
		
		# player 3:
		player_bottom_box_1.show()
		
		# player 4:
		player_bottom_box_2.show()
		
		# Hide Player Visibility:
		add_player_bottom_container.hide()

func _update_player_boxes_for_game():
	if bottom_box_right_margin == null:
		return
	
	# update player 1 box visibility:
	player_top_box_1.show()
	top_box.show()
		
	# Hide Player Visibility:
	add_player_bottom_container.hide()
	top_box_left_margin.size_flags_stretch_ratio = 10
	top_box_right_margin.size_flags_stretch_ratio = 10
	bottom_box_left_margin.size_flags_stretch_ratio = 10
	bottom_box_right_margin.size_flags_stretch_ratio = 10
	
	if player1 == null or player2 == null: # 1 Player Has Locked In
		# update player 1 box margins:
		top_box_left_margin.hide()
		top_box_right_margin.hide()
		
		# update other player boxes' visibility:
		player_top_box_2.hide()
		bottom_box.hide()
	elif player3 == null: # 2 Players Have Locked In
		# update shown players boxes' visibility:
		# player 1 margins:
		top_box_left_margin.show()
		top_box_right_margin.show()
		
		# player 2 box and margins:
		bottom_box.show()
		bottom_box_left_margin.show()
		bottom_box_right_margin.show()
		
		# player 2:
		player_bottom_box_1.show()
		
		# update other player boxes' visibility:
		player_top_box_2.hide()
		player_bottom_box_2.hide()
		
	elif player4 == null: # 3 Players Have Locked In
		# update player 1 and 2 box margins:
		top_box_left_margin.hide()
		top_box_right_margin.hide()
		
		# player 2:
		player_top_box_2.show()
		
		# player 3 box and margins:
		player_bottom_box_1.show()
		bottom_box_left_margin.show()
		bottom_box_right_margin.show()
		
		# player 3:
		bottom_box.show()
		
	else: # 4 Players Have Locked In
		# update player 1 and 2 box margins:
		top_box_left_margin.hide()
		top_box_right_margin.hide()
		
		# player 2:
		player_top_box_2.show()
		
		# update player 3 and 4 box and margins:
		bottom_box.show()
		bottom_box_left_margin.hide()
		bottom_box_right_margin.hide()
		
		# player 3:
		player_bottom_box_1.show()
		
		# player 4:
		player_bottom_box_2.show()

func start_game() -> void:
	_update_player_boxes_for_game()
	player_top_box_1.start_game()
	player_top_box_2.start_game()
	player_bottom_box_1.start_game()
	player_bottom_box_2.start_game()
	if player1 != null:
		player1.start_game()
	if player2 != null:
		player2.start_game()
	if player3 != null:
		player3.start_game()
	if player4 != null:
		player4.start_game()
	var tween: Tween = create_tween()
	tween.tween_callback(start_music).set_delay(0.75)

func start_music() -> void:
	music_player.volume_db = ON_VOLUME
	music_player.play(0.0)

func end_game() -> void:
	player_top_box_1.end_game()
	player_top_box_2.end_game()
	player_bottom_box_1.end_game()
	player_bottom_box_2.end_game()
	if player1 != null:
		player1.end_game()
	if player2 != null:
		player2.end_game()
	if player3 != null:
		player3.end_game()
	if player4 != null:
		player4.end_game()
	music_player.volume_db = QUIET_VOLUME
	_update_player_boxes()

func end_music() -> void:
	music_player.stop()

func _update_border_size() -> void:
	for player_box in _player_boxes:
		player_box.border_size = border_size

@export var solo_margin_size: int = 40:
	get:
		return solo_margin_size
	set(new_solo_margin_size):
		solo_margin_size = new_solo_margin_size
		_update_solo_margin_size()

func _update_solo_margin_size() -> void:
	for player_box in _player_boxes:
		player_box.solo_margin_size = solo_margin_size

@export var solo_tween_duration: float = 0.2:
	get:
		return solo_tween_duration
	set(new_solo_tween_duration):
		solo_tween_duration = new_solo_tween_duration
		_update_solo_tween_duration()

func _update_solo_tween_duration() -> void:
	for player_box in _player_boxes:
		player_box.solo_tween_duration = solo_tween_duration

func initialize() -> void:
	_player_boxes.clear()
	player_top_box_1.end_game()
	player_top_box_2.end_game()
	player_bottom_box_1.end_game()
	player_bottom_box_2.end_game()
	_player_boxes.append_array([player_top_box_1, player_top_box_2, player_bottom_box_1, player_bottom_box_2])
	_update_border_size()
	_update_solo_margin_size()
	solo_player = -1
	_update_player_boxes()

func _ready() -> void:
	initialize()
