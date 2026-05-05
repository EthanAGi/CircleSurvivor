# CircleSurvivor

A fast-paced survival game where every second matters.  
Fight off relentless enemy waves, evolve your build through powerful upgrades, and push your limits to survive as long as possible.

---

## What is CircleSurvivor?

CircleSurvivor is a top-down survival game inspired by roguelike and bullet-heaven gameplay.

You are dropped into an arena with one goal: **stay alive**.

Enemies spawn endlessly and grow stronger over time. As you defeat them, you gain experience, level up, and choose upgrades that shape your playstyle. Every run becomes a unique build, driven by your decisions and the synergies you create.

Victory isn’t about winning — it’s about lasting longer than your last attempt.

---

## Core Gameplay Loop

1. Survive against continuous enemy waves  
2. Defeat enemies to gain experience  
3. Level up and choose upgrades  
4. Build powerful synergies  
5. Adapt as difficulty increases  
6. Repeat until overwhelmed  

---

## Features

### Combat
- Smooth and responsive movement
- Multiple weapon types with distinct roles:
  - **Bullets** – consistent, rapid-fire damage
  - **Missiles** – homing attacks with explosive impact
  - **Lightning** – instant strikes with chaining damage
  - **Orbitals** – rotating defenses that damage nearby enemies
- Area-of-effect damage and chain reactions
- Status effects:
  - **Burn** – damage over time
  - **Shock** – enhanced damage interactions

---

### Enemies
- Variety of enemy behaviors and movement patterns
- Ranged enemies with projectile attacks
- Scaling difficulty that increases pressure over time
- **Elite enemies**:
  - Spawn at intervals
  - Stronger, faster, and more dangerous
  - Force changes in positioning and strategy

---

### Progression
- Experience drops from defeated enemies
- Level-up system with randomized upgrade choices
- Skip option for faster pacing
- Build-focused design encouraging synergy between weapons and effects

---

### Player Systems
- Health and damage handling
- Brief invulnerability after taking damage
- Visual feedback during invulnerability (flashing effect)
- Responsive controls for both gameplay and UI

---

### Feedback & Feel
- Floating damage numbers
  - Different visuals for player vs enemy damage
- Camera shake when taking damage
- Clear visual feedback for hits and effects
- Enemy health represented through color instead of UI bars

---

### UI & Menus
- Fully navigable with keyboard and mouse
- Clean menu flow:
  - Main Menu
  - Character Select
  - Level Select
  - Options
  - Pause Menu
- Level-up selection interface with full input support
- Game over and restart systems

---

### Systems & Architecture
- Scalable enemy spawning system
- Time-based difficulty ramping
- Modular weapon system
- Status effect and damage systems
- Scene-based structure for clean, maintainable code

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

## Current State

CircleSurvivor is fully playable and includes:

- Core combat systems
- Multiple weapon types
- Enemy AI and spawning
- Elite enemies
- Status effects
- Leveling and upgrades
- Damage feedback systems
- Full UI navigation and menus
- Pause and restart functionality

---

## Planned Features

- Boss fights with unique mechanics
- Expanded upgrade and weapon systems
- Audio (sound effects and music)
- Visual polish (particles, animations, effects)
- Meta progression systems
- Save/load functionality
- More enemy types and behaviors

---

## Author

Ethan G  
Game Developer  

---

## About This Project

CircleSurvivor is an actively developed project focused on:
- Expanding gameplay depth
- Improving system design
- Delivering satisfying combat feedback

It serves both as a playable game and a demonstration of game system design and implementation.

---

## Support the Project

If you enjoy the project, consider starring the repository and following its development.
