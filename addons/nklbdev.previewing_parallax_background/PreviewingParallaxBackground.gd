tool
extends ParallaxBackground
class_name PreviewingParallaxBackground

var _editor_viewport: Viewport
var _previous_canvas_transform: Transform2D
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

func _ready():
	if Engine.editor_hint:
		var edited_scene_root = get_tree().edited_scene_root
		if edited_scene_root:
			_editor_viewport = edited_scene_root.get_viewport()

func _enter_tree():
	# reset positions that was changed in editor and saved in scene
	if not Engine.editor_hint:
		_reset_children()

func _reset_children():
	for child in get_children():
		if child is ParallaxLayer:
			child.position = Vector2.ZERO

func _process(_delta):
	if preview_enabled and Engine.editor_hint and _editor_viewport:
		_update_children()

func _update_children(force: bool = false):
	var canvas_transform = _editor_viewport.global_canvas_transform
	if not force and canvas_transform == _previous_canvas_transform:
		return
	_previous_canvas_transform = canvas_transform
	
	var vps = _editor_viewport.size
	var inverted_canvas_transform = canvas_transform.affine_inverse()
	var screen_offset = -inverted_canvas_transform.xform(vps / 2)

	var scroll_ofs = scroll_base_offset + screen_offset * scroll_base_scale
	
	scroll_ofs = -scroll_ofs
	if scroll_limit_begin.x < scroll_limit_end.x:
		if scroll_ofs.x < scroll_limit_begin.x:
			scroll_ofs.x = scroll_limit_begin.x
		elif scroll_ofs.x + vps.x > scroll_limit_end.x:
			scroll_ofs.x = scroll_limit_end.x - vps.x

	if scroll_limit_begin.y < scroll_limit_end.y:
		if scroll_ofs.y < scroll_limit_begin.y:
			scroll_ofs.y = scroll_limit_begin.y
		elif scroll_ofs.y + vps.y > scroll_limit_end.y:
			scroll_ofs.y = scroll_limit_end.y - vps.y
	scroll_ofs = -scroll_ofs;
	
	var scroll_scale = inverted_canvas_transform.get_scale().dot(Vector2.ONE)
	scroll_ofs = (scroll_ofs + screen_offset * (scroll_scale - 1)) / scroll_scale

	for child in get_children():
		if child is ParallaxLayer:
			child.position = scroll_ofs * child.motion_scale + child.motion_offset - screen_offset
