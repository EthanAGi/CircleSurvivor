# res://scripts/character_select.gd
extends Control

@onready var test_character_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TestCharacterButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	test_character_button.pressed.connect(_on_test_character_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_test_character_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
