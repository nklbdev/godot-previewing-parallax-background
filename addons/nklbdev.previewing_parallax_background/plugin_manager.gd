tool
extends EditorPlugin

const _ppb_class_name: String = "PreviewingParallaxBackground"
const _ppb_base_class_name: String = "ParallaxBackground"
const _ppb_script: GDScript = preload("res://addons/nklbdev.previewing_parallax_background/PreviewingParallaxBackground.gd")
const _icon_texture: Texture = preload("type_icon.svg")

func _enter_tree():
	add_custom_type(_ppb_class_name, _ppb_base_class_name, _ppb_script, _icon_texture)

func _exit_tree():
	remove_custom_type(_ppb_class_name)
