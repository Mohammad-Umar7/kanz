---
name: image_step
version: 1
description: One picture in a tutorial's step chain. Step 1 edits the original photo and every later step edits the previous step's picture, so the series shows one object progressing.
references: step 1 = [original photo]; step N = [step N-1 picture, original photo]; the last step adds [finished project (after image)] when it exists
inputs: step, total, goal, image_prompt, previous_step, previous_prompt, upcoming, after_index
---

## task
These pictures illustrate a hands-on upcycling tutorial: one photo per step, all of the same object in the same spot. For context, the finished project will be: {{goal}}. This picture is step {{step}} of {{total}}.

## refs_first
Image 1 is the owner's original photo of the item, before any work. Edit image 1.

## refs_chain
<!-- Chaining is what keeps the series consistent: each picture starts from the last one, and the original photo is sent too so small drifts in color or shape get pulled back instead of piling up. -->
Image 1 is the photo taken after step {{previous_step}}; it shows: {{previous_prompt}}. Edit image 1. Image 2 is the owner's original photo, before any work: use it only as the reference for the object's true shape, color, material, surface and background, and correct anything in image 1 that has drifted from it.

## refs_final
Image {{after_index}} shows the finished project exactly as the owner has already seen it on the idea card. This is the last step, so the object must end up matching image {{after_index}}: same added materials, colors, placement and finish.

## change
Show the item right after step {{step}}:
{{image_prompt}}

## progress
<!-- Without this, models skip ahead to the finished look after one or two steps. Naming what comes later pins each picture to its own moment. -->
Show exactly the progress made up to this step, no more. Everything done so far stays exactly as it is in image 1. These later steps have not happened yet, so none of their results may appear:
{{upcoming}}

## finale
This is the final step: show the finished project complete, tidy and ready to use, still in the same spot.

## identity
It is one physical object throughout the series. Keep its exact shape, proportions, color, material and distinctive details (label remnants, scratches, dents, chips) unless a step removes or covers them. Keep the same surface, background, lighting direction and camera angle and framing as image 1, as if the phone stood on a tripod for the whole project. Remove any hands or tools left in the frame from an earlier step unless this step needs them to show the technique.
