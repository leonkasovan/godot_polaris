extends Node

var sfxPath = "res://Music and Sounds/SFX/"
var sfxVolume = 0 setget volumeChanged

var sounds = {
	
	"Blip":[load(sfxPath + "Blip.wav"), - 15], 
	"Select":[load(sfxPath + "Select.wav"), - 15], 
	"Bullet":[load(sfxPath + "Bullet.wav"), - 15], 
	"SavePointHum":[load(sfxPath + "SavePointHum.wav"), - 5], 
	"BulletReflect":[load(sfxPath + "BulletReflect.wav"), - 15], 
	"Boing":[load(sfxPath + "Boing.wav"), - 15], 
	"Jump":[load(sfxPath + "Jump.wav"), - 15], 
	"Land":[load(sfxPath + "Land.wav"), - 18], 
	"EnemyHit":[load(sfxPath + "EnemyHit.wav"), - 11], 
	"EnemyDie":[load(sfxPath + "EnemyDie.wav"), - 11], 
	"PigAlert":[load(sfxPath + "PigAlert.wav"), - 8], 
	"PigDeath":[load(sfxPath + "PigDeath.wav"), - 8], 
	"BatAlert":[load(sfxPath + "BatAlert.wav"), - 18], 
	"BatDeath":[load(sfxPath + "BatDeath.wav"), - 18], 
	"SpiderAlert":[load(sfxPath + "SpiderAlert.wav"), - 22], 
	"SpiderDeath":[load(sfxPath + "SpiderDeath.wav"), - 22], 
	"WaspAlert":[load(sfxPath + "WaspAlert.wav"), - 16], 
	"WaspDeath":[load(sfxPath + "WaspDeath.wav"), - 16], 
	"AmgusLotusShoot":[load(sfxPath + "AmgusLotusShoot.wav"), - 12], 
	"AmgusLotusDeath":[load(sfxPath + "AmgusLotusDeath.wav"), - 12], 
	"PlayerHurt":[load(sfxPath + "PlayerHurt.wav"), - 10], 
	"PlayerDeath":[load(sfxPath + "PlayerDeath.wav"), - 15], 
	"Dash":[load(sfxPath + "Dash.wav"), - 20], 
	"BoneBossDash":[load(sfxPath + "BoneBossDash.wav"), - 18], 
	"BoneBossJumpAttack":[load(sfxPath + "BoneBossJumpAttack.wav"), - 15], 
	"BoneBossSpin":[load(sfxPath + "BoneBossSpin.wav"), - 5], 
	"BigThud":[load(sfxPath + "BigThud.wav"), - 5], 
	"BossHpFill":[load(sfxPath + "BossHpFill.wav"), - 7], 
	"Start":[load(sfxPath + "Start.wav"), - 18], 
	"Victory":[load(sfxPath + "Victory.wav"), - 25], 
	"Punch":[load(sfxPath + "Punch.wav"), - 10], 
	"WingShoot":[load(sfxPath + "WingShoot.wav"), - 8], 
	"Radio":[load(sfxPath + "Radio.wav"), - 16], 
	"ShipPass":[load(sfxPath + "ShipPass.wav"), - 10], 
	"MapOpen":[load(sfxPath + "MapOpen.wav"), - 7], 
	"MapClose":[load(sfxPath + "MapClose.wav"), - 7], 
	"Stalactite":[load(sfxPath + "Stalactite.wav"), - 8], 
	"ChestOpen":[load(sfxPath + "ChestOpen.wav"), - 5], 
	"ArtifactGet":[load(sfxPath + "ArtifactGet.wav"), - 12], 
	"PowerUpGet":[load(sfxPath + "PowerUpGet.wav"), - 12], 
	"PuzzleSolved":[load(sfxPath + "PuzzleSolved.wav"), - 8], 
	"Eat":[load(sfxPath + "Eat.wav"), - 3], 
	"ShipLand":[load(sfxPath + "ShipLand.wav"), - 15], 
	"LightningBullet":[load(sfxPath + "LightningBullet.wav"), - 10], 
	"ShipDestroy":[load(sfxPath + "ShipDestroy.wav"), - 10], 
	"TakeOff":[load(sfxPath + "TakeOff.wav"), - 8], 
}

onready var players = get_children()

func volumeChanged(val):
	if val > - 30:
		sfxVolume = val
	else :
		sfxVolume = - 80

func play(soundString, pitch = 1, dontRepeat = false):
	if Global.health == 0:
		return 
	if dontRepeat:
		for player in players:
			if player.stream == sounds[soundString][0] and player.playing:
				return 
	for player in players:
		if not player.playing:
			player.stream = sounds[soundString][0]
			player.volume_db = sounds[soundString][1] + sfxVolume
			player.pitch_scale = pitch
			player.play()
			return 
	print("too many sounds playing at once")
	
func playOverride(soundString, pitch = 1):
	for player in players:
		if not player.playing:
			player.stream = sounds[soundString][0]
			player.volume_db = sounds[soundString][1] + sfxVolume
			player.pitch_scale = pitch
			player.play()
			return 
	print("too many sounds playing at once")
