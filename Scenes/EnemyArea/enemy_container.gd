@tool
extends MarginContainer
class_name EnemyContainer

signal completed(enemy_container: EnemyContainer)

@onready var enemy_sprite: Sprite2D = %EnemySprite
@onready var sillhouette_sprite: Sprite2D = %SillhouetteSprite
@onready var enemy_animation_tree: AnimationTree = %EnemyAnimationTree
@onready var enemy_animation_player: AnimationPlayer = %EnemyAnimationPlayer

enum EnemyStatus {
	UNKNOWN = -1,
	FRIENDLY = 0,
	ENEMY = 1
}

enum FriendlyEnemies {
	UNKNOWN = -1,
	AUDIENCE_FRIEND = 0,
	FRANKEN_FAN = 1,
}

enum EnemyEnemies {
	UNKNOWN = -1,
	FRANKEN_ENEMY = 0,
	KRAKEN_ENEMY = 1,
	AUDIENCE_ENEMY = 2,
	FRANKEN_FAN_ENEMY = 3
}

var AUDIENCE_ATLAS: Texture2D = preload("res://Scenes/EnemyArea/Images/AudienceAtlas.png")
var FRANKEN_ATLAS: Texture2D = preload("res://Scenes/EnemyArea/Images/FrankenAtlas.png")
var FRANKEN_FAN_ATLAS: Texture2D = preload("res://Scenes/EnemyArea/Images/FrankenFanAtlas.png")
var KRAKEN_ATLAS: Texture2D = preload("res://Scenes/EnemyArea/Images/KrakenAtlas.png")

@export var initialized: bool = false
@export var was_hit: bool = false
@export var enemy_status: EnemyStatus = EnemyStatus.UNKNOWN
@export var was_serenaded: bool = false
@export var score: int = 0

@export var was_interacted: bool = false:
	get:
		return was_hit or was_serenaded

func start():
	enemy_status = Globals.rng.randi_range(0, 1) as EnemyStatus
	match enemy_status:
		EnemyContainer.EnemyStatus.FRIENDLY:
			var friendly_type: FriendlyEnemies = FriendlyEnemies.UNKNOWN
			if score < 20:
				friendly_type = FriendlyEnemies.AUDIENCE_FRIEND
			else:
				friendly_type = Globals.rng.randi_range(0, 1) as FriendlyEnemies
			match friendly_type:
				FriendlyEnemies.AUDIENCE_FRIEND:
					enemy_sprite.texture = AUDIENCE_ATLAS
					sillhouette_sprite.texture = AUDIENCE_ATLAS
					enemy_sprite.vframes = 3
					sillhouette_sprite.vframes = 3
					enemy_sprite.frame = 1
					sillhouette_sprite.frame = 2
				FriendlyEnemies.FRANKEN_FAN:
					enemy_sprite.texture = FRANKEN_FAN_ATLAS
					sillhouette_sprite.texture = FRANKEN_FAN_ATLAS
					enemy_sprite.vframes = 3
					sillhouette_sprite.vframes = 3
					enemy_sprite.frame = 1
					sillhouette_sprite.frame = 2
			#enemy_sprite.frame = 2
			#sillhouette_sprite.frame = 3
		EnemyContainer.EnemyStatus.ENEMY:
			var enemy_type: EnemyEnemies = EnemyEnemies.UNKNOWN
			if score < 30:
				enemy_type = Globals.rng.randi_range(0, 1) as EnemyEnemies
			elif score < 40:
				enemy_type = Globals.rng.randi_range(0, 2) as EnemyEnemies
			else:
				enemy_type = Globals.rng.randi_range(0, 3) as EnemyEnemies
			match enemy_type:
				EnemyEnemies.FRANKEN_ENEMY:
					enemy_sprite.texture = FRANKEN_ATLAS
					sillhouette_sprite.texture = FRANKEN_ATLAS
					enemy_sprite.vframes = 2
					sillhouette_sprite.vframes = 2
					enemy_sprite.frame = 0
					sillhouette_sprite.frame = 1
				EnemyEnemies.KRAKEN_ENEMY:
					enemy_sprite.texture = KRAKEN_ATLAS
					sillhouette_sprite.texture = KRAKEN_ATLAS
					enemy_sprite.vframes = 2
					sillhouette_sprite.vframes = 2
					enemy_sprite.frame = 0
					sillhouette_sprite.frame = 1
				EnemyEnemies.AUDIENCE_ENEMY:
					enemy_sprite.texture = AUDIENCE_ATLAS
					sillhouette_sprite.texture = AUDIENCE_ATLAS
					enemy_sprite.vframes = 3
					sillhouette_sprite.vframes = 3
					enemy_sprite.frame = 0
					sillhouette_sprite.frame = 2
				EnemyEnemies.FRANKEN_FAN_ENEMY:
					enemy_sprite.texture = FRANKEN_FAN_ATLAS
					sillhouette_sprite.texture = FRANKEN_FAN_ATLAS
					enemy_sprite.vframes = 3
					sillhouette_sprite.vframes = 3
					enemy_sprite.frame = 0
					sillhouette_sprite.frame = 2
	enemy_animation_tree.active = true
	was_serenaded = false
	was_hit = false
	initialized = true

func hit():
	if !was_interacted:
		was_hit = true

func serenade():
	if !was_interacted:
		was_serenaded = true

func _reset():
	was_serenaded = false
	was_hit = false
	initialized = false
	enemy_status = EnemyStatus.UNKNOWN
	var tween = create_tween()
	tween.tween_callback(emit_completed).set_delay(0.1)
	enemy_animation_player.stop()

func emit_completed():
	enemy_animation_tree.active = false
	completed.emit(self)

func _ready():
	was_serenaded = false
	was_hit = false
	initialized = false
	enemy_animation_player.stop()
