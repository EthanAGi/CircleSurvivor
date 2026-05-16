# CircleSurvivor

A fast-paced survival game where every second matters.

Fight through relentless enemy waves, evolve your build through powerful upgrades, and survive as long as possible in an ever-escalating arena of chaos.

---

# Overview

CircleSurvivor is a top-down survival game inspired by roguelike and bullet-heaven gameplay.

You begin each run with minimal power and a single goal:

> **Stay alive.**

Enemies continuously spawn and grow stronger over time. Defeating them grants experience, allowing you to level up and shape your build through randomized upgrades and weapon synergies.

Each run becomes a different experience depending on:
- Your upgrade choices
- Weapon combinations
- Positioning
- Risk management
- Enemy scaling

The longer you survive, the more overwhelming the arena becomes.

Victory is temporary.  
Improvement is permanent.

---

# Gameplay Loop

The core gameplay loop is built around constant progression and escalating pressure.

## 1. Enter the Arena
Spawn into a hostile environment with basic combat capabilities and limited survivability.

## 2. Fight Enemy Waves
Enemies appear endlessly and increase in difficulty over time:
- Higher health
- Faster movement
- Greater enemy density
- More dangerous attack patterns

## 3. Collect Experience
Defeated enemies drop experience pickups that can:
- Be collected manually
- Be attracted from nearby distances
- Chain into fast progression during large fights
- Be pulled in automatically through the EXP Vacuum pickup

## 4. Level Up
Each level grants randomized upgrade choices that shape your run:
- Increase weapon power
- Unlock new combat effects
- Improve survivability
- Create build synergies

## 5. Adapt Your Build
Your choices determine how your run evolves:
- Rapid projectile builds
- Area denial setups
- Status-effect focused combat
- Explosive chain-reaction builds
- Defensive orbital strategies
- Forcefield-based close-range combat

## 6. Survive Longer
As elite enemies begin appearing and enemy pressure ramps up, positioning and build decisions become increasingly important.

Eventually, the arena overwhelms you.

Then the next run begins.

---

# Features

# Combat System

CircleSurvivor focuses heavily on responsive combat feel and layered weapon interactions.

## Weapons

### Bullets
Fast and reliable projectile-based damage.
- Rapid-fire attacks
- Strong sustained DPS
- Core foundational weapon
- Can inherit critical effect upgrades

### Missiles
Homing explosive projectiles.
- Tracks enemies automatically
- Explosion-based area damage
- Burn effect support
- Area-of-effect detonation damage

### Lightning
Instant-hit chain attacks.
- High burst damage
- Area chain interactions
- Shock effect synergy
- Area-of-effect strike damage

### Orbitals
Rotating projectiles surrounding the player.
- Persistent close-range defense
- Area control
- Constant collision damage

### Forcefield
A persistent area-of-effect defensive weapon.
- Damages nearby enemies automatically
- Creates defensive space around the player
- Scales into a near-constant defensive zone
- Inspired by survival-style aura weapons

---

# Status Effects

## Burn
Deals damage over time after impact.

Burn can be applied through explosive and missile-based attacks.

## Shock
Enhances damage interactions and chain effects.

Shock effects synergize heavily with lightning attacks and area damage.

## Critical Effect System
Critical hits can inherit additional combat effects depending on upgrades obtained during a run.

Critical attacks may trigger:
- Explosions
- Burn effects
- Shock interactions
- Cross-weapon combat synergies

This system allows builds to evolve into highly chaotic chain-reaction setups.

---

# Enemy Systems

## Scaling Difficulty
Enemy pressure increases continuously throughout a run:
- Faster spawn rates
- Larger enemy counts
- Increased movement speed
- Higher durability

## Enemy Variety
Different enemy types introduce varying combat pressures:
- Direct melee pursuit
- Projectile-based attacks
- High-speed threats
- Elite units

## Elite Enemies
Special enemies spawn at intervals and significantly increase danger.

Elite enemies feature:
- Increased health
- Increased movement speed
- Higher damage output
- Greater battlefield pressure

They act as pacing spikes that force players to reposition and adapt.

## Enemy Projectiles
Certain enemies can attack from range using projectile systems, forcing players to remain mobile and aware of battlefield positioning.

---

# Progression Systems

## Experience & Leveling
Defeating enemies rewards experience pickups.

Leveling up pauses gameplay and presents randomized upgrade options that influence:
- Damage
- Attack speed
- Utility
- Survivability
- Weapon evolution

## EXP Vacuum
The EXP Vacuum is a special pickup that instantly pulls experience pickups toward the player.

It improves progression flow by allowing the player to rapidly collect scattered experience after large fights.

The EXP Vacuum supports:
- Faster level progression
- Reward cleanup after intense enemy waves
- Reduced backtracking for distant pickups
- Smoother pacing during chaotic combat
- More satisfying post-fight collection moments

## Build Variety
Runs naturally evolve depending on upgrade combinations and player decisions.

The system encourages experimentation and replayability through:
- Randomized upgrades
- Weapon synergy
- Status interactions
- Scaling power curves
- Critical effect combinations

