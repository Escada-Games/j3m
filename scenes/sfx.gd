extends AudioStreamPlayer
func _ready():
	randomize()
	self.pitch_scale=rand_range(0.5,0.7)
