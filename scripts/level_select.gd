# res://scripts/level_select.gd
extends Control

@onready var test_level_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TestLevelButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	test_level_button.pressed.connect(_on_test_level_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_test_level_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")
