@tool
extends MarginContainer
class_name PlayerBox

@onready var border_margin_container: MarginContainer = %BorderMarginContainer
@onready var player_area: PlayerArea = %PlayerArea
const BASE_Z_INDEX = 0
const SOLO_Z_INDEX = 100

enum Corner {
	UNKNOWN = -1, # when first initialized
	TOP_LEFT = 0, # for 4 player and 3 player
	TOP_RIGHT, # for 4 player and 3 player
	BOTTOM_RIGHT, # for 4 player
	BOTTOM_LEFT, # for 4 player and 3 player
	LEFT, # for 2 player
	RIGHT, # for 2 player
	CENTER, # for 1 player
}

enum Status {
	UNKNOWN = -1,
	NORMAL = 0,
	SOLO = 1,
	SUPPORTING = 2
}

class SupportingInfo:
	var positive_margins: PackedStringArray = []
	var negative_margins: PackedStringArray = []
	var double_margins: PackedStringArray = []
	
	func _init(
		positive_margins: PackedStringArray = [],
		negative_margins: PackedStringArray = [],
		double_margins: PackedStringArray = []
	) -> void:
		self.positive_margins = positive_margins
		self.negative_margins = negative_margins
		self.double_margins = double_margins

class CornerInfo:
	var margin_changes: PackedStringArray = []
	var supporting_margin_info: Dictionary[PlayerBox.Corner, SupportingInfo] = {}
	
	func _init(
		margin_changes: PackedStringArray = [],
		supporting_margin_info: Dictionary[PlayerBox.Corner, SupportingInfo] = {}
	) -> void:
		self.margin_changes = margin_changes
		self.supporting_margin_info = supporting_margin_info

static var _all_theme_constants: PackedStringArray = ["margin_right", "margin_bottom", "margin_left", "margin_top"]

static var _corner_string_lookup: Dictionary[PlayerBox.Corner, PlayerBox.CornerInfo] = {
	Corner.UNKNOWN: CornerInfo.new(),
	Corner.TOP_LEFT: CornerInfo.new(
		["margin_right", "margin_bottom"],
		{
			PlayerBox.Corner.TOP_RIGHT: SupportingInfo.new(
				["margin_right"],
				["margin_bottom"],
				["margin_top"]
			),
			PlayerBox.Corner.BOTTOM_RIGHT: SupportingInfo.new(
				["margin_bottom", "margin_right"]
			),
			PlayerBox.Corner.BOTTOM_LEFT: SupportingInfo.new(
				["margin_bottom"],
				["margin_right"],
				["margin_left"]
			),
		}
	),
	Corner.TOP_RIGHT: CornerInfo.new(
		["margin_left", "margin_bottom"],
		{
			PlayerBox.Corner.TOP_LEFT: SupportingInfo.new(
				["margin_left"],
				["margin_bottom"],
				["margin_top"]
			),
			PlayerBox.Corner.BOTTOM_RIGHT: SupportingInfo.new(
				["margin_bottom"],
				["margin_left"],
				["margin_right"]
			),
			PlayerBox.Corner.BOTTOM_LEFT: SupportingInfo.new(
				["margin_bottom", "margin_left"]
			),
		}
	),
	Corner.BOTTOM_RIGHT: CornerInfo.new(
		["margin_left", "margin_top"],
		{
			PlayerBox.Corner.TOP_LEFT: SupportingInfo.new(
				["margin_top", "margin_left"]
			),
			PlayerBox.Corner.TOP_RIGHT: SupportingInfo.new(
				["margin_top"],
				["margin_left"],
				["margin_right"]
			),
			PlayerBox.Corner.BOTTOM_LEFT: SupportingInfo.new(
				["margin_left"],
				["margin_top"],
				["margin_bottom"]
			),
		}
	),
	Corner.BOTTOM_LEFT: CornerInfo.new(
		["margin_right", "margin_top"],
		{
			PlayerBox.Corner.TOP_LEFT: SupportingInfo.new(
				["margin_top"],
				["margin_right"],
				["margin_left"]
			),
			PlayerBox.Corner.TOP_RIGHT: SupportingInfo.new(
				["margin_top", "margin_right"]
			),
			PlayerBox.Corner.BOTTOM_RIGHT: SupportingInfo.new(
				["margin_right"],
				["margin_top"],
				["margin_bottom"]
			),
		}
	),
}

@export var solo_tween_duration: float = 0.3

@export var border_size: int = 2:
	get:
		return border_size
	set(new_border_size):
		border_size = new_border_size
		initialize()

@export var solo_margin_size: float = 40
@export var current_solo_margin_size: float = 0

@export var corner: PlayerBox.Corner = Corner.UNKNOWN:
	get:
		return corner
	set(new_corner):
		corner = new_corner
		initialize()

@export var player: Player = null:
	get:
		return player
	set(new_player):
		player = new_player
		if player_area != null:
			player_area.player = player

var _supporting_corner: PlayerBox.Corner = Corner.UNKNOWN:
	get:
		return _supporting_corner
	set(new_supporting_corner):
		_supporting_corner = new_supporting_corner

var _status: PlayerBox.Status = Status.UNKNOWN
var status: PlayerBox.Status = Status.UNKNOWN:
	get:
		return _status

