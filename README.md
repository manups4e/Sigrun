# Sigrun API 🎮

![Sigrun Banner|690x394, 75%](https://github.com/user-attachments/assets/dda2c0a0-099a-47d6-9131-91114b46ace8)

**Sigrun API** is a standalone library for FiveM that faithfully recreates the new **Rockstar Mission Creator** interface using the power of **Scaleform** movies. Designed to be lightweight, elegant, and high-performing, it allows developers to integrate "Native-style" menus with zero effort and maximum customization.

---

## ✨ Key Features

* **Authentic Rockstar Aesthetic:** A pixel-perfect clone of the GTA V Mission Creator menu.
* **Extreme Performance:** Optimized to run smoothly on any graphics card.
* **Advanced Widgets:**
    * **Checkboxes & Toggles:** Smooth interaction for settings.
    * **List Items:** Easy cycling through options.
    * **Sliders & Progress Bars:** Visual feedback for values and difficulty levels.
    * **Submenus:** Hierarchical structure for complex configurations.
* **Highly Customizable:** Supports custom colors, separators, and advanced labels.
* **Tab System:** Multiple menus sections divided on the same menu with mooth navigation between different categories using customizable icons.
* **Standalone:** No specific framework dependencies (works on ESX, QB, or custom).
* **Exports compatibility**: The API allows you to export the entire building system to any other resource by simply calling `exports.sigrun:GetAPI()` export. (WIP)

---

## 🛠️ Requirements

* No mandatory external dependencies.
* **Language:** **Lua** (C# version currently in development/WIP).

---

## 📥 Installation

1. Download the latest release or clone the repository.
2. Drag the `sigrun_assets` and `sigrun_lua` folder into your `resources` directory.
3. Add `ensure sigrun_assets` and `ensure sigrun_lua`  to your `server.cfg` file.
4. Test the new menu API using the example file with the provided example menu and start making your own menus.

---


## 🏗️ Roadmap
- [x] Stable Lua Version
- [ ] C# Version (WIP)

---

## 📄 License
This project is distributed under the **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License**.

**Created with ❤️ for the FiveM community.**

---

Check my FiveM best releases at
- ScaleformUI [Free]- https://forum.cfx.re/t/scaleformui-a-lightweight-fast-and-fun-api/4836252
- Bubble Emotes [Paid] - https://forum.cfx.re/t/paid-bubble-emotes-express-yourself-visually-standalone-rp/5327314
- ScaleDraw [Free] - https://forum.cfx.re/t/free-esx-qb-ox-whatev-scaledraw-standalone/5308697
- Brynhildr Inventory (Valkyr series) [Paid] - https://forum.cfx.re/t/release-paid-standalone-brynhildr-3d-inventory/5356307
- Eir HUD (Valkyr series) [Paid] - https://forum.cfx.re/t/paid-esx-qb-qbox-standalone-eir-hud-valkyr-series/5379159
- Aesir Compass [Paid] - https://forum.cfx.re/t/paid-standalone-aesir-compass/5380256
- Rounded Minimap [Paid] - https://forum.cfx.re/t/paid-standalone-rounded-minimap-esx-qb-all-frameworks-to-be-tagged-go-here/5255832
- Aesir Vehicle Dashboard [Paid] - https://forum.cfx.re/t/paid-standalone-aesir-vehicle-dashboard/5381184
