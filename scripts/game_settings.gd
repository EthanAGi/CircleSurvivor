# res://scripts/game_settings.gd
extends Node

signal settings_changed

const SETTINGS_PATH: String = "user://settings.cfg"

var fullscreen_enabled: bool = false
var screen_shake_enabled: bool = true
var damage_numbers_enabled: bool = true

func _ready() -> void:
	load_settings()
	_apply_display_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)

	if error != OK:
		save_settings()
		return

	fullscreen_enabled = bool(config.get_value("display", "fullscreen_enabled", false))
	screen_shake_enabled = bool(config.get_value("gameplay", "screen_shake_enabled", true))
	damage_numbers_enabled = bool(config.get_value("gameplay", "damage_numbers_enabled", true))

	_apply_display_settings()

func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("display", "fullscreen_enabled", fullscreen_enabled)
	config.set_value("gameplay", "screen_shake_enabled", screen_shake_enabled)
	config.set_value("gameplay", "damage_numbers_enabled", damage_numbers_enabled)

	config.save(SETTINGS_PATH)
	_apply_display_settings()
	settings_changed.emit()

func reset_settings() -> void:
	fullscreen_enabled = false
	screen_shake_enabled = true
	damage_numbers_enabled = true
	save_settings()

func set_fullscreen_enabled(value: bool) -> void:
	fullscreen_enabled = value
	save_settings()

func set_screen_shake_enabled(value: bool) -> void:
	screen_shake_enabled = value
	save_settings()

func set_damage_numbers_enabled(value: bool) -> void:
	damage_numbers_enabled = value
	save_settings()

func _apply_display_settings() -> void:
	if fullscreen_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
