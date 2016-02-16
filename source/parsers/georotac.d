module georotac;

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

class georotac
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
			writeln("Loading georotac");
			string confpath = buildPath((thisExePath[0..((thisExePath.lastIndexOf("\\"))+1)]), "url2path.ini");
			auto pathconfig = VariantConfig(confpath);

			string currentdt = to!string((cast(Date)(Clock.currTime())).toISOString);				

			string dt_1 = to!string((cast(Date)(Clock.currTime()) + 1.days).toISOString);
			string dt_14 = to!string((cast(Date)(Clock.currTime()) + 14.days).toISOString);	
			string dt_30 = to!string((cast(Date)(Clock.currTime()) + 30.days).toISOString);	

			//small hack to get current date in FileName column
			string dt_1_ = to!string((cast(Date)(Clock.currTime())).toISOString);
			string dt_14_ = to!string((cast(Date)(Clock.currTime())).toISOString);	
			string dt_30_ = to!string((cast(Date)(Clock.currTime())).toISOString);	


			string var_x        = pathconfig["x_date"].toStr;

			string var_y        = pathconfig["y_date"].toStr;

			string var_pol      = pathconfig["Polhody"].toStr;

			string var_ut1utc   = pathconfig["UT1-UTC"].toStr;

			string var_ut1tai   = pathconfig["UT1_TAI"].toStr;

			string var_lod      = pathconfig["LOD"].toStr;

		
			//download(fullImgURL_electric_cbi, electric_cbi ~ to!string(currentdt.toISOString) ~ ".png");	
			//db.kakiokajma_insert(currentdt.toISOString, "electric_cbi", "DONE");

			string url_var_x_1 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=1&eop=1&graphe=1&dimx=600&dimy=350&tver=0";
			string url_var_x_14 ="http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=14&eop=1&graphe=1&dimx=600&dimy=350&tver=0";
			string url_var_x_30 ="http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=30&eop=1&graphe=1&dimx=600&dimy=350&tver=0";

			string url_var_y_1 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=1&eop=1&graphe=2&dimx=600&dimy=350&tver=0";
			string url_var_y_14 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=14&eop=1&graphe=2&dimx=600&dimy=350&tver=0";
			string url_var_y_30 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=30&eop=1&graphe=2&dimx=600&dimy=350&tver=0";

			string url_var_pol_1 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=1&eop=1&graphe=12&dimx=600&dimy=600&tver=0";
			string url_var_pol_14 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=14&eop=1&graphe=12&dimx=600&dimy=600&tver=0";
			string url_var_pol_30 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=30&eop=1&graphe=12&dimx=600&dimy=600&tver=0";

			string url_var_ut1utc_1 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=1&eop=1&graphe=3&dimx=600&dimy=350&tver=0";
			string url_var_ut1utc_14 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=1&eop=14&graphe=3&dimx=600&dimy=350&tver=0";
			string url_var_ut1utc_30 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=1&eop=30&graphe=3&dimx=600&dimy=350&tver=0";

			string url_var_ut1tai_1 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=1&eop=1&graphe=4&dimx=600&dimy=350&tver=0";
			string url_var_ut1tai_14 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=14&eop=1&graphe=4&dimx=600&dimy=350&tver=0";
			string url_var_ut1tai_30 = "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=30&eop=1&graphe=4&dimx=600&dimy=350&tver=0";

			string url_var_lod_1 =  "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=1&eop=1&graphe=5&dimx=600&dimy=350&tver=0";		
			string url_var_lod_14 =  "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=14&eop=1&graphe=5&dimx=600&dimy=350&tver=0";		
			string url_var_lod_30 =  "http://hpiers.obspm.fr/eop-pc/products/combined/realtime/realtimeplot.php?laps=30&eop=1&graphe=5&dimx=600&dimy=350&tver=0";		


			download(url_var_x_1, var_x ~ currentdt  ~ "_x_1" ~ ".png");
				if( (var_x ~ currentdt  ~ "_x_1" ~ ".png").getSize/1000 < 4) (var_x ~ currentdt  ~ "_x_1" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_1 ~"', '" ~ dt_1_ ~ "_x_1.png', " ~ "1, '" ~ "x_date" ~ "');");

			download(url_var_x_14, var_x ~ currentdt ~ "_x_14" ~ ".png");
				if( (var_x ~ currentdt ~ "_x_14" ~ ".png").getSize/1000 < 4) (url_var_x_14, var_x ~ currentdt ~ "_x_14" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_14 ~"', '" ~ dt_14_ ~ "_x_14.png', " ~ "14, '" ~ "x_date" ~ "');");

			download(url_var_x_30, var_x ~ currentdt ~ "_x_30" ~ ".png");
				if( (var_x ~ currentdt ~ "_x_30" ~ ".png").getSize/1000 < 4) (var_x ~ currentdt ~ "_x_30" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_30 ~"', '" ~ dt_30_ ~ "_x_30.png', " ~ "30, '" ~ "x_date" ~ "');");

			////
			download(url_var_y_1, var_y ~ currentdt ~ "_y_1" ~ ".png");
				if( (var_y ~ currentdt ~ "_y_1" ~ ".png").getSize/1000 < 4) (var_y ~ currentdt ~ "_y_1" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_1 ~"', '" ~ dt_1_ ~ "_y_1.png', " ~ "1, '" ~ "y_date" ~ "');");

			download(url_var_y_14, var_y ~ currentdt ~ "_y_14" ~ ".png");
				if( (var_x ~ currentdt  ~ "_x_1" ~ ".png").getSize/1000 < 4) (var_y ~ currentdt ~ "_y_14" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_14 ~"', '" ~ dt_14_ ~ "_y_14.png', " ~ "14, '" ~ "y_date" ~ "');");

			download(url_var_y_30, var_y ~ currentdt ~ "_y_30" ~ ".png");
				if( (var_y ~ currentdt ~ "_y_30" ~ ".png").getSize/1000 < 4) (var_y ~ currentdt ~ "_y_30" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_30 ~"', '" ~ dt_30_ ~ "_y_30.png', " ~ "30, '" ~ "y_date" ~ "');");			

			//////
			download(url_var_pol_1, var_pol ~ currentdt ~ "_Polhody_1" ~ ".png");
				if( (var_pol ~ currentdt ~ "_Polhody_1" ~ ".png").getSize/1000 < 4) (var_pol ~ currentdt ~ "_Polhody_1" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_1 ~"', '" ~ dt_1_ ~ "_Polhody_1.png', " ~ "1, '" ~ "Polhody" ~ "');");

			download(url_var_pol_14, var_pol ~ currentdt ~ "_Polhody_14" ~ ".png");
				if( (var_pol ~ currentdt ~ "_Polhody_14" ~ ".png").getSize/1000 < 4) (var_pol ~ currentdt ~ "_Polhody_14" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_14 ~"', '" ~ dt_14_ ~ "_Polhody_14.png', " ~ "14, '" ~ "Polhody" ~ "');");

			download(url_var_pol_30, var_pol ~ currentdt ~ "_Polhody_30" ~ ".png");
				if( (var_x ~ currentdt  ~ "_x_1" ~ ".png").getSize/1000 < 4) (var_x ~ currentdt  ~ "_x_1" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_30 ~"', '" ~ dt_30_ ~ "_Polhody_30.png', " ~ "30, '" ~ "Polhody" ~ "');");			

			////
			download(url_var_ut1utc_1, var_pol ~ currentdt ~ "_Polhody_30" ~ ".png");
				if( (var_pol ~ currentdt ~ "_Polhody_30" ~ ".png").getSize/1000 < 4) (var_pol ~ currentdt ~ "_Polhody_30" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_1 ~"', '" ~ dt_1_ ~ "_UT1-UTC_1.png', " ~ "1, '" ~ "UT1-UTC" ~ "');");

			download(url_var_ut1utc_14, var_ut1utc ~ currentdt ~ "_UT1-UTC_14" ~ ".png");
				if( (var_ut1utc ~ currentdt ~ "_UT1-UTC_14" ~ ".png").getSize/1000 < 4) (var_ut1utc ~ currentdt ~ "_UT1-UTC_14" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_14 ~"', '" ~ dt_14_ ~ "_UT1-UTC_14.png', " ~ "14, '" ~ "UT1-UTC" ~ "');");

			download(url_var_ut1utc_30, var_ut1utc ~ currentdt ~ "_UT1-UTC_30" ~ ".png");
				if( (var_ut1utc ~ currentdt ~ "_UT1-UTC_30" ~ ".png").getSize/1000 < 4) (var_ut1utc ~ currentdt ~ "_UT1-UTC_30" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_30 ~"', '" ~ dt_30_ ~ "_UT1-UTC_30.png', " ~ "30, '" ~ "UT1-UTC" ~ "');");			

			//////
			download(url_var_ut1tai_1, var_ut1tai ~ currentdt ~ "_UT1_TAI_1" ~ ".png");
				if( (var_ut1tai ~ currentdt ~ "_UT1_TAI_1" ~ ".png").getSize/1000 < 4) (var_ut1tai ~ currentdt ~ "_UT1_TAI_1" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_1 ~"', '" ~ dt_1_ ~ "_UT1_TAI_1.png', " ~ "1, '" ~ "UT1_TAI" ~ "');");

			download(url_var_ut1tai_14, var_ut1tai ~ currentdt ~ "_UT1_TAI_14" ~ ".png");
				if( (var_ut1tai ~ currentdt ~ "_UT1_TAI_14" ~ ".png").getSize/1000 < 4) (var_ut1tai ~ currentdt ~ "_UT1_TAI_14" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_14 ~"', '" ~ dt_14_ ~ "_UT1_TAI_14.png', " ~ "14, '" ~ "UT1_TAI" ~ "');");

			download(url_var_ut1tai_30, var_ut1tai ~ currentdt ~ "_UT1_TAI_30" ~ ".png");
				if( (var_ut1tai ~ currentdt ~ "_UT1_TAI_30" ~ ".png").getSize/1000 < 4) (var_ut1tai ~ currentdt ~ "_UT1_TAI_30" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_30 ~"', '" ~ dt_30_ ~ "_UT1_TAI_30.png', " ~ "30, '" ~ "UT1_TAI" ~ "');");			

			/////

			download(url_var_lod_1, var_lod ~ currentdt ~ "_LOD_1" ~ ".png");
				if( (var_lod ~ currentdt ~ "_LOD_1" ~ ".png").getSize/1000 < 4) (var_lod ~ currentdt ~ "_LOD_1" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_1 ~"', '" ~ dt_1_ ~ "_LOD_1.png', " ~ "1, '" ~  "LOD" ~ "');");

			download(url_var_lod_14, var_lod ~ currentdt ~ "_LOD_14" ~ ".png");
				if( (var_lod ~ currentdt ~ "_LOD_14" ~ ".png").getSize/1000 < 4) (var_lod ~ currentdt ~ "_LOD_14" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_14 ~"', '" ~ dt_14_ ~ "_LOD_14.png', " ~ "14, '" ~ "LOD" ~ "');");

			download(url_var_lod_30, var_lod ~ currentdt ~ "_LOD_30" ~ ".png");
				if( (var_lod ~ currentdt ~ "_LOD_30" ~ ".png").getSize/1000 < 4) (var_lod ~ currentdt ~ "_LOD_30" ~ ".png").remove; else
			db.stmt.executeUpdate("INSERT IGNORE INTO " ~ config.dbname ~ ".georotac (DateStart, DateEnd, file, Day, Type) VALUES ('" ~ currentdt ~ "', '" ~ dt_30 ~"', '" ~ dt_30_ ~ "_LOD_30.png', " ~ "30, '" ~ "LOD" ~ "');");		
			
		}

	catch(Exception e)
	{
		writeln("Error in georotac (getPlots)");
		writeln(e.msg);
	}

	}
}