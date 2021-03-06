### GryffinEngine v.0.2.4 ###
 * Make the Virtual FileSystem regard Assets as static files that cannot be overwritten.
   Asset files are now first-class citizens in the virtual filesystem.
 * Make the NativeFileSystem class use the same "virtual" filesystem schema as the JavaScript implementation.
 * Change the `VirtualVolume` file format in such a way that it can be loaded in pieces, instead of all at once.

 * Create a new "entry-type" for the VirtualVolume class, for "linker" files, which just point to files that are neither Assets,
   nor part of that Virtual FileSystem.

 * Create new `RegEx` class, which uses `EReg`, but behaves like a Python regular expression.

 * Make the FileSystem use the **actual** filesystem API, on the JS target

 * Design a file format for the VirtualVolume that allows it to index it's contents and load only what is requested
