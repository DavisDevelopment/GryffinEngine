package gryffin.fquery.selectors;

enum FileDesc {
	FAny;
	FGeneric(name : String);
	FName(name : String);
	FChildOf(parent_description:FileDesc, child_description:FileDesc);
	FHasExtension(general_description:FileDesc, extension:String);

	FBlock(set : Array<FileDesc>);
}