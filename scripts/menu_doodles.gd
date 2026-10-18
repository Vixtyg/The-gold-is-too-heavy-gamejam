@tool
extends Control
## Native canvas decorations stay sharp at every window size.

const BACKGROUND := Color("ffdeeb")
const BUBBLEGUM := Color("ffc0d8")
const BLUSH := Color("f2a0c0")
const MILK := Color("fff5fa")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / Vector2(1280.0, 720.0))
	draw_rect(Rect2(0, 0, 1280, 720), BACKGROUND)
	# A soft scalloped edge, like the wrapper of a very pink cupcake.
	for index in range(9):
		draw_circle(Vector2(index * 170.0 - 40.0, 780.0), 115.0, BUBBLEGUM)
	draw_circle(Vector2(407, 455), 176.0, MILK)
	draw_circle(Vector2(407, 455), 166.0, BUBBLEGUM)
	draw_ellipse_shadow()
	_heart(Vector2(102, 125), 33.0, -0.24, BLUSH)
	_heart(Vector2(1175, 327), 28.0, 0.2, BLUSH)
	_heart(Vector2(1130, 601), 19.0, -0.15, MILK)
	_heart(Vector2(575, 311), 24.0, 0.3, BLUSH)
	_heart(Vector2(225, 507), 18.0, -0.2, MILK)
	_star(Vector2(1148, 122), 25.0, MILK)
	_star(Vector2(196, 312), 21.0, MILK)
	_star(Vector2(599, 536), 21.0, MILK)
	_star(Vector2(95, 564), 20.0, BLUSH)
	_star(Vector2(1050, 249), 12.0, BLUSH)
	for point: Vector2 in [Vector2(154, 235), Vector2(1090, 516), Vector2(1240, 473), Vector2(635, 270)]:
		draw_circle(point, 5.0, BLUSH)


func draw_ellipse_shadow() -> void:
	var points := PackedVector2Array()
	for index in range(48):
		var angle := TAU * index / 48.0
		points.append(Vector2(407, 599) + Vector2(cos(angle) * 100.0, sin(angle) * 15.0))
	draw_colored_polygon(points, BLUSH)


func _heart(center: Vector2, radius: float, angle: float, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(48):
		var t := TAU * index / 48.0
		var point := Vector2(16.0 * pow(sin(t), 3.0), -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)))
		points.append(center + (point * radius / 16.0).rotated(angle))
	draw_colored_polygon(points, color)


func _star(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(8):
		var angle := PI * index / 4.0 - PI / 2.0
		points.append(center + Vector2.from_angle(angle) * radius * (1.0 if index % 2 == 0 else 0.28))
	draw_colored_polygon(points, color)
