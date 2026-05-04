# CircleSurvivor

A fast-paced, systems-driven survival game built in Godot.  
Fight through escalating enemy waves, construct powerful builds, and master layered combat mechanics to survive as long as possible.

---

## Overview

CircleSurvivor is a top-down survival experience inspired by roguelike and bullet-heaven design, with a focus on mechanical depth, responsive controls, and build experimentation.

Players are placed in an arena where enemies continuously evolve in difficulty. Through combat, you collect experience, level up, and shape your build using randomized upgrade choices. Success depends on positioning, decision-making, and synergy between abilities.

---

## Key Features

### Combat System
- Responsive, physics-based player movement
- Multi-weapon combat system with distinct behaviors:
  - **Projectile Bullets** (rapid, consistent damage)
  - **Homing Missiles** (target tracking with explosion effects)
  - **Lightning Strikes** (instant hits with area-of-effect chaining)
  - **Orbiting Projectiles** (persistent defensive/offensive zone)
- Status-based combat interactions:
  - Burn effects (damage over time)
  - Shock effects (enhanced damage behavior)
- Area-of-effect damage systems for explosive and lightning attacks

---

### Enemy Design
- Multiple enemy types with distinct behaviors
- Projectile-based enemy attacks
- Scaling difficulty over time
- **Elite enemy system**:
  - Spawns at timed intervals
  - Increased durability and threat level
  - Forces adaptation in player strategy

---

### Progression & Build System
- Experience pickups with attraction and collection mechanics
- Fully implemented leveling system
- Randomized upgrade selection per level
- Upgrade skipping for faster pacing
- Build-focused gameplay encouraging synergy between weapons and effects

---

### Combat Feedback & Polish
- Floating damage numbers system:
  - Separate visual styles for player vs enemy damage
- Camera shake system on player damage
- Visual clarity for hit detection and attack feedback
- Enemy health represented through color (no UI clutter)

---

### Player Systems
- Temporary invulnerability after taking damage
- Visual feedback during invulnerability (sprite flashing)
- Health and damage handling systems
- Responsive input handling for both gameplay and UI

---

### UI & UX Systems
- Fully navigable UI using:
  - Keyboard (W/S or Arrow Keys)
  - Mouse
- Focus-based menu navigation system
- Complete menu flow:
  - Main Menu
  - Character Select
  - Level Select
  - Options Menu
  - Pause Menu
- Level-up selection interface with input support
- Restart and game-over flow

---

### Core Game Systems
- Enemy spawning system with scaling intensity
- Timer-based progression and difficulty ramping
- Modular weapon system
- Damage calculation and status handling systems
- Scene-based architecture for clean system separation

---

## Tech Stack

- **Engine:** Godot  
- **Language:** GDScript  
- **Architecture:** Scene-based modular design  

---

## Controls

| Action        | Input                |
|--------------|---------------------|
| Move         | WASD / Arrow Keys   |
| Navigate UI  | W/S or Arrow Keys   |
| Select       | Enter / Click       |
| Pause        | ESC                 |

---

## Current Systems Implemented

- Player combat system
- Enemy AI and spawning system
- Elite enemy system
- Multiple weapon types with unique behaviors
- Status effects (burn and shock)
- EXP and leveling system
- Upgrade selection and skip system
- Damage number system
- Camera feedback system
- Full UI navigation system (keyboard + mouse)
- Menu system (main, level select, character select, options)
- Pause and restart systems
- Game over handling

---

## Planned Features

- Boss encounters with unique mechanics
- Expanded weapon and upgrade trees
- Audio design (sound effects and music)
- Visual polish (particles, animations, screen effects)
- Meta progression / persistent upgrades
- Save system
- Additional enemy archetypes

---

## Author

Ethan G  
Game Developer  

---

## Notes

This project is actively being developed with a focus on continuous iteration, system expansion, and gameplay polish.  
It serves as both a technical showcase and an evolving game project.

---

## If you like the project

Consider starring the repository and following development.
