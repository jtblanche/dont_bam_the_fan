extends Node

static var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
