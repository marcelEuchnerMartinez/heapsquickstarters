# HeapsIO quickstarters

Samples on how to implement customary game features with the HeapsIO API.

1. "astro shooter"
    - very close to the HeapsIO API, no custom `Entity` class etc.
2. "astro shooter" (performance boosted version)
    - no `findAll()` in the game's `update()` loop to gain performance
    - requires maintaining Haxe arrays instead
3. "RPG"
    - Sample on how to implement the HeapsIO `h2d.Camera` and separating world and UI by `h2d.Scene`'s `h2d.Layers`