extends Node

onready var player = $AudioStreamPlayer
onready var tween = $Tween
onready var stopTimer = $StopTimer
onready var startTimer = $StartTimer

var musicPath = "res://Music and Sounds/Music/"
var musicVolume = 0 setget volumeChanged

var music = {
	
	"LightBreeze":[load(musicPath + "LightBreeze.ogg"), - 15], 
	"DesolateStarSystem":[load(musicPath + "DesolateStarSystem.ogg"), - 13], 
	"SuperNova":[load(musicPath + "SuperNova.ogg"), - 12], 
	"March":[load(musicPath + "March.ogg"), - 15], 
	"MainMenu":[load(musicPath + "MainMenu.ogg"), - 10], 
	"FirstFlight":[load(musicPath + "FirstFlight.ogg"), - 20], 
	"ColdBreeze":[load(musicPath + "ColdBreeze.ogg"), - 14], 
	"WindAmbient":[load(musicPath + "WindAmbient.ogg"), - 10], 
}

func _ready():
	pass

func volumeChanged(val):
	var previous = clamp(musicVolume, - 30, 30)
	if val > - 30:
		musicVolume = val
	else :
		musicVolume = - 80
	var diff = val - previous
	player.volume_db += diff

func play(musicString, transTime = 1.0):
	tween.stop_all()
	startTimer.stop()
	stopTimer.stop()
	if player.playing and player.stream != music[musicString][0]:
		tween.interpolate_property(player, "volume_db", player.volume_db, - 40, transTime / 2)
		tween.start()
		startTimer.wait_time = transTime / 2 + 0.1
		startTimer.connect("timeout", self, "playTheSong", [musicString, transTime])
		startTimer.start()
		return 
	playTheSong(musicString, transTime)
		
func playTheSong(musicString, transTime = 1.0):
	if startTimer.is_connected("timeout", self, "playTheSong"):
		startTimer.disconnect("timeout", self, "playTheSong")
	if player.stream != music[musicString][0] or not player.playing:
		player.stream = music[musicString][0]
		player.play()
		var targetVolume = music[musicString][1] + musicVolume
		tween.interpolate_property(player, "volume_db", - 40, targetVolume, transTime / 2)
		tween.start()
		return 
	if player.stream == music[musicString][0]:
		var targetVolume = music[musicString][1] + musicVolume
		tween.interpolate_property(player, "volume_db", player.volume_db, targetVolume, transTime / 2)
		tween.start()
		
func stop(transTime = 1.0):
	tween.stop_all()
	startTimer.stop()
	stopTimer.stop()
	if player.playing:
		tween.interpolate_property(player, "volume_db", player.volume_db, - 40, transTime)
		tween.start()
		stopTimer.wait_time = transTime + 0.1
		stopTimer.start()
		
func changeVolume(volume = 0, transTime = 1.0):
	tween.stop_all()
	startTimer.stop()
	stopTimer.stop()
	tween.interpolate_property(player, "volume_db", player.volume_db, player.volume_db + volume, transTime)
	tween.start()
	
func _on_StopTimer_timeout():
	player.stop()
