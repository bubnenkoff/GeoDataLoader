import std.stdio;
import std.path;
import std.file;
import std.conv;
import std.algorithm;
import std.array;
import std.string;
import std.process;

import gdallookup;
import dbconnect;
import parseconfig;
import png2jpg;
import utils; // checkURL, makeDir


class GDALProcessing
{
//before we read dir from config, but now we get every FullImageName after downloading and process it 
	DBConnect db;
	
	this(DBConnect db)
	{
		this.db = db;
	}
	
	//reprojectedImageFullName need to GET PATH where to locate it! It's much easier then calculate it.
	string gdalProcessFile(string imageFullName, string reprojectedImageFullName, string myalias) 
	{
		
		if (!imageFullName.exists)
		{
			writeln("File from DB do not exists on FS: ", imageFullName);
			readln;
		}

		if (imageFullName.getSize/1024 < 15) //if image less then 25KB than remove it
			imageFullName.remove;


		//check if dir for reprojected image exists, if not create it
		try
		{
			if (!reprojectedImageFullName.dirName.exists)
				makeDir(reprojectedImageFullName.dirName); // stand alone function

			writeln("dir created: ", reprojectedImageFullName.dirName);

			//do same for temp folder
			try
			{
				string temp_folder = buildPath(reprojectedImageFullName.dirName, "temp");
				makeDir(temp_folder);			
			}
			catch(Exception e)
			{
				writeln("Can't create temp dir!");
			}

		}
		catch(Exception e)
		{
			writeln("Can't create dir for reprojected image:");
			writeln(reprojectedImageFullName.dirName);
			writeln(e.msg);
		}


		string gdalfolder = which("gdalwarp.exe"); //return folder that consist gdalwarp.exe file
		string gdalpluginpath = (gdalfolder ~ `gdal\plugins\`); //for JP2 support
			
			// before calling we should set PATH to current CMD session like: SET PATH=%PATH%;
			// GDAL_DATA Need to be specified too! --> GDAL\gdal-data
			// better to call both command with --config key like:
			// gdalwarp --config GDAL_DATA "D:/my/gdal/data"


			// GDAL_DATA folder include metadatas that needed for processing
			string gdal_data_folder = buildPath(gdalfolder, "gdal-data");
			if (!exists(gdal_data_folder))
			{
				writeln("[ERROR] GDAL-DATA do not exists in GDAL folder. Can't continue.");
				return null;
			}

			string gdalFullPath = buildPath(gdalfolder, `gdal_translate.exe`);

			if(!buildPath(getcwd, "xdata").exists)
			{
				writeln("xdata do not exists in GeoDataLoader dir");
				writeln("This folder include information for spatial referencing and should include folders named as aliases in DB");
			}


			if(!buildPath(getcwd, "xdata", myalias).exists)
			{
				string path = buildPath(getcwd, "xdata", myalias);
				writeln("Path do not exists: ", path);
				writefln("Spatial referencing is not possible");
				writeln("This folder include information for spatial referencing and should include folders named as aliases in DB");
				readln;
			}

			string pointFile = buildPath(getcwd, "xdata", myalias, "points.txt");
			string proj_params_gdal_translate = buildPath(getcwd, "xdata", myalias, "proj_params_gdal_translate.txt");
			string proj_params_gdalwarp = buildPath(getcwd, "xdata", myalias, "proj_params_gdalwarp.txt");


			if(!pointFile.exists || !proj_params_gdal_translate.exists || !proj_params_gdalwarp.exists)
			{	
				if(!pointFile.exists)
					writeln("Do not exists: ", pointFile);

				if(!proj_params_gdal_translate.exists)
					writeln("Do not exists: ", proj_params_gdal_translate);

				if(!proj_params_gdalwarp.exists)
					writeln("Do not exists: ", proj_params_gdalwarp);

				readln;
			}
			
			File file = File(pointFile, "r"); 
			string contentWithGsp = to!string(file.byLine.map!(a => "-gcp " ~ a ~ " ").joiner);
			string projParamsFileContent = proj_params_gdal_translate.readText();
			string gdal_warp_params_content = proj_params_gdalwarp.readText();

			//it's better to place _temp files in temp folder


			string outputImageName_temp = buildPath(reprojectedImageFullName.dirName, "temp",  reprojectedImageFullName.baseName);
				writeln("outputImageName_temp will be: ", outputImageName_temp);				
				writeln("reprojected image location will be: ", outputImageName_temp);

			// WARINING: -of JP2OpenJPEG on PNG files cause WRONG spatial reference
			string gdal_translate_string_for_cmd = `"` ~ gdalFullPath  ~ `" --config GDAL_DATA "` ~ gdal_data_folder ~ `" ` ~ projParamsFileContent  ~ " " ~ contentWithGsp ~ " " ~ imageFullName ~ " " ~ outputImageName_temp; 
			string gdalwarp_command_for_cmd = `"` ~ buildPath(gdalfolder, "gdalwarp.exe") ~ `"` ~ `  --config GDAL_DATA "` ~ gdal_data_folder ~ `" ` ~ gdal_warp_params_content ~ " " ~ outputImageName_temp ~ " " ~ reprojectedImageFullName ~ " -order 1";


			writeln("----------gdal translate:--------");
			writeln(gdal_translate_string_for_cmd);
			writeln("---------------------------------");
			writeln("------------gdal warp:-----------");
			writeln(gdalwarp_command_for_cmd);
			writeln("---------------------------------");
			readln;
			

			auto gdal_plugin_Pid = spawnShell(`SET PATH = "` ~ gdalpluginpath ~ `"`); //JP2 support



			//GDAL Translate start
			try
			{
				auto gdal_translate_Pid = spawnShell(gdal_translate_string_for_cmd);
				if(wait(gdal_translate_Pid) !=0)
				{
					writeln("[ERROR] Gdal Translate failed");
					return null;
				}
				else
					writeln("gdal translate DONE");
			}

			catch(Exception e)
			{
				writeln("Error in GDAL Translate section");
			}

			try
			{
				//GDAL Warp start
				auto gdal_warp_Pid = spawnShell(gdalwarp_command_for_cmd);
				if(wait(gdal_warp_Pid) !=0)
				{
					writeln("[ERROR] Gdal Warp failed");
					return null;
				}
			}

			catch(Exception e)
			{
				writeln("Error in GDAL Warp section");
			}


//------------------------------------------------------
			try
			{
				foreach (name; dirEntries(outputImageName_temp.dirName, SpanMode.depth))
				{
				 remove(name);
				}
			}

			catch(Exception e)
			{
				writeln("Can't clean temp dir: ", outputImageName_temp);
				writeln(e.msg);
			}

			writeln("reprojectedImageFullName return: ", reprojectedImageFullName);
			return reprojectedImageFullName.baseName;




	}

}

