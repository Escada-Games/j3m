extends Node2D

var nextColor=1
const platform = preload("res://scenes/platform.tscn")

func _ready():
	$timer.autostart=false
	$timer.paused=true
	global.connect("gameStart",self,'gameStart')
func gameStart():
	$timer.autostart=true
	$timer.paused=false
	$timer.start()
	pass

func _on_timer_timeout():
	$timer.wait_time=.85
	$timer.start()
	randomize()
	self.global_position.y+=32*(randf()-0.5)
	self.global_position.y=clamp(self.global_position.y,0.2*global.RES.y,0.8*global.RES.y)
	var i=platform.instance()
	i.global_position=self.global_position
	i.cCurrentColor=nextColor
	get_parent().add_child(i)
	nextColor+=1 if randf()<0.5 else -1
	if nextColor==-1:
		nextColor=2
	nextColor%=3
