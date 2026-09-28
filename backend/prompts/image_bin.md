---
name: image_bin
version: 1
description: The scanned item shown correctly prepared for its recycling stream (rinsed, cap off, flattened, label removed), so the Recycle path has a picture to copy.
references: 1 = the user's photo, cropped to the item when the analysis has its bounding box
inputs: item, material, category, condition, stream, prep_steps
---

## task
Edit the attached photo to show this item correctly prepared for recycling, ready to take to the {{stream}}.
Item: {{item}} ({{material}}; category: {{category}}).
Its condition in the photo: {{condition}}.

## prep
Show the result of these preparation steps, all already done:
{{prep_steps}}

<!-- The picture is a visual checklist: the end state is what the user needs to copy, not the action. -->
Show the end state, not the process: a rinsed container is clean and dry, a removed cap or lid sits next to the item, a flattened box lies flat, a peeled label is gone with no paper left behind. Do only what the steps say; never cut, paint, decorate or repair the item.

## no_prep
No special preparation is needed: show the item empty, clean and dry, ready to drop off as it is.

## identity
Keep the item's identity: its exact shape (unless a step flattens or crushes it), color, material and distinctive details such as scratches, dents or chips. Keep the same surface, lighting direction and camera angle as the photo. Show only this item and the parts a step separates from it (a cap, a lid, a label); remove any other objects from the photo and fill the surface behind them in naturally.
