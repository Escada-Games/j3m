extends KinematicBody2D

var globalPosition=Vector2()
const SPEED=230
enum Colors {Red, Green, Blue}
export(Colors) var cCurrentColor=Colors.Red
export(bool) var bLockColor=true
func _ready():
	randomize()
	if not bLockColor:
		cCurrentColor=Colors.values()[randi()%Colors.size()]
	$polygon2D.color=global.colors[cCurrentColor]
	$collisionPolygon2D.polygon=$polygon2D.polygon
	self.globalPosition=self.global_position
	set_physics_process(true)
func _physics_process(delta):
	if global.gameHasStarted:
		self.globalPosition.x-=SPEED*delta
		self.global_position=self.global_position.linear_interpolate(self.globalPosition,0.2)
	#move_and_slide(Vector2(-SPEED,0),Vector2.UP)
