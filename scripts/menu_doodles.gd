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
