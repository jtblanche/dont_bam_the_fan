extends CanvasLayer
class_name SceneManager

@onready var scene_container: MarginContainer = %SceneContainer

static var TITLE_SCENE: PackedScene = preload("res://title/title.tscn")
static var MAIN_SCENE: PackedScene = preload("res://main/main.tscn")
static var HOW_TO_PLAY_SCENE: PackedScene = preload("res://HowToPlay/HowToPlay.tscn")

var current_scene_type: SceneType = SceneType.TITLE
var current_scene: MarginContainer = TITLE_SCENE.instantiate()
static var scene_manager: SceneManager = null

enum SceneType {
	LOADING = -1,
	MAIN = 0,
	TITLE = 1,
	HOW_TO_PLAY = 2,
}

func load_scene(type: SceneType):
	match(type):
		SceneType.MAIN:
			unload_scene()
			current_scene_type = type
			current_scene = MAIN_SCENE.instantiate()
			scene_container.add_child(current_scene)
		SceneType.TITLE:
			unload_scene()
			current_scene_type = type
			current_scene = TITLE_SCENE.instantiate()
			scene_container.add_child(current_scene)
		SceneType.HOW_TO_PLAY:
			unload_scene()
			current_scene_type = type
			current_scene = HOW_TO_PLAY_SCENE.instantiate()
			scene_container.add_child(current_scene)

func unload_scene():
	current_scene_type = SceneType.LOADING
	scene_container.remove_child(current_scene)
	current_scene.queue_free()
	current_scene = null

func _ready() -> void:
	scene_manager = self
	scene_container.add_child(current_scene)
