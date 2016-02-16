module nadisa;

import std.datetime;
import std.net.curl;
import std.stdio;
import std.file;
import std.path;
import std.conv;
import std.array;
import std.string;
import variantconfig;
import parseconfig;
import dbconnect;
import dbinsert;
import utils;
static import dom = arsd.dom; //to prevent name collision with xml

class Nadisa // ---> gravitacion_data
{
	DBConnect db;
	Config config;
	
	this(DBConnect db, Config config)
	{
		this.db = db;
		this.config = config;
	}

	void getPlots()
	{
		try
		{
			// http://nadisa.org/lab2/3-150118-150201.jpg
			string baseurl = "http://nadisa.org/lab2/3-";
			writeln("Loading Nadisa");
			string confpath = buildPath((thisExePath[0..((thisExePath.lastIndexOf("\\"))+1)]), "url2path.ini");
			auto pathconfig = VariantConfig(confpath);

			string currentdt = to!string((cast(Date)(Clock.currTime())).toISOString);				

			string dt_14 = to!string((cast(Date)(Clock.currTime()) - 14.days).toISOString)[2..$];	
			string dt_30 = to!string((cast(Date)(Clock.currTime()) - 30.days).toISOString)[2..$];	

			string url_14 = baseurl ~ dt_14 ~ "-" ~ currentdt[2..$] ~ ".jpg";
			string url_30 = baseurl ~ dt_30 ~ "-" ~ currentdt[2..$] ~ ".jpg";

			string nadisa_14  = pathconfig["nadisa_14"].toStr;
			string nadisa_30  = pathconfig["nadisa_30"].toStr;

			//writeln(currentdt[2..$]);

			//writeln(url_30);
			writeln("example of data that we are trying to download: ");
			writeln(url_14, " ", nadisa_14 ~ currentdt ~ ".jpg"); // 
			download(url_14, nadisa_14 ~ currentdt ~ ".jpg");
				//if((url_14, nadisa_14 ~ currentdt ~ ".jpg").getSize/1000 < 9) (url_14, nadisa_14 ~ currentdt ~ ".jpg").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".gravitacion_data (file, date_start, date_end, status, type) VALUES ('" ~ currentdt ~ ".jpg', " ~ dt_14 ~ " ," ~ currentdt ~ ", 'DONE', 'nadisa_14')");
			//db.stmt.executeUpdate("INSERT IGNORE INTO test.Nadisa (name, status) VALUES ('" ~ currentdt ~ "', '" ~ dt_1 ~"', '" ~ dt_1 ~ ".png', '" ~ "var_x_1" ~ "');");

			download(url_30, nadisa_30 ~ currentdt ~ ".jpg");
				//if((url_30, nadisa_30 ~ currentdt ~ ".jpg").getSize/1000 < 9) (url_30, nadisa_30 ~ currentdt ~ ".jpg").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".gravitacion_data (file, date_start, date_end, status, type) VALUES ('" ~ currentdt ~ ".jpg', " ~ dt_30 ~ " ," ~ currentdt ~ ", 'DONE', 'nadisa_30')");
		}

		catch(Exception e)
		{
			writeln("Error in Nadisa section (getPlots)");
			writeln(e.msg);
		}

	}

}