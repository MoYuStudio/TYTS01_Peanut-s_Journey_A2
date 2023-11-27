
# COPYRIGHT © 2020-2023 MoYuStudio摸鱼社
# = 100% 自主通用模块标签 =

extends Node

class_name SceneManager

@onready var scene_instantiate_place = $SceneInstance

@export var scene_path:String = "res://scene/"

var scene_instantiate

func _ready():
	load_scene("init")
	pass
	
func unload_scene():
	if is_instance_valid(scene_instantiate):
		scene_instantiate.queue_free()
	scene_instantiate = null
	
func load_scene(scene_name:String):
	unload_scene()
	var path = scene_path + scene_name + ".tscn"
	var resource := load(path)
	if resource:
		scene_instantiate = resource.instantiate()
		scene_instantiate_place.add_child(scene_instantiate)
		
