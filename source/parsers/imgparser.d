module imgparser;

import std.stdio;
import std.algorithm;
import std.file;
import std.string;
import std.array;
import std.conv;
import std.path;
import std.range;
import std.datetime;
import std.net.curl;

static import dom = arsd.dom; //to prevent name collision with xml
import utils; // checkURL 
import dbconnect;
import dbinsert;
import parseconfig;
import colorize;


class GetImgFullLinks
{
	
	DataBaseInsert databaseinsert;
	Config config; // we need it's because basepath of IMG link are getting from config
	DBConnect db;

	string [] pagewithimgforparsing; // list of pages for extractring images from them
	string [] fullimgurl; // ALL links from NRL section. (I hope). Now only NRL section! 
	string [] imgnames;

	this (DataBaseInsert databaseinsert, Config config, DBConnect db) // instanse of class Parse and GetImgLinks
	{
		this.databaseinsert = databaseinsert;
		this.config = config;
		this.db = db;

		writefln("[Exctacting images from pages]");
		writefln("[Checking pages]");
		foreach (url; config.pagewithimgforparsing)
			{
				// DO NOT FORGET UNCOMMENT!
				//  comment to prevent link check 
			
				if(checkLink(url))// we need to check if all links are alive and correct!
					this.pagewithimgforparsing ~=url;
				
				else
				{
					cwriteln("Next links in config.ini look like unreachable:".color(fg.red));
					writeln(url);
				}
				
				
			}

	}


	// here is another page where IMG storage. And we do not need to send post
	void nrlmrynavymil()
	{
			writeln("Loading NRL2 sections to DB");
		try
		{
			writeln("Processing http://www.nrlmry.navy.mil (list [] of URLs)");

			string [] imgfullurls;
			string [] imgnames;

			string [] baseurls = ["http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/Europe/Overview/vis_ir_background/meteo8/",
									"http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/Europe/Overview/ir_color/meteo8/",
									"http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/Europe/Overview/ir_images/meteo8/",
									"http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/Europe/Overview/vis_images/meteo8/",
									"http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/SouthAmerica/Overview/vis_ir_background/goes/",
									"http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/SouthAmerica/Overview/vis_ir_background/goes_lowcloud/",
									"http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/Global/Overview/ir/",
									"http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/NW_Pacific/Overview/vis_ir_background/gms_6/",
									"http://www.nrlmry.navy.mil/nexdat/CONUS/focus_regions/NW_Pacific/Overview/vis_ir_background/gms_6_lowcloud/",
									"http://www.nrlmry.navy.mil/archdat/global/stitched/ir/",
									"http://www.nrlmry.navy.mil/archdat/global/stitched/vis/"];

			foreach(baseurl;baseurls)
			{
					if(!baseurl.endsWith("/")) 
				
				baseurl = baseurl ~ "/";
				writeln("Processing: ", baseurl);

				string content = get(baseurl).idup;
				auto document = new dom.Document(content);

				//writeln(baseurl);
			    foreach(row; document.querySelectorAll(`a[href]`))
			    {
			    	if(!row.href.endsWith(".jpg")) continue; // skip not jpg files
			    	if(row.href.canFind("LATEST")) continue; // skip LATEST
			    	if(row.href.canFind("CURRENT")) continue; // skip LATEST
			    	imgfullurls ~= baseurl ~ row.href;
			    	imgnames ~= row.href;
			    	//writefln(baseurl ~ row.href);
			    }
			 }
		
			databaseinsert.IMGsInsert(imgfullurls, imgnames);
		}
		
		catch(Exception e)	
		{
			writeln("Error processing nrlmrynavymil");
			writeln(e.msg);
		}
	}	



	// on jma page we can't parse html to get all links (it's gen by js)
	// so we will use bruteforce
	void jmaimgs()
	{
		writeln("Loading JMA section to DB");
		try
		{
			string [] imgurls; //all urls
			string [] aliveimgurls; //all urls
			string [] imgnames; //all urls
			//string basepart = "http://www.jma.go.jp/en/gms/imgs/5/infrared/0/";
			string basepart_vis = "http://www.jma.go.jp/en/gms/imgs_c/0/visible/0/";
			string basepart_ir = "http://www.jma.go.jp/en/gms/imgs_c/0/infrared/0/";


			//string basepart = "http://www.jma.go.jp/en/gms/imgs/5/infrared/0/201502121615-00.png";
			DateTime dt = cast(DateTime)(Clock.currTime - 4.hours);
			string dtformat = dt.toISOString.replace("T", "")[0 .. 10]; //2015 02 12 16
															   			//2015 02 12 16 15-00.png
			//string fullurl = basepart ~ dtformat ~ "00-00.png";
			
			imgurls ~= basepart_vis ~ dtformat ~ "00-00.png"; 
			imgurls ~= basepart_ir ~ dtformat ~ "00-00.png";

			imgurls ~= basepart_vis ~ dtformat ~ "30-00.png"; 
			imgurls ~= basepart_ir ~ dtformat ~ "30-00.png";			

			writeln(imgurls.length);

			//ok all links in array, now we need to check them if they are alive
			foreach(i, url;imgurls)
			{
				if(checkLink(url))
				{
					aliveimgurls ~= url;
					imgnames ~= url[url.lastIndexOf("/")+1 .. $]; // extract name from url
				}
			}


			databaseinsert.IMGsInsert(aliveimgurls, imgnames);
		}

		catch (Exception e)
		{
			writeln("Error in http://www.jma.go.jp");
			writeln(e.msg);
		}

	}


