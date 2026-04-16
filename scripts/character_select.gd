# res://scripts/character_select.gd
extends Control

@onready var test_character_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TestCharacterButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	test_character_button.pressed.connect(_on_test_character_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_setup_menu_focus()

func _setup_menu_focus() -> void:
	test_character_button.focus_mode = Control.FOCUS_ALL
	back_button.focus_mode = Control.FOCUS_ALL

	test_character_button.focus_neighbor_top = back_button.get_path()
	test_character_button.focus_neighbor_bottom = back_button.get_path()

	back_button.focus_neighbor_top = test_character_button.get_path()
	back_button.focus_neighbor_bottom = test_character_button.get_path()

	test_character_button.mouse_entered.connect(func() -> void: test_character_button.grab_focus())
	back_button.mouse_entered.connect(func() -> void: back_button.grab_focus())

	test_character_button.grab_focus()

func _on_test_character_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