var _corner_info: PlayerBox.CornerInfo = CornerInfo.new()

func set_my_theme_constant_value(value):
	current_solo_margin_size = value
	get_node("MyControlNode").add_theme_constant_override("separation", value)

func initialize() -> void:
	_corner_info = _corner_string_lookup.get(self.corner)
	if border_margin_container != null:
		for theme_property in _all_theme_constants:
			border_margin_container.remove_theme_constant_override(theme_property)
		for theme_property in _corner_info.margin_changes:
			border_margin_container.add_theme_constant_override(theme_property, border_size)
	enter_normal()

var tween: Tween = null

func enter_solo() -> void:
	_supporting_corner = PlayerBox.Corner.UNKNOWN
	_status = PlayerBox.Status.SOLO
	z_index = SOLO_Z_INDEX
	if tween != null:
		tween.kill()
		set_final_normal_margin_size()
	tween = create_tween()
	tween.tween_method(set_solo_current_margin_size, 0, solo_margin_size, solo_tween_duration)
	tween.tween_callback(end_solo_margin_size)

func set_solo_current_margin_size(new_current_solo_margin_size) -> void:
	current_solo_margin_size = new_current_solo_margin_size
	for theme_property in _all_theme_constants:
		remove_theme_constant_override(theme_property)
	for theme_property in _corner_info.margin_changes:
		remove_theme_constant_override(theme_property)
		add_theme_constant_override(theme_property, -current_solo_margin_size)

func set_solo_final_margin_size() -> void:
	for theme_property in _all_theme_constants:
		remove_theme_constant_override(theme_property)
	for theme_property in _corner_info.margin_changes:
		remove_theme_constant_override(theme_property)
		add_theme_constant_override(theme_property, -solo_margin_size)

func end_solo_margin_size() -> void:
	set_solo_final_margin_size()
	tween = null

func enter_supporting(supporting_corner: PlayerBox.Corner) -> void:
	if supporting_corner == PlayerBox.Corner.UNKNOWN:
		enter_normal()
		return
	_supporting_corner = supporting_corner
	_status = PlayerBox.Status.SUPPORTING
	z_index = BASE_Z_INDEX
	if tween != null:
		tween.kill()
		set_final_normal_margin_size()
	tween = create_tween()
	tween.tween_method(set_supporting_current_margin_size, 0, solo_margin_size, solo_tween_duration)
	tween.tween_callback(end_supporting_margin_size)

func set_supporting_current_margin_size(new_current_solo_margin_size) -> void:
	current_solo_margin_size = new_current_solo_margin_size
	for theme_property in _all_theme_constants:
		remove_theme_constant_override(theme_property)
	var supporting_margin_info = _corner_info.supporting_margin_info.get(_supporting_corner)
	for theme_property in supporting_margin_info.positive_margins:
		add_theme_constant_override(theme_property, current_solo_margin_size)
	for theme_property in supporting_margin_info.negative_margins:
		add_theme_constant_override(theme_property, -current_solo_margin_size)
	for theme_property in supporting_margin_info.double_margins:
		add_theme_constant_override(theme_property, 2 * current_solo_margin_size)

func set_supporting_final_margin_size() -> void:
	for theme_property in _all_theme_constants:
		remove_theme_constant_override(theme_property)
	var supporting_margin_info = _corner_info.supporting_margin_info.get(_supporting_corner)
	for theme_property in supporting_margin_info.positive_margins:
		add_theme_constant_override(theme_property, solo_margin_size)
	for theme_property in supporting_margin_info.negative_margins:
		add_theme_constant_override(theme_property, -solo_margin_size)
	for theme_property in supporting_margin_info.double_margins:
		add_theme_constant_override(theme_property, 2 * solo_margin_size)

func end_supporting_margin_size() -> void:
	set_supporting_final_margin_size()
	tween = null

func enter_normal() -> void:
	if tween != null:
		tween.kill()
		if _status == PlayerBox.Status.SOLO:
			set_solo_final_margin_size()
		elif _status == PlayerBox.Status.SUPPORTING:
			set_supporting_final_margin_size()
	if _status == PlayerBox.Status.SOLO:
		tween = create_tween()
		tween.tween_method(set_solo_current_margin_size, solo_margin_size, 0, solo_tween_duration)
		tween.tween_callback(end_normal_margin_size)
	elif _status == PlayerBox.Status.SUPPORTING:
		tween = create_tween()
		tween.tween_method(set_supporting_current_margin_size, solo_margin_size, 0, solo_tween_duration)
		tween.tween_callback(end_normal_margin_size)
	_status = PlayerBox.Status.NORMAL

func end_normal_margin_size() -> void:
	_supporting_corner = PlayerBox.Corner.UNKNOWN
	z_index = BASE_Z_INDEX
	set_final_normal_margin_size()
	tween = null

func set_final_normal_margin_size() -> void:
	for theme_property in _all_theme_constants:
		remove_theme_constant_override(theme_property)

func start_game() -> void:
	player_area.start_game()

func end_game() -> void:
	player_area.end_game()

func _ready() -> void:
	initialize()
	player_area.player = player
