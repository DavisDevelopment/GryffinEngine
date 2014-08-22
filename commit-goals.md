### GryffinEngine v.0.2.3 ###
#### Goals ####


##### General Changes #####
 * Delete legacy packages that are no longer in use
   * physics *
   * shaders *

 * Delete classes that have been abandoned
   * display.Worker *
   * display.Image *
   * display.ImageFrame *
   * display.SpriteSheetAnimation *

---------------------------------------------------------------------------------------------------------------------

 * Make the NativeMap class abstract


##### Platform-Specific Changes #####
 * Make the FileSystem use the *actual* filesystem API, on the JS target