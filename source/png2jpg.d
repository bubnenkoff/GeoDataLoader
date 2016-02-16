module png2jpg;
import std.stdio;
import std.path;
import std.string;
import std.file;
import derelict.freeimage.freeimage;

bool convertToJPG(string imageFullName)
{
	DerelictFI.load();
	string inputFile = imageFullName;
	string outputFile = imageFullName.replace(".png", ".jpg");
    const(char)* imgFullName = cast(const(char)*)(inputFile);
	auto bitmap = FreeImage_Load(FIF_PNG, imgFullName, FIF_JPEG);
	if(FreeImage_Save(FIF_JPEG, bitmap, cast(const(char)*)outputFile, 0))
		return true;
	else
		return false;
	
}