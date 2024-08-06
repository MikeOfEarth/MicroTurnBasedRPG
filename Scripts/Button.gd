extends Button


# Called when the node enters the scene tree for the first time.
func _pressed():
	#$"../MoveSprite".play('death')
	$"..".take_damage(1)
