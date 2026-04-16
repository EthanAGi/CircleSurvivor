# res://scripts/level_select.gd
extends Control

@onready var test_level_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TestLevelButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	test_level_button.pressed.connect(_on_test_level_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_setup_menu_focus()

func _setup_menu_focus() -> void:
	test_level_button.focus_mode = Control.FOCUS_ALL
	back_button.focus_mode = Control.FOCUS_ALL

	test_level_button.focus_neighbor_top = back_button.get_path()
	test_level_button.focus_neighbor_bottom = back_button.get_path()

	back_button.focus_neighbor_top = test_level_button.get_path()
	back_button.focus_neighbor_bottom = test_level_button.get_path()

	test_level_button.mouse_entered.connect(func() -> void: test_level_button.grab_focus())
	back_button.mouse_entered.connect(func() -> void: back_button.grab_focus())

	test_level_button.grab_focus()

func _on_test_level_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")
