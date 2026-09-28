---
name: image_reference
version: 1
description: For text scans (no photo), a realistic photo of the described item. It becomes the base image that after, step and bin pictures edit, so they stay consistent with each other.
references: none
inputs: description
---

## task
Create a realistic photo of the household item described below, as its owner would snap it with a phone before deciding whether to upcycle, recycle or donate it.
The owner's description: "{{description}}"

## scene
<!-- Every later edit inherits this framing, so it must leave room for projects that add a handle, a plant or a stand. -->
Show the item whole and fully in frame, centered, on a plain home surface such as a kitchen counter, a wooden table or a tiled floor, against a simple, uncluttered background with some free space around it. If the description names several pieces or a pile, show that quantity together. Show the condition the description gives; if it gives none, show a clean, used item with light everyday wear, not a new product.
