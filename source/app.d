import std.stdio;
import std.file;
import std.string;
import std.array;
import std.conv;
import std.path;
import std.range;
import std.format;
import std.algorithm;
import std.xml;
import std.regex;
import std.getopt;
import std.datetime;
import std.parallelism;
import std.zip;
import std.regex;
import core.thread;

import colorize;

static import dom = arsd.dom; //to prevent name collision with xml

import vibe.core.log;
import vibe.http.client;
import vibe.stream.operations;
import vibe.http.status;

import reproj; // for gdal reprojection
import dbconnect;
import dbinsert;
import parseconfig;
import seismodownload;
import imagedownload;
import utils; // checkURL 
import dbcheck; // checkURL 

import imgparser;
import georotac;
import nadisa;
import geomagnetic_index;
import kakioka;
import solarindex;
import ftplogs;

//Globals
Date currentdt;
static this()
{
	currentdt = cast(Date)(Clock.currTime()); // It's better to declarate globally
}

void main(string[] args)
{

	string appName = "-=GeoDataLoader App v.1.2=-\n".color(fg.green);
	cwriteln(appName);
	core.thread.Thread.sleep( dur!("seconds")(2) );


	try
	{
		writeln("Checking Internet connection...");
		int i;
		while (i <= 5)
		{
			if(checkLink("http://example.org"))
			{
				cwritefln("Internet connection OK".color(fg.green));
				break;
			}
			else
			{
				cwritefln("Attempt connect to Internet: %s ".color(fg.red), i);
				i++;
				core.thread.Thread.sleep( dur!("seconds")(1) );
			}
		}
		if (i == 6)  // i at end of while loop is 6, NOT 5
			{
				writeln("Can't connect to Internet. Exit");
				writeln("Check Internet connection and run Application again");
				return; // exit
			}

		//We need 2 instance for start: config and DBConnect, or App can't run
		//Then we will use them everywhere
		auto config = new Config();
			config.parseconfig();	


		core.thread.Thread.sleep( dur!("seconds")(1) );
		auto db = new DBConnect(config);
		DataBaseInsert databaseinsert = new DataBaseInsert(config, db);

		if(config.checkImgsExists == "true")	// checking if imgs from DB exists on FS
		{
			auto dbwork = new DBWork (databaseinsert, db, config);
			dbwork.checkImgsExists();
		}	

		if (config.georotac_load == "true")
		{
			auto georotac = new georotac(db, config);
			georotac.getPlots();
		}

		if(config.nadisa_load == "true")
		{
			auto nadisa = new Nadisa(db, config);
			nadisa.getPlots();
		}
		

		core.thread.Thread.sleep( dur!("seconds")(1) );
		if(config.emsc_csem_load == "true")
			{
				if (checkLink(config.emsc_csem)) // if link in config is alive processing it
				{
					auto seismodownload = new SeismoDownload(config);
					seismodownload.parsecsem();
					databaseinsert.EQInsert(seismodownload.eqs); 
				}
				else 
				cwritefln("Look like link is dead: %s", config.emsc_csem.color(fg.red));
			}
		
			if(config.usgs_load == "true")
			{
				if (checkLink(config.usgs)) // if link in config is alive processing it
				{
					//auto db = new DBConnect(config); // already exists
					auto seismodownload = new SeismoDownload(config);
					seismodownload.parseusgs();
					databaseinsert.EQInsert(seismodownload.eqs);
					//scope(exit) db.stmt.close(); //now we can close connection
				}
				else 
				cwritefln("Look like link is dead: %s", config.emsc_csem.color(fg.red));
			}

		if(config.kakiokajma_load == "true") // in DB it's --> tellurika
		{
			auto kakioka = new Kakiokajma(databaseinsert, db);
			kakioka.kakiokajma();
		}

		if(config.dgdindex_load == "true") // name in SQL: geomagnetic_index
		{
			if (config.geomagnetic_index) // DO NOT work with FTP! old version: checkLink(config.geomagnetic_index)
			{
				auto geomagnetic_index = new geomagnetic_index(databaseinsert, config, db);
				geomagnetic_index.parse();
			}
			else 
				cwritefln("Look like link is dead: %s", config.geomagnetic_index.color(fg.red));
		}
		
		if(config.solarindex_load == "true")
		{
			auto solarindex = new SolarIndex(databaseinsert, config, db);
			solarindex.parse();
			core.thread.Thread.sleep( dur!("seconds")(1) );
		}



		if(config.ftp_load == "true")
		{
			auto ftplogs2db = new FTP(databaseinsert, config, db);
			ftplogs2db.getLogsList(config.ftplocalpath);
		}

		if(config.ftp_shgm3_load == "true")
		{
			auto ftplogs2db = new FTP(databaseinsert, config, db);
			ftplogs2db.getLogsList(config.ftplocalpath_shgm3);
		}


		//if one of the config sections is true, create instance of getimgfulllinks that include other small section
		// and instance of IMGDownload
		core.thread.Thread.sleep( dur!("msecs")(1000) );
		if (config.nrlmry_load == "true" || config.jmaimgs_load == "true" || config.cwbimgs_load == "true" || config.kalpana_load == "true")
		{
				auto getimgfulllinks = new GetImgFullLinks(databaseinsert, config, db); //2 instance 

				if(config.nrlmry_load == "true")
					getimgfulllinks.nrlmrynavymil();

				if(config.jmaimgs_load == "true")
					getimgfulllinks.jmaimgs();
				
				if(config.cwbimgs_load == "true")	
					getimgfulllinks.cwbimgs();

				if(config.kalpana_load == "true")
					getimgfulllinks.kalpana();

		}

		else
			writeln("Images DO NOT load because all sections in config.ini are set to false");

		// loading IMGs to DB and DB2FS are separate sections
		if(config.allow_download == "true")
		{
			
			Date dateStart;
			Date dateEnd;
			writeln("Allow download == true");
			if(config.interval_download == "true" && config.interval_end != currentdt) // download interval
			{
				dateStart = config.interval_start;
				dateEnd = config.interval_end;
			}
			else // download all
			{
				
				if(config.interval_end == currentdt)
				{
					dateStart = config.interval_start;
					dateEnd = currentdt;
				}
				else
				{
					dateStart = Date.fromISOExtString("2015-01-01");
					dateEnd = config.interval_end;
				}
				
			}

			writeln("Loading images from DB to FS");
			core.thread.Thread.sleep(dur!("seconds")(1));
			
			auto imgdownload = new IMGDownload (databaseinsert, db, config);

			imgdownload.imagedownload(dateStart, dateEnd); 
			

		}


		if(config.reprojection_allow == "true")
		{
			
			writeln("Georeference images from DB");
			core.thread.Thread.sleep(dur!("seconds")(1));
			auto imgdownload = new IMGDownload (databaseinsert, db, config);

			Date dateStart = config.interval_start;
			Date dateEnd = config.interval_end;

			imgdownload.runReferenceDownloadedImgs(dateStart, dateEnd); 
			
		}


		if(config.patter_loader == "true")
		{
			writeln("Loading images by pattern");
			PatternLoader patternloader	= new PatternLoader(databaseinsert, db, config);
		}		


		scope(exit) db.stmt.close(); //now we can close connection
		cwritefln("[Complete!]".color(fg.yellow));
		core.thread.Thread.sleep( dur!("seconds")(10));
	}


	catch(Exception e)
	{
		writeln(e.msg);
	}

}