	// url hardcoded. becouse page gen by js
	void cwbimgs()
	{
		writeln("Loading CWB section to DB");
		try
		{
			string [] imgurls; //all urls
			string [] aliveimgurls; //all urls
			string [] imgnames; //all urls

			string basepart_vis = "http://www.cwb.gov.tw/V7/observe/satellite/Data/HSUP/"; // vis
			string basepart_rgb = "http://www.cwb.gov.tw/V7/observe/satellite/Data/HSXO/"; // rgb
			string basepart_enh = "http://www.cwb.gov.tw/V7/observe/satellite/Data/HS5Q/"; // enh
			string basepart_ir = "http://www.cwb.gov.tw/V7/observe/satellite/Data/HS5O/"; // ir

			//http://www.cwb.gov.tw/V7/observe/satellite/Data/HS5O/HS5O-2015-02-14-20-00.jpg
			DateTime dt = cast(DateTime)(Clock.currTime + 4.hours);
			//string dtformat = dt.toISOString.replace("T", "")[0 .. 10]; //2015021216

			// dirty hack!
			string dtformat = format(to!string(dt.year) ~ "-" ~ (dt.toISOExtString.split("-")[1]) 
				~ "-" ~ to!string(dt.toISOString[6..8]) ~ "-" ~ (to!string(dt.hour)).replace("0","00").replace("000","00") ); //HACK! to get two digits date
			//writeln(dtformat);
			//writeln(();
			//writeln("-----");
			

			//string fullurl = basepart ~ dtformat ~ "00-00.png";
			
			imgurls ~= basepart_vis ~"HSUP-" ~ dtformat ~ "-00.jpg"; 
			imgurls ~= basepart_vis ~"HSUP-" ~ dtformat ~ "-10.jpg"; 
			imgurls ~= basepart_vis ~"HSUP-" ~ dtformat ~ "-20.jpg"; 
			imgurls ~= basepart_vis ~"HSUP-" ~ dtformat ~ "-30.jpg"; 
			imgurls ~= basepart_vis ~"HSUP-" ~ dtformat ~ "-40.jpg"; 
			imgurls ~= basepart_vis ~"HSUP-" ~ dtformat ~ "-50.jpg"; 

			imgurls ~= basepart_rgb ~"HSXO-" ~ dtformat ~ "-00.jpg"; 
			imgurls ~= basepart_rgb ~"HSXO-" ~ dtformat ~ "-10.jpg"; 
			imgurls ~= basepart_rgb ~"HSXO-" ~ dtformat ~ "-20.jpg"; 
			imgurls ~= basepart_rgb ~"HSXO-" ~ dtformat ~ "-30.jpg"; 
			imgurls ~= basepart_rgb ~"HSXO-" ~ dtformat ~ "-40.jpg"; 
			imgurls ~= basepart_rgb ~"HSXO-" ~ dtformat ~ "-50.jpg"; 

			imgurls ~= basepart_enh ~"HS5Q-" ~ dtformat ~ "-00.jpg"; 
			imgurls ~= basepart_enh ~"HS5Q-" ~ dtformat ~ "-10.jpg"; 
			imgurls ~= basepart_enh ~"HS5Q-" ~ dtformat ~ "-20.jpg"; 
			imgurls ~= basepart_enh ~"HS5Q-" ~ dtformat ~ "-30.jpg"; 
			imgurls ~= basepart_enh ~"HS5Q-" ~ dtformat ~ "-40.jpg"; 
			imgurls ~= basepart_enh ~"HS5Q-" ~ dtformat ~ "-50.jpg"; 		

			imgurls ~= basepart_ir ~"HS5O-" ~ dtformat ~ "-00.jpg"; 
			imgurls ~= basepart_ir ~"HS5O-" ~ dtformat ~ "-10.jpg"; 
			imgurls ~= basepart_ir ~"HS5O-" ~ dtformat ~ "-20.jpg"; 
			imgurls ~= basepart_ir ~"HS5O-" ~ dtformat ~ "-30.jpg"; 
			imgurls ~= basepart_ir ~"HS5O-" ~ dtformat ~ "-40.jpg"; 
			imgurls ~= basepart_ir ~"HS5O-" ~ dtformat ~ "-50.jpg"; 	


			writeln(imgurls.length);
			writefln(basepart_rgb);
			//ok all links in array, now we need to check them if they are alive
			foreach(i, url;imgurls)
			{
				if(checkLink(url))
				{
					aliveimgurls ~= url;
					imgnames ~= url[url.lastIndexOf("/")+1 .. $]; // extract name from url
				}
			}
			writeln(aliveimgurls.length);

			databaseinsert.IMGsInsert(aliveimgurls, imgnames);
		}

		catch(Exception e)
		{
			writeln("Error in cwbimgs section");
			writeln(e.msg);
		}

	}

