### GryffinEngine v.0.2.3 ###
#### Goals ####


##### General Changes #####
 * Delete legacy packages that are no longer in use
   * physics^
   * shaders^

 * Delete classes that have been abandoned
   * display.Worker^
   * display.Image^
   * display.ImageFrame^
   * display.SpriteSheetAnimation^

---------------------------------------------------------------------------------------------------------------------

 * Make Selection class abstract
   * allow array access on selection
   * allow implicit casting on selection
     - implicit cast to what is now it's underlying type: `ISelection`^
     - implicit cast to `Array<`*`Entity`*`>`^
     - implicit cast to `String`^

     - implicit cast *from* `ISelection`^
     - implicit cast *from* `String`^
     - implicit cast *from* `Array<`*`Entity`*`>`^
   * allow addition of multiple selections^
   * allow subtraction of multiple selections^
   * allow addition of `String` + `Selection`^
   * allow subtraction of `String` - `Selection`^

---------------------------------------------------------------------------------------------------------------------

 * Make new `PixelMask` class which reads pixel colors in *the* most efficient way possible
 * Make new `Texture` class which renders bitmap images lazily via the `Buffer` class

 * Make new `Modal` class in the `gryffin.ui` package, for creating semi-transparent overlays


##### Platform-Specific Changes #####
 * Make the FileSystem use the **actual** filesystem API, on the JS target
