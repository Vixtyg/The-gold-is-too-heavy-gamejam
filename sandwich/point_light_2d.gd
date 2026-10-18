extends PointLight2D

var brighter = true
var dimmer = false
var pulse_rate=0.007
var max = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if texture_scale<=max && brighter:
		texture_scale+=pulse_rate
	if texture_scale>=max:
		brighter=false
		texture_scale-=pulse_rate
	if texture_scale==max:
		brighter=false
	if texture_scale<=1:
		brighter=true
	if brighter==false:
		texture_scale-=pulse_rate
		