	// to prevent very big insert operation to DB we will skip latest 2 month
	void kalpana()
	{
		writeln("Loading KALPANA section to DB");
		try
		{
			string baseurl = "http://202.54.31.45/archive/KALPANA-1/";
			// if parsed part is DO NOT start with "/" and END with "/"
			// it's right link

			// ?C=N;O=D <- do not need
			// ?C=M;O=A <- do not need
			// ?C=S;O=A <- do not need
			// ?C=D;O=A <- do not need
			// /archive/ <- do not need
			// ASIA-SECTOR/
			// FULL-DISK/
			// NORTHEAST-SECTOR/
			// NORTHWEST-SECTOR/
			// PRODUCTS/

			if(!baseurl.endsWith("/")) 
				baseurl = baseurl ~ "/";

			string content = get(baseurl).idup;
			auto document = new dom.Document(content);
			string [] urls;
			string currentyear = to!string((cast(DateTime)(Clock.currTime())).year); // we need to put to DB only current year

		    foreach(row; document.querySelectorAll(`a[href]`))
		    {
			    	// skip some dirs
			    	if(row.href.canFind("PRODUCTS")) continue; // skip PRODUCTION folder
			    	if(row.href.canFind("FULL-DISK")) continue; // skip PRODUCTION folder
			    	if(row.href.canFind("ISOTHERM")) continue; // skip PRODUCTION folder
			    	if(row.href.canFind("WATERVAPOR")) continue; // skip PRODUCTION folder
		    	if(!row.href.startsWith('/') && row.href.endsWith('/'))
		    	{
		    		string content1 = get(baseurl ~ row.href).idup;
		    		auto document1 = new dom.Document(content1);
		    		//writeln(content1);
					// here is 2 level folding

					foreach(row1; document1.querySelectorAll(`a[href]`))
				    {
				    		// skip some dirs
				    		if(row.href.canFind("COLOR")) continue; // skip
				    		if(row.href.canFind("WATERVAPOR")) continue; // skip
				    		if(row.href.canFind("ISOTHERM")) continue; 
			    			if(row.href.canFind("WATERVAPOR")) continue; // skip PRODUCTION folder
				    	if(!row1.href.startsWith('/') && row1.href.endsWith('/'))
				    	{
			    			urls ~= baseurl ~ row.href ~ row1.href;
				    	}

				    }

		    	}
		    }
		    
		    DateTime currentdt = cast(Date)(Clock.currTime());
		    string lastyear = to!string(currentdt.roll!"years"(-1))[0..4];
		    foreach(url;urls)
		    {
		    	
					if(url.canFind("WATERVAPOR")) continue; // skip
					if(url.canFind("ISOTHERM")) continue; 
		    	// it's better to past per folder, then collect all data. All data collection take too long time
		    	string [] fullurlimgs;
				string [] imgnames;
		    	writeln(url);
		    	string pagecontent = get(url).idup;
		    	auto page = new dom.Document(pagecontent);
		    	foreach (p; page.querySelectorAll(`a[href]`))
		    	{
		    		// we should skip name of base folders, like: /archive/KALPANA-1/ASIA-SECTOR/
		    		// idk why, but they are include in list of files
		    		if (p.href.endsWith("/"))	continue;
		    		if (!canFind(p.href, "jpg")) continue;
		    		if (canFind(p.href, lastyear)) continue;
		    			// to prevent to big date we will add to DB date for this year

		    		fullurlimgs ~= url ~ p.href;
		    		imgnames ~= p.href;
		    
		    	}
		    	databaseinsert.IMGsInsert(fullurlimgs, imgnames);
		    	//writefln("%s files was parsed in this section", to!string(fullurlimgs.length));
		    }
		}

		catch(Exception e)
		{
			writeln("Error in kalpana section");
			writeln(e.msg);
		}	
		    
	}


}