## Upgrade Selection
Players choose from randomized upgrade pools during each level-up.

The system supports:
- Keyboard navigation
- Mouse interaction
- Skip functionality
- Fast gameplay flow
- Build specialization

---

# Player Systems

## Health & Damage
The player can survive multiple hits, but enemy pressure escalates rapidly over time.

## Invulnerability Frames
After taking damage:
- The player becomes briefly invulnerable
- The sprite flashes visually during invulnerability
- Prevents instant multi-hit deaths

## Responsive Movement
Movement is built around precision and constant repositioning.

Controls are designed to remain smooth and responsive even during high enemy density.

## Camera Follow System
The camera remains centered on the player and dynamically reacts to combat situations to reinforce impact and movement feel.

---

# Combat Feedback & Visual Feel

CircleSurvivor emphasizes readable and satisfying combat feedback.

## Damage Numbers
Floating damage indicators display:
- Enemy damage
- Player damage
- Combat readability
- Critical hit visibility

## Camera Shake
The camera reacts dynamically when taking damage to reinforce impact.

## Visual Clarity
Enemy health is represented visually through color changes rather than traditional health bars, reducing UI clutter while maintaining readability.

## Combat Density
Combat systems are designed to remain visually understandable even during large-scale enemy encounters and overlapping weapon effects.

---

# UI & Navigation

The entire game is fully playable with both keyboard and mouse controls.

## Menu Systems
- Main Menu
- Character Select
- Level Select
- Options Menu
- Pause Menu
- Game Over Screen

## Pause Functionality
Gameplay can be paused seamlessly during runs while maintaining UI navigation support.

## Level-Up Interface
The level-up system supports:
- Keyboard navigation
- Mouse selection
- Focus management
- Quick selection flow
- Skip functionality

## Controller-Friendly Navigation Philosophy
UI systems are built around fast and responsive navigation principles to minimize gameplay interruption.

---

# Systems & Architecture

The project is built using a modular scene-based structure in Godot.

Implemented systems include:
- Modular weapon architecture
- Enemy spawning framework
- Difficulty scaling system
- Status effect handling
- Area damage systems
- Pickup attraction systems
- EXP Vacuum pickup system
- UI state management
- Camera feedback systems
- Input-driven menu navigation
- Elite enemy spawning systems
- Projectile combat systems
- Forcefield aura systems
- Critical effect inheritance systems

The structure is designed for maintainability and rapid feature expansion.

---

# Technical Highlights

## Modular Weapon Design
Each weapon operates through its own scene and script structure, making the combat system easy to expand and maintain.

## Scene-Based Architecture
Gameplay systems are separated into reusable scenes and scripts to keep development scalable and organized.

## Dynamic Difficulty Scaling
Enemy pressure ramps continuously over time using scalable spawning and stat systems.

## Input Flexibility
Menus and gameplay support both keyboard and mouse interaction with full UI navigation support.

## Performance-Oriented Design
Systems are designed to support:
- Large enemy counts
- Multiple simultaneous projectiles
- Persistent area effects
- High-action combat scenarios
- Rapid experience collection through vacuum-style pickup behavior

while remaining responsive and readable.

---

# Design Philosophy

CircleSurvivor is designed around three major principles:

## 1. Readability
Combat should remain visually understandable even during chaos.

## 2. Responsiveness
Movement, attacks, and menus should always feel immediate and smooth.

## 3. Synergy
The most satisfying builds emerge through combinations of systems interacting together.

Weapons, status effects, and upgrades are intentionally designed to overlap and create unexpected build interactions.

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

CircleSurvivor is currently fully playable and includes:

## Implemented Features
- Smooth player movement
- Multiple weapon systems
- Orbiting projectiles
- Homing missiles
- Lightning attacks
- Forcefield aura weapon
- Enemy AI and pathing
- Ranged enemy attacks
- Enemy projectile systems
- Elite enemies
- Status effects
- Burn and shock interactions
- Critical effect inheritance
- Experience and leveling systems
- EXP Vacuum pickup system
- Upgrade selection system
- Camera shake
- Damage numbers
- Invulnerability system
- Keyboard-friendly UI
- Pause functionality
- Restart systems
- Menu navigation systems
- Difficulty scaling
- Area-of-effect combat systems

---

# Development Roadmap

## Planned Features
- Boss encounters
- Additional enemy archetypes
- More weapons and evolutions
- Expanded upgrade pools
- Sound effects and music
- Particle effects and visual polish
- Animation improvements
- Meta progression systems
- Save/load systems
- Additional playable characters
- New arenas and environments
- Weapon evolutions
- Advanced status interactions

---

# Development Status

CircleSurvivor is actively developed through continuous iteration and feature expansion.

The project currently focuses on:
- Gameplay feel
- System depth
- Combat satisfaction
- Code maintainability
- Long-term scalability

New systems and improvements are added regularly as development continues.

---

# Author

## Ethan G
Game Developer

---

# About This Project

CircleSurvivor serves as both:
- A fully playable survival game
- A long-term game development project focused on gameplay systems and scalable architecture

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
