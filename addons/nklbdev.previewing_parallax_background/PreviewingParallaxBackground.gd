tool
extends ParallaxBackground
class_name PreviewingParallaxBackground

onready var _editor_viewport: Viewport = _find_editor_viewport(get_tree().root) if Engine.editor_hint else null
var _previous_viewport_transform: Transform2D
export var preview_enabled: bool = true setget _set_preview_enabled
func _set_preview_enabled(value: bool):
	if preview_enabled == value:
		return
	preview_enabled = value
	if Engine.editor_hint and _editor_viewport:
		if preview_enabled:
			_update_children(true)
		else:
			_reset_children()

func _enter_tree():
	# reset positions that was changed in editor and saved in scene
	if not Engine.editor_hint:
		_reset_children()

func _reset_children():
	for child in get_children():
		if child is ParallaxLayer:
			child.position = Vector2.ZERO

func _update_children(force: bool = false):
	var viewport_transform = _editor_viewport.global_canvas_transform
	if not force and viewport_transform == _previous_viewport_transform:
		return
	_previous_viewport_transform = viewport_transform
	var visibleRectGlobal: Rect2 = viewport_transform.affine_inverse().xform(Rect2(Vector2.ZERO, _editor_viewport.size))
	var view_center = visibleRectGlobal.position + visibleRectGlobal.size / 2
	for child in get_children():
		if child is ParallaxLayer:
			child.position = view_center - view_center * child.motion_scale + child.motion_offset

func _process(_delta):
	if preview_enabled and Engine.editor_hint and _editor_viewport:
		_update_children()

func _find_editor_viewport(node: Node, recursive_level = 0) -> Viewport:
	if node.get_class() == "CanvasItemEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0) as Viewport
	recursive_level += 1
	if recursive_level > 15:
		return null
	for child in node.get_children():
		var result = _find_editor_viewport(child, recursive_level)
		if result:
			return result
	return null
