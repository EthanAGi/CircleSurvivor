# CircleSurvivor

A fast-paced survival game where every second matters.

Fight through relentless enemy waves, evolve your build through powerful upgrades, and survive as long as possible in an ever-escalating arena of chaos.

---

# Overview

CircleSurvivor is a top-down survival game inspired by roguelike and bullet-heaven gameplay.

You begin each run with one goal:

> **Stay alive.**

Enemies continuously grow stronger as you defeat them, collect experience, and level up through randomized upgrades and weapon synergies.

Every run evolves differently depending on:
- Upgrade choices
- Weapon combinations
- Positioning
- Enemy scaling

The longer you survive, the more chaotic the arena becomes.

---

# Gameplay Loop

1. Enter the arena  
2. Fight endless enemy waves  
3. Collect EXP pickups  
4. Level up and choose upgrades  
5. Build powerful synergies  
6. Survive as long as possible  

---

# Features

## Combat System

### Weapons

#### Bullets
- Rapid-fire projectile damage
- Reliable sustained DPS
- Can inherit critical effects

#### Missiles
- Homing explosive projectiles
- Area-of-effect explosions
- Burn effect support

#### Lightning
- Instant-hit chain attacks
- Burst damage and shock synergy
- Area strike damage

#### Orbitals
- Rotating projectiles around the player
- Constant close-range damage
- Area control utility

#### Forcefield
- Persistent defensive aura
- Damages nearby enemies automatically
- Scales into near-constant protection

---

# Status Effects

## Burn
Damage-over-time effect applied through explosive attacks.

## Shock
Enhances chain damage and lightning interactions.

## Critical Effects
Critical hits can inherit special effects such as:
- Explosions
- Burn
- Shock
- Cross-weapon synergies

This allows builds to evolve into chaotic chain-reaction setups.

---

# Enemy Systems

## Scaling Difficulty
Enemy pressure increases over time through:
- Faster spawns
- Larger enemy counts
- Increased speed
- Higher durability

## Enemy Types
Includes:
- Melee enemies
- Projectile enemies
- Fast-moving threats
- Elite enemies

## Elite Enemies
Powerful enemies that appear periodically with:
- Increased health
- Increased speed
- Higher damage output

---

# Progression Systems

## Experience & Leveling
Defeated enemies drop EXP pickups used to level up and unlock upgrades.

## EXP Vacuum
A special pickup that pulls nearby experience toward the player, improving pacing and reducing backtracking.

## Build Variety
Runs evolve through:
- Randomized upgrades
- Weapon synergies
- Status interactions
- Critical effect combinations

---

# Player Systems

## Responsive Movement
Movement is built around precision and constant repositioning.

## Invulnerability Frames
After taking damage:
- The player briefly becomes invulnerable
- The player sprite flashes visually

## Camera Follow
The camera remains centered on the player and reacts dynamically during combat.

---

# Combat Feedback

## Damage Numbers
Floating damage indicators improve combat readability and critical hit visibility.

## Camera Shake
The camera reacts dynamically when taking damage to reinforce impact.

## Visual Clarity
Enemy health is represented visually through color changes instead of traditional health bars.

---

# UI & Navigation

The game supports both keyboard and mouse controls.

## Included Menus
- Main Menu
- Character Select
- Level Select
- Pause Menu
- Options Menu
- Game Over Screen

## Level-Up Interface
Supports:
- Keyboard navigation
- Mouse selection
- Skip functionality
- Fast UI flow

---

# Systems & Architecture

Built using a modular scene-based structure in Godot.

Implemented systems include:
- Modular weapon architecture
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
Weapons operate through separate scenes and scripts for scalability and maintainability.

## Dynamic Difficulty Scaling
Enemy pressure ramps continuously throughout each run.

## Performance-Oriented Design
Built to support:
- Large enemy counts
- Multiple simultaneous projectiles
- Persistent area effects
- High-action combat

while remaining responsive and readable.

---

# Design Philosophy

CircleSurvivor is built around three core principles:

## Readability
Combat should remain visually understandable during chaos.

## Responsiveness
Movement, attacks, and menus should always feel smooth and immediate.

## Synergy
Weapons, upgrades, and status effects are designed to combine into powerful interactions.

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

# Current State

## Implemented Features
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

CircleSurvivor serves as both:
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
