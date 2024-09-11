extends Node2D
class_name Character

@export var is_player : bool
@export var cur_hp : int = 1
@export var max_hp : int = 25

@export var combat_actions : Array
@export var opponent : Node

@onready var health_bar : ProgressBar = get_node("HealthBar")
@onready var health_text : Label = get_node("HealthBar/HealthText")

@export var visual : SpriteFrames


# Called when the node enters the scene tree for the first time.
func _ready():
	$MoveSprite.sprite_frames=visual
	$MoveSprite.play("idle")
	get_node("/root/BattleScene").character_begin_turn.connect(_on_character_begin_turn)
	
	if !is_player:
		$MoveSprite.scale.x*=-1
	health_bar.max_value=max_hp
	_update_health_bar() 

func take_damage(damage):
	cur_hp-=damage
	$MoveSprite.play("hurt")
	_update_health_bar()
	
	if cur_hp<=0:
		get_node("/root/BattleScene").character_died(self)
		$MoveSprite.play('death')
		
		await get_tree().create_timer(1.2).timeout
		queue_free()

func heal(amount):
	cur_hp+=amount
	if cur_hp> max_hp:
		cur_hp=max_hp
	
	_update_health_bar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !$MoveSprite.is_playing():
		$MoveSprite.play("idle")

func _update_health_bar():
	health_bar.value=cur_hp
	health_text.text = str(cur_hp,"/",max_hp)

func _on_character_begin_turn(character):
	if character==self and is_player==false:
		_decide_combat_action()
	
func cast_combat_action(action):
	if action.damage > 0:
		opponent.take_damage(action.damage)
	elif action.heal>0:
		heal(action.heal)
		$HealParticle.restart()
	$MoveSprite.play(action.animation)
	get_node("/root/BattleScene").end_current_turn()
	
func _decide_combat_action():
	var health_percent = float(cur_hp) / float(max_hp)
	
	for i in combat_actions:
		var action = i as CombatAction
		if action.heal>0:
			if randf()>health_percent+0.25:
				cast_combat_action(action)
				return
			else:
				continue
		else:
			cast_combat_action(action)
			return
