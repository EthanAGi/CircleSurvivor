# res://scripts/options_menu.gd
extends Control

@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

	_setup_menu_focus()

func _setup_menu_focus() -> void:
	back_button.focus_mode = Control.FOCUS_ALL
	back_button.mouse_entered.connect(func() -> void: back_button.grab_focus())
	back_button.grab_focus()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
