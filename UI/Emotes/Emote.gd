extends Sprite

enum EMOTES{
	EXCLAMATION, 
	ANNOYED
}

var emote = EMOTES.EXCLAMATION

func _ready():
	call_deferred("init")
	
func init():
	$Sprite.frame = emote
