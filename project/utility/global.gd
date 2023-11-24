
extends Node

func _ready():

	DisplayServer.window_set_title("花生迷途 Peanut's Journey")
	
	Engine.set_max_fps(60)
	DisplayServer.window_set_size(Vector2(1280,720))
	DisplayServer.window_set_position(Vector2(100,100))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
