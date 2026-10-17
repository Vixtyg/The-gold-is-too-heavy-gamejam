extends CharacterBody2D

signal eaten

@export var SPEED = 75
@export var DETECTION_RADIUS = 400
@export var player: CharacterBody2D
var radius
var _eaten: bool = false


func _ready() -> void:
	$EatingArea.body_entered.connect(_on_eating_area_body_entered)


func _on_eating_area_body_entered(body: Node2D) -> void:
	if body != player or _eaten:
		return
	_eaten = true
	eaten.emit()
	queue_free()


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player) or _eaten:
		return

	radius = calculate_radius(self.position.x,self.position.y,player.position.x,player.position.y)
	if (radius<DETECTION_RADIUS):
		velocity.x=SPEED*detect_direction_x(self.position.x,player.position.x)
		velocity.y=SPEED*detect_direction_y(self.position.y,player.position.y)
	else:
		velocity.x=0
		velocity.y=0
	move_and_slide()
func calculate_radius(x1,y1,x2,y2):
	return ((max(x2,x1)-min(x2,x1))**2+(max(y2,y1)-min(y2,y1))**2)**0.5
func detect_direction_x(x1,x2):
	if (x2-x1>=0):
		return -1
	else:
		return 1
func detect_direction_y(y1,y2):
	if (y2-y1>=0):
		return -1
	else:
		return 1
