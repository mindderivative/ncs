## Summary

This README provides a professional overview of the **Node Component System (NCS)**, a modular architectural framework designed for **Godot 4.6+**. The system leverages the **Scene Layer**, the highest level of Godot's architecture, to implement a "Composition over Inheritance" workflow. By decoupling logic into discrete **Components** and configuration into **Data Resources**, the NCS ensures that game entities remain scalable, maintainable, and highly performant.

---

## 🏗️ Core Architectural Philosophy

The NCS is built to align with the core principles of Godot's **Object** and **Scene** systems:

* **Entities (Nodes)**: Standard Godot nodes (e.g., `CharacterBody2D`, `Node3D`) that serve as shells for behavior.
* **Components**: Specialized scripts attached as children to an Entity to handle specific logic chunks (e.g., Health, Movement).
* **Data (Resources)**: Built upon the `Resource` class—which inherits from `RefCounted` for efficient memory management—these store all static configuration.

---

## 📂 Project Structure

Following the organization in **Godot Project: NCS_3**, the repository is structured as follows:

* **`core/`**: Abstract base classes for the framework.
* `data.gd`: The base `Resource` for all component configuration.
* `component.gd`: The base logic for standard `Node` components.
* `component_2d.gd` / `component_3d.gd`: Specialized components for spatial entities.


* **`components/`**: Concrete behavior implementations (e.g., Health, Movement).
* **`data/`**: Custom `.tres` files that act as data templates for components.

---

## 🚀 Key Features & Standards

* **Godot 4.6+ Optimized**: Leverages modern GDScript features such as `Callable`, `Signal` syntax, and strict static typing for maximum engine performance.
* **Memory Efficiency**: Utilizes Godot’s **Variant** system and **Resource** reference counting to minimize the memory footprint of duplicated entities.
* **Decoupled Communication**: Components communicate via signals or `@export` references; the use of `get_parent().get_node()` is strictly forbidden to prevent brittle dependencies.
* **Performance First**: Minimizes expensive operations in `_process` or `_physics_process`, relying on signal-driven logic to ensure code only runs when necessary.

---

## 📖 Usage Example

### 1. Define Your Data

Create a script extending the base `Data` class to hold variables.

```gdscript
class_name HealthData
extends Data # Inherits from core/data.gd

@export var max_health: float = 100.0
@export var flat_defense: float = 5.0

```

### 2. Implementation

Attach a Component to your Entity and drag your `.tres` Data resource into the Inspector slot.

```gdscript
class_name HealthComponent
extends Component

@export var health_data: HealthData

func _ready() -> void:
    if health_data:
        print("Initialized with max health: ", health_data.max_health)

```

---

## 🛠️ Development Environment

* **Engine**: Godot 4.6+
* **OS**: Zorin OS
* **Version Control**: Managed via GitHub

---
 
