
extends Node

var IS_OWNED: bool = false
var IS_ONLINE: bool = false
var STEAM_APP_ID: int = 2636960
var STEAM_ID: int = 0

var ACHIEVEMENTS: Dictionary = {'Welcome':false, "achieve2":false, "achieve3":false}

func _init() -> void:
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))

func _initialize_Steam() -> void:
	var INIT: Dictionary = Steam.steamInit()
		
	IS_ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	IS_OWNED = Steam.isSubscribed()
		
func _get_Achievement(value: String) -> void:
	var ACHIEVEMENT: Dictionary = Steam.getAchievement(value)
	if ACHIEVEMENT['ret']:
		if ACHIEVEMENT['achieved']:
			ACHIEVEMENTS[value] = true
		else:
			ACHIEVEMENTS[value] = false
	else:
		ACHIEVEMENTS[value] = false

func _ready():
	_initialize_Steam()
	Steam.setAchievement('Welcome')
	Steam.storeStats()
	pass

func _physics_process(delta):
	Steam.run_callbacks()
	pass
	
