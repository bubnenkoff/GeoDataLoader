module parseconfig;

import std.file;
import std.string;
import std.datetime;
import std.path;
import std.stdio;
import std.exception;

import variantconfig;
import colorize;
import dbconnect;

Date currentdt;
static this()
{
	currentdt = cast(Date)(Clock.currTime()); // It's better to declarate globally
}


class Config
{
	string dbname;
	string dbuser;
	string dbpass;
	string dbhost;
	string dbport;
	string emsc_csem; 
	string usgs; 
	string geomagnetic_index;
	/////////////IMGs////////////////////
	string [] pagewithimgforparsing; // array of list IMG urls for parsing from config
	string allow_download; // load images to FS or no
	string interval_download;
	Date interval_start;
	Date interval_end;
	string _interval_end; // temp. getting `now` before converting it's to date


	string solarindex; // solar and geomagnetic index
	////ftp////
	string ftplocalpath;
	string ftplocalpath_shgm3;

	string emsc_csem_load;
	string usgs_load;
	string solarindex_load;
	string ftp_load;
	string ftp_shgm3_load;
	//string geomagneticURL_load;
	string nrlmry_load;
	string jmaimgs_load;
	string cwbimgs_load;
	string kalpana_load;
	string dgdindex_load;

	// archive URL sections. take urls from config
	string nrlmry_archiveURL_NW_Pacific;
	string nrlmry_archiveURL_NE_Pacific;
	string nrlmry_archiveURL_Europe;

	//plots
	string kakiokajma_load;
	string georotac_load;
	string nadisa_load;

	//for FTP
	string ftp_load_only_1_minuts;

	// grad reprojection
	string reprojection_allow;
	string reproject_imgs_start_folder;
	string remove_data_older_then_one_year;

	string checkImgsExists; // check images from DB exists on FS
	string rootImgsPath;
	string rootImgsPath_projected;

	string test_mode;
	string patter_loader; 

void parseconfig()
	{

			//getcwd do not return correct path if run from task shoulder
			string confpath = buildPath((thisExePath[0..((thisExePath.lastIndexOf("\\"))+1)]), "config.ini");
			//writefln(thisExePath[0..((thisExePath.lastIndexOf("\\"))+1)]); // get path without extention +1 is for getting last slash

			//string confpath = buildPath(thisExePath, "config.ini");
			if (!exists(confpath)) 
				{
					writeln("ERROR: config.ini do not exists");
				}
			auto config = VariantConfig(confpath);

				dbname = config["dbname"].toStr;
				dbuser = config["dbuser"].toStr;
				dbpass = config["dbpass"].toStr;
				dbhost = config["dbhost"].toStr;
				dbport = config["dbport"].toStr;
				emsc_csem = config["emsc_csem"].toStr;
				usgs = config["usgs"].toStr;
				geomagnetic_index = config["geomagnetic_index"].toStr;
				//////////////////////////IMGs//////////////////////////////////
				//Now we collect img-urls-page in array. Next we will check them and extract FULL links to images
				//Links here DO NOT include FULL imgs urls!!! Just URLs for PAGEs for parsing!
				////////////////////////////////////////////////////////////////
				// "" - default value if base value could not be parse!
				solarindex = config["solarindex"].toStr;

				ftplocalpath = config["ftplocalpath"].toStr;
				ftplocalpath_shgm3 = config["ftplocalpath_shgm3"].toStr;

				////// ON and OFF sectons
				emsc_csem_load = config["emsc_csem_load"].toStr;
				usgs_load = config["usgs_load"].toStr;
				solarindex_load = config["solarindex_load"].toStr;
				ftp_load = config["ftp_load"].toStr;
				ftp_shgm3_load = config["ftp_shgm3_load"].toStr;
				//this.geomagneticURL_load = config["geomagneticURL_load"].toStr;
				nrlmry_load = config["nrlmry_load"].toStr;
				jmaimgs_load = config["jmaimgs_load"].toStr;
				cwbimgs_load = config["cwbimgs_load"].toStr;
				kalpana_load = config["kalpana_load"].toStr;
				dgdindex_load = config["dgdindex_load"].toStr;

				kakiokajma_load = config["kakiokajma_load"].toStr;
				georotac_load = config["georotac_load"].toStr;
				nadisa_load = config["nadisa_load"].toStr;
				ftp_load_only_1_minuts = config["ftp_load_only_1_minuts"].toStr; //load FTP data only with 1 minute interval
				allow_download = config["allow_download"].toStr;
				interval_download = config["interval_download"].toStr; // future that allow load only date for specified date

				interval_start = Date.fromISOExtString(config["interval_start"].toStr);

					_interval_end = config["interval_end"].toStr; //temp
					if (_interval_end == "now")
					{
						interval_end = currentdt;
					}
					else
					{
						interval_end =  Date.fromISOExtString(_interval_end);						
					}

				// nrlmry arhive section
				//hardcoded above
				
				reprojection_allow = config["reprojection_allow"].toStr;
				reproject_imgs_start_folder = config["reproject_imgs_start_folder"].toStr;
				remove_data_older_then_one_year = config["remove_data_older_then_one_year"].toStr;
				
				checkImgsExists = config["checkImgsExists"].toStr;

				test_mode = config["test_mode"].toStr; // load only ONE copy of each source. Use Group By request
				patter_loader = config["patter_loader"].toStr; // generate pattern for loading images

				rootImgsPath = config["rootImgsPath"].toStr;
					if (!(rootImgsPath.endsWith("\\"))) // if forget slashes in config building path will be failed
					{
						rootImgsPath = rootImgsPath ~ "\\";
					}

					if(!rootImgsPath.exists)
					{
						writefln("Path from config do not exists: ", rootImgsPath);
						writeln("Please create it before continue");
						string exceptionText = format("Path from config do not exists: %s", rootImgsPath);
						throw new Exception(exceptionText);

					}
	

				rootImgsPath_projected = config["rootImgsPath_projected"].toStr;
					if (!(rootImgsPath_projected.endsWith("\\"))) // if forget slashes in config building path will be failed
					{
						rootImgsPath_projected = rootImgsPath_projected ~ "\\";
					}

					if(!rootImgsPath_projected.exists)
					{
						writeln("Path from config do not exists: ", rootImgsPath_projected);
						writeln("Please create it before continue");
						string exceptionText = format("Path from config do not exists: %s", rootImgsPath_projected);
						throw new Exception(exceptionText);
						
					}

				

	}





}