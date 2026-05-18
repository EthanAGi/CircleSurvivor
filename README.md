# CircleSurvivor

A fast-paced survival game where every second matters.

Fight endless enemy waves, evolve your build through upgrades and synergies, and survive as long as possible in an increasingly chaotic arena.

---

# Overview

CircleSurvivor is a top-down roguelike survival game inspired by bullet-heaven gameplay.

Each run focuses on:
- Surviving escalating enemy waves
- Collecting EXP and leveling up
- Building powerful weapon combinations
- Creating chaotic upgrade synergies

Every run evolves differently depending on your build choices and survival strategy.

---

# Gameplay Loop

1. Enter the arena  
2. Defeat enemies  
3. Collect EXP  
4. Level up and choose upgrades  
5. Build synergies  
6. Survive as long as possible  

---

# Features

## Weapons
- **Bullets** — Rapid-fire sustained damage
- **Missiles** — Homing explosive projectiles with burn effects
- **Lightning** — Instant-hit chain attacks with shock synergy
- **Orbitals** — Rotating projectiles for area control
- **Forcefield** — Persistent close-range defensive damage aura

---

# Status Effects

## Burn
Damage-over-time effect applied through explosive attacks.

## Shock
Enhances lightning interactions and chain damage.

## Critical Effects
Critical hits can trigger:
- Explosions
- Burn
- Shock
- Cross-weapon synergies

---

# Enemy Systems

## Scaling Difficulty
Enemy pressure increases over time through:
- Faster spawns
- Higher enemy counts
- Increased speed
- Greater durability

## Enemy Types
- Melee enemies
- Projectile enemies
- Fast enemies
- Elite enemies

## Elite Enemies
Periodic stronger enemies with:
- Increased health
- Higher speed
- Increased damage

---

# Progression Systems

## Experience & Leveling
Enemies drop EXP pickups used for leveling and upgrades.

## EXP Vacuum
Special pickup that attracts nearby EXP toward the player.

## Build Variety
Runs evolve through:
- Randomized upgrades
- Weapon synergies
- Status interactions
- Critical effect combinations

---

# Player Systems

## Responsive Movement
Movement emphasizes precision and repositioning.

## Invulnerability Frames
After taking damage:
- Temporary invulnerability activates
- Player sprite flashes visually

## Camera Follow
Dynamic camera tracking with combat feedback effects.

---

# Combat Feedback

## Damage Numbers
Floating damage indicators improve readability.

## Camera Shake
Dynamic camera shake reinforces combat impact.

## Visual Clarity
Enemy health is represented through color changes instead of health bars.

---

# UI & Navigation

Supports both keyboard and mouse controls.

## Included Menus
- Main Menu
- Character Select
- Level Select
- Pause Menu
- Options Menu
- Game Over Screen

## Level-Up Interface
- Keyboard navigation
- Mouse selection
- Skip functionality
- Fast UI flow

---

# Systems & Architecture

Built using a modular scene-based structure in Godot.

Implemented systems include:
- Modular weapons
- Enemy spawning and scaling
- Status effects
- Area damage systems
- Pickup attraction
- EXP Vacuum system
- UI state management
- Camera feedback
- Elite enemy spawning
- Projectile combat
- Forcefield systems
- Critical effect inheritance

---

# Technical Highlights

## Modular Weapon Design
Weapons use separate scenes and scripts for scalability and maintainability.

## Dynamic Difficulty Scaling
Enemy intensity ramps continuously throughout each run.

## Performance-Oriented Design
Designed to support:
- Large enemy counts
- Multiple projectiles
- Persistent area effects
- High-action combat

while remaining responsive and readable.

---

# Design Philosophy

## Readability
Combat should remain visually understandable during chaos.

## Responsiveness
Movement, combat, and UI should feel smooth and immediate.

## Synergy
Weapons and upgrades are designed to combine into powerful builds.

---

# Tech Stack

| Category | Technology |
|---|---|
| Engine | Godot |
| Language | GDScript |
| Architecture | Scene-Based Modular Design |

---

# Controls

| Action | Input |
|---|---|
| Move | WASD / Arrow Keys |
| Navigate UI | W/S / Arrow Keys |
| Select | Enter / Mouse Click |
| Pause | ESC |

---

# Current Features

- Smooth player movement
- Multiple weapon systems
- Orbitals
- Missiles
- Lightning attacks
- Forcefield weapon
- Enemy AI and projectiles
- Elite enemies
- Burn and shock effects
- Critical effect inheritance
- Experience and leveling systems
- EXP Vacuum pickup
- Upgrade selection system
- Camera shake
- Damage numbers
- Invulnerability system
- Keyboard-friendly UI
- Pause functionality
- Difficulty scaling
- Area-of-effect combat systems

---

# Planned Features

- Boss encounters
- Additional enemy archetypes
- More weapons and evolutions
- Expanded upgrade pools
- Sound and music
- Particle effects and polish
- Meta progression systems
- Save/load systems
- Additional playable characters
- New arenas and environments

---

# Development Status

CircleSurvivor is actively developed through continuous iteration and feature expansion.

Current development focuses on:
- Gameplay feel
- Combat satisfaction
- System depth
- Maintainable architecture
- Long-term scalability

---

# Author

## Ethan G
Game Developer

---

# About the Project

CircleSurvivor is both:
- A fully playable survival game
- A long-term systems-focused game development project

The project emphasizes:
- Iterative development
- Gameplay experimentation
- Combat system design
- Modular architecture
- Continuous expansion

---

# Support the Project

If you enjoy the project:
- Star the repository
- Follow development updates
- Share feedback and suggestions

Every improvement helps shape the future of CircleSurvivor.
