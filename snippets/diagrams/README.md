For diagrams... [draw.io](https://www.draw.io/) seems pretty great.

Steps to embed a diagram from there...

1. File / Export as / SVG...
   2. Selection Only (w/ Cropping)
   2. Do not include a copy of my diagram
1. Download
1. Open the file
   2. Copy the `<svg` line (not the `DOCTYPE`)
   2. Add the `viewbox` attribute, documenting the internal canvas size (format is `0 0 {width attribute} {height attribute}`)
   2. Changing `width` to be 100%, and remove the `height` attribute.
1. Reference the SVG from your document using snippet form (e.g. `--8<-- "snippets/diagrams/my-diagram-export.svg"`)

Example of the file change...

    # before
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="806px" height="304px" version="1.1"

    # after
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewbox="0 0 806 304" width="100%" version="1.1"
