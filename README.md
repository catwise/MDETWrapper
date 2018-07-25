# MDETWrapper

## Summary
The MDETWrapper first collects unWISE co-added images and their uncertainties then creates their CatWISE point spread functions (PSF's). The MDETWrapper then runs these inputs through the ICORE software developed for the WISE catalog. The wrapper ensures the output files from ICORE are in the correct file format and directory structure for the CatWISE source detection program, MDET, and the rest of the pipeline.

## Technical Summary
TODO

## How to Run Modes
* Mode 1: Everything Mode
	* Run all tiles in input directory
	* **./icore\_wrapper\_executable** 1 \<ParentDirectory\>
* Mode 2: List Mode
	* Run all tiles in input list
	* **./icore\_wrapper\_executable** 2 \<ParentDirectory\> \<TileList\>
* Mode 3: Single-Tile Mode
	* Run tile given in command line input. The input TileName should be a RaDecID (eg 3568m182)
	* **./icore\_wrapper\_executable** 1 \<ParentDirectory\> \<TileName\>

