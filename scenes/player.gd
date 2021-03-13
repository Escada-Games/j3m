extends KinematicBody2D


enum Colors {Red, Green, Blue}
var cCurrentColor=Colors.Red
var cShownColor=global.colors[0]

enum States {Alive, Dead}
var state=States.Alive

var vVelocity=Vector2()
var fCurrentRotation=0
var fTargetRotation=0
var bWasOnFloor=false
var fJumpBuffer=0
var fCoyoteTime=0
const fMaxCoyoteTime=10
const fMaxJumpBuffer=8
const fGravity=15.0
const fJumpForce=275.0
const fRadStep=deg2rad(120)
const particlesJumpOk=preload("res://scenes/particlesJumpOk.tscn")
const sfxJump=preload("res://scenes/sfxJump.tscn")
const sfxLand=preload("res://scenes/sfxLand.tscn")

func _ready():
	$twn.connect("tween_all_completed",self,'enableCollision')
	set_physics_process(true)
func _physics_process(delta):
	if self.global_position.y>700:
		gameOver()
	if state==States.Alive and global.gameHasStarted:
		fJumpBuffer+=1
		if not self.is_on_floor():
			fCoyoteTime+=1
		else:
			fCoyoteTime=0
		
		$raycasts.rotation=-self.rotation
		$triangle/color.color=self.cShownColor
		self.rotation=self.fCurrentRotation
		if Input.is_action_just_pressed("ui_jump"):
			self.fTargetRotation+=fRadStep if Input.is_action_just_pressed("ui_jump_clockwise") else -fRadStep
			var inc=1 if Input.is_action_just_pressed("ui_jump_clockwise") else -1
			cCurrentColor=Colors.values()[(cCurrentColor+inc)%Colors.size()]
			$twn.interpolate_property(self,'fCurrentRotation',self.fCurrentRotation,self.fTargetRotation,0.66,Tween.TRANS_QUINT,Tween.EASE_OUT)
			$twn.interpolate_property(self,'cShownColor',self.cShownColor,global.colors[cCurrentColor],0.3,Tween.TRANS_QUINT,Tween.EASE_OUT)
			$twn.start()
			fJumpBuffer=0
		if fJumpBuffer<fMaxJumpBuffer and fCoyoteTime<fMaxCoyoteTime:
			fJumpBuffer=fMaxJumpBuffer
			fCoyoteTime=fMaxCoyoteTime
			self.vVelocity.y=-fJumpForce
			get_parent().add_child(sfxJump.instance())
#			$twnSquish.interpolate_property($triangle,'scale',Vector2(0.6,1.4),Vector2(1,1),0.3,Tween.TRANS_BACK,Tween.EASE_OUT)
#			$twnSquish.start()
			
		vVelocity.x=-self.get_floor_velocity().x
		vVelocity.y+=fGravity
		vVelocity=move_and_slide(vVelocity,Vector2(0,-1))
		if self.is_on_floor() and not self.bWasOnFloor:
			print_debug('Landed')
			var i=particlesJumpOk.instance()
			i.global_position=self.global_position+Vector2(0,18)
			i.emitting=true
			i.modulate=$triangle/color.color
			get_parent().add_child(i)
			get_parent().add_child(sfxLand.instance())
			
			var nodeBelow=null
			for r in [$raycasts/raycastL,$raycasts/raycastM,$raycasts/raycastR]:
				nodeBelow=r.get_collider()
				if nodeBelow!=null:
					break
	
			if nodeBelow!=null:
				if nodeBelow.is_in_group('Platform'):
					if self.cCurrentColor==nodeBelow.cCurrentColor:
						global.score+=1
						pass
	#					print_debug('OK')
					else:
						print_debug('Dead')
						print_debug('Self color:'+str(self.cCurrentColor))
						print_debug('Floor color:'+str(nodeBelow.cCurrentColor))
						self.gameOver()
					pass
		self.bWasOnFloor=self.is_on_floor()
	elif state==States.Dead:
		self.rotation+=delta*PI/6
		vVelocity.x=-230
		vVelocity.y+=fGravity
		vVelocity=move_and_slide(vVelocity,Vector2(0,-1))
		pass

func gameOver():
	self.vVelocity.y=-fJumpForce
	$collisionShape2D.disabled=true
	global.emit_signal('gameOver')
