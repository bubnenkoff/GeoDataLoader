module seismodownload;

import parseconfig;

import std.file;
import std.string;
import std.datetime;
import std.path;
import std.net.curl;
import std.stdio;
import std.xml;
import std.conv;

static import dom = arsd.dom; //to prevent name collision with xml
import colorize;



struct EQ
{
	string region; //title
	string lat;
	string lon;
	string depth;
	string magnitude;
	string datetime; //accomulate date + time, but we need split them
	string date;
	string time;
	string type; // name of source
}


class SeismoDownload
{
	//string emsc_csem;
	//string usgs;
	Config config;

	string pagecontent;
	
	EQ[] eqs;
	EQ eq;

	this(Config config)
	{
		this.config = config;
	}
	
	void parsecsem()
	{
	
		try
		{
			writeln("[Earth Quakes]");
			pagecontent = get(config.emsc_csem).idup;
			//writeln(pagecontent);

			//check(pagecontent);
			auto pageDOM = new DocumentParser(pagecontent);
			pageDOM.onStartTag["item"] = (ElementParser pageDOM)
			{
	
				pageDOM.onEndTag["title"] = (in Element e) { eq.region = e.text(); }; //region
				pageDOM.onEndTag["geo:lat"] = (in Element e) { eq.lat = e.text(); }; //geo:lat
				pageDOM.onEndTag["geo:long"] = (in Element e) { eq.lon = e.text(); }; //geo:lon
				pageDOM.onEndTag["emsc:depth"] = (in Element e) { eq.depth = e.text(); };
				pageDOM.onEndTag["emsc:magnitude"] = (in Element e) { eq.magnitude = e.text(); };
				pageDOM.onEndTag["emsc:time"] = (in Element e) { eq.datetime = e.text(); };

				pageDOM.parse();

				//Filtering Data. Removing crap data, Removing whitespaces.
				// WARNING: some data may include apostrophe like O'Chily we need to remove it!!!  
				eq.region = strip(eq.region[8..$].replace("'", " "));
				eq.lat = strip(eq.lat);
				eq.lon = strip(eq.lon);
				eq.depth = strip(chomp(eq.depth, "f"));
				eq.magnitude = strip(eq.magnitude[2..$]);
				eq.date = strip(chomp(eq.datetime, "UTC").split(" ")[0]);
				eq.time = strip(chomp(eq.datetime, "UTC").split(" ")[1]);
				eq.type = "emsc-csem.org";
				
				eqs ~= eq;

			};
		
			pageDOM.parse();	

		}
		
		catch (Exception msg)
		{
			cwriteln("ERROR: parsecsem section".color(fg.red));
		}


	}
	
		void parseusgs()
		{
			try
			{
				//string url = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.csv";
				string url = config.usgs;
				
				foreach(line; url.byLine())
				{
					if (to!string((line[0]))== "t") continue; // stupid way to check header
					//writeln(line);
					//readln();
					eq.date = ((to!string(line)).split(",")[0]).replace("T", " ").replace("Z", "").replace("\"", "").split(" ")[0];
					eq.time = ((to!string(line)).split(",")[0]).replace("T", " ").replace("Z", "").replace("\"", "").split(" ")[1];
					eq.lat = (to!string(line)).split(",")[1];
					eq.lon = (to!string(line)).split(",")[2];
					eq.depth = (to!string(line)).split(",")[3];
					eq.magnitude = (to!string(line)).split(",")[4];
					eq.region = (to!string(line).replace("'", "").replace(`"`, ``)).split(",")[13];
					eq.type = "earthquake.usgs.gov";

					//writeln(eq.date);
					//writeln(eq.time);

			

					eqs ~= eq;
				}
				
				/*
				writeln(eq.region);
				writeln(eq.lat);
				writeln(eq.lon);
				writeln(eq.depth);
				writeln(eq.magnitude);
				writeln(eq.time);
				*/

			}

			catch (Exception msg)
			{
				cwriteln("ERROR: parseusgs section".color(fg.red));
			}
		}

}