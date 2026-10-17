extends Node2D
## A deterministic backdrop makes camera movement easy to see.

const WORLD_SIZE := Vector2(3200, 2200)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("6b9255"))
	var horizontal := PackedVector2Array([
		Vector2(0, 1260), Vector2(600, 1260), Vector2(1140, 1100),
		Vector2(1800, 1100), Vector2(2500, 1380), Vector2(3200, 1380),
	])
	var vertical := PackedVector2Array([
		Vector2(1900, 0), Vector2(1900, 470), Vector2(1620, 1100),
		Vector2(1480, 1650), Vector2(1480, 2200),
	])
	for path in [horizontal, vertical]:
		draw_polyline(path, Color("a89b70"), 154.0)
		draw_polyline(path, Color("c6b78a"), 136.0)

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261016
	for index in range(2400):
		var point := Vector2(rng.randf_range(30, 3170), rng.randf_range(30, 2170))
		if _near_path(point, horizontal) or _near_path(point, vertical):
			if index % 8 == 0:
				draw_rect(Rect2(point, Vector2(4, 2)), Color("b3a47b"))
			continue
		var tint := Color("557c46") if index % 3 == 0 else Color("7da063")
		draw_line(point, point + Vector2(-3, -5), tint, 2.0)
		draw_line(point, point + Vector2(2, -7), tint, 2.0)
		if index % 19 == 0:
			draw_rect(Rect2(point + Vector2(-3, -7), Vector2(4, 4)), Color("e9db9a"))
		if index % 53 == 0:
			draw_rect(Rect2(point + Vector2(1, -8), Vector2(4, 4)), Color("dca3a1"))

	for point in [Vector2(1180, 870), Vector2(2130, 950), Vector2(760, 1530),
			Vector2(2320, 1670), Vector2(1350, 390), Vector2(2700, 530)]:
		_draw_bush(point)
	for point in [Vector2(1380, 1280), Vector2(1950, 740), Vector2(920, 1020),
			Vector2(2250, 1460), Vector2(1220, 1900)]:
		_draw_rock(point)
	draw_rect(Rect2(Vector2(12, 12), WORLD_SIZE - Vector2(24, 24)), Color("456a3d"), false, 24.0)


func _near_path(point: Vector2, path: PackedVector2Array) -> bool:
	for index in range(path.size() - 1):
		var closest := Geometry2D.get_closest_point_to_segment(point, path[index], path[index + 1])
		if point.distance_squared_to(closest) < 7200.0:
			return true
	return false


func _draw_bush(point: Vector2) -> void:
	draw_circle(point + Vector2(5, 8), 39, Color("577a46"))
	draw_circle(point + Vector2(-23, -9), 30, Color("3f6c43"))
	draw_circle(point + Vector2(23, -13), 32, Color("47794a"))
	draw_circle(point + Vector2(0, -29), 34, Color("53864f"))
	draw_circle(point + Vector2(-9, -40), 17, Color("669957"))


func _draw_rock(point: Vector2) -> void:
	draw_circle(point + Vector2(5, 4), 23, Color(0.1, 0.2, 0.1, 0.15))
	draw_colored_polygon(PackedVector2Array([
		point + Vector2(-23, -3), point + Vector2(-13, -22),
		point + Vector2(11, -26), point + Vector2(26, -10),
		point + Vector2(19, 6), point + Vector2(-14, 8),
	]), Color("7b8676"))
	draw_colored_polygon(PackedVector2Array([
		point + Vector2(-23, -3), point + Vector2(-13, -22),
		point + Vector2(11, -26), point + Vector2(4, -5),
	]), Color("a3ac94"))
