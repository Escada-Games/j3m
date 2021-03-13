extends Node

const colorRed=Color('F45866')
const colorGreen=Color('59C9A5')
const colorBlue=Color('677DB7')
const colors=[colorRed,colorGreen,colorBlue]
const RES=Vector2(630,500)
var score=-3
signal gameOver
signal gameStart
var gameHasStarted=false
func _ready():
	self.connect("gameStart",self,'startGame')
	set_process(true)
func startGame():
	gameHasStarted=true
func _process(delta):
	if Input.is_action_pressed("ui_jump_clockwise") and Input.is_action_pressed("ui_jump_counterclockwise") and self.gameHasStarted==false:
		self.gameHasStarted=true
		emit_signal("gameStart")
