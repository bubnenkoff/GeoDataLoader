module kakioka;

import std.datetime;
import std.net.curl;
import std.stdio;
import std.file;
import std.regex;
import std.conv;
import std.path;
import std.array;
import std.string;
import variantconfig;
import parseconfig;
import dbconnect;
import dbinsert;
import utils;
static import dom = arsd.dom; //to prevent name collision with xml

class Kakiokajma
{
	DataBaseInsert databaseinsert;
	Config config;
	DBConnect db;

	this(DataBaseInsert databaseinsert, DBConnect db)
	{
		this.databaseinsert = databaseinsert;
		this.db = db;
	
	}


	void kakiokajma()
	{

		try
		{
			writeln("Loading PLOTS from kakiokajma"); // in SQL -> tellurika
			string confpath = buildPath((thisExePath[0..((thisExePath.lastIndexOf("\\"))+1)]), "url2path.ini");
			auto config = VariantConfig(confpath);
				
			string geomagnetic_kak = config["geomagnetic_kak"].toStr;
			string electric_kak = config["electric_kak"].toStr;

			string geomagnetic_mmb = config["geomagnetic_mmb"].toStr;
			string electric_mmb = config["electric_mmb"].toStr;

			string geomagnetic_kny = config["geomagnetic_kny"].toStr;
			string electric_kny = config["electric_kny"].toStr;

			string geomagnetic_cbi = config["geomagnetic_cbi"].toStr;
			string electric_cbi = config["electric_cbi"].toStr;


			Date currentdt = cast(Date)(Clock.currTime());
			currentdt = currentdt.roll!"days"(-1);
			string year = to!string(currentdt.year);
			string month = to!string(currentdt.month);
			string day = to!string(currentdt.day);	

			string baseurl = "http://www.kakioka-jma.go.jp/cgi-bin/plot/plotNN.pl";

			string geomagnetic_kak_post = "place=kak&lang=en&datatype=provisional&datakind=m&sampling=1-min&hipasssec=150&year=" ~ year ~ "&month=" ~ month ~ "&day=" ~ day ~ "&hour=0&min=0";
			string electric_kak_post = "place=kak&lang=en&datatype=provisional&datakind=e&sampling=1-min&hipasssec=150&year=" ~ year ~ "&month=" ~ month ~ "&day=" ~ day ~ "&hour=0&min=0";

			string geomagnetic_mmb_post = "place=mmb&lang=en&datatype=provisional&datakind=m&sampling=1-min&hipasssec=150&year=" ~ year ~ "&month=" ~ month ~ "&day=" ~ day ~ "&hour=0&min=0";
			string electric_mmb_post = "place=mmb&lang=en&datatype=provisional&datakind=e&sampling=1-min&hipasssec=150&year=" ~ year ~ "&month=" ~ month ~ "&day=" ~ day ~ "&hour=0&min=0";

			string geomagnetic_kny_post = "place=kny&lang=en&datatype=provisional&datakind=m&sampling=1-min&hipasssec=150&year=" ~ year ~ "&month=" ~ month ~ "&day=" ~ day ~ "&hour=0&min=0";
			string electric_kny_post = "place=kny&lang=en&datatype=provisional&datakind=e&sampling=1-min&hipasssec=150&year=" ~ year ~ "&month=" ~ month ~ "&day=" ~ day ~ "&hour=0&min=0";

			string geomagnetic_cbi_post = "place=cbi&lang=en&datatype=provisional&datakind=m&sampling=1-min&hipasssec=150&year=" ~ year ~ "&month=" ~ month ~ "&day=" ~ day ~ "&hour=0&min=0";
			string electric_cbi_post = "place=cbi&lang=en&datatype=provisional&datakind=e&sampling=1-min&hipasssec=150&year=" ~ year ~ "&month=" ~ month ~ "&day=" ~ day ~ "&hour=0&min=0";


		    string content_geomagnetic_kak = post(baseurl, geomagnetic_kak_post).idup;
		    string content_electric_kak = post(baseurl, electric_kak_post).idup;
		    string content_geomagnetic_mmb = post(baseurl, geomagnetic_mmb_post).idup;
		    string content_electric_mmb = post(baseurl, electric_mmb_post).idup;
		    string content_geomagnetic_kny = post(baseurl, geomagnetic_kny_post).idup;
		    string content_electric_kny = post(baseurl, electric_kny_post).idup;
		    string content_geomagnetic_cbi = post(baseurl, geomagnetic_cbi_post).idup;
		    string content_electric_cbi = post(baseurl, electric_cbi_post).idup;


		    auto pngRegex = regex(r"(/.+png)");


		    auto imgpng = matchFirst(content_geomagnetic_kak, pngRegex)[0]; // to prevent 2 elemets 

			string imgpng_geomagnetic_kak = matchFirst(content_geomagnetic_kak, pngRegex)[0];
			string imgpng_electric_kak = matchFirst(content_electric_kak, pngRegex)[0];
			string imgpng_geomagnetic_mmb = matchFirst(content_geomagnetic_mmb, pngRegex)[0];
			string imgpng_electric_mmb = matchFirst(content_electric_mmb, pngRegex)[0];
			string imgpng_geomagnetic_kny = matchFirst(content_geomagnetic_kny, pngRegex)[0];
			string imgpng_electric_kny = matchFirst(content_electric_kny, pngRegex)[0];
			string imgpng_geomagnetic_cbi = matchFirst(content_geomagnetic_cbi, pngRegex)[0];
			string imgpng_electric_cbi = matchFirst(content_electric_cbi, pngRegex)[0];

		    string fullImgURL_geomagnetic_kak = "http://www.kakioka-jma.go.jp" ~ imgpng_geomagnetic_kak;
		    string fullImgURL_electric_kak = "http://www.kakioka-jma.go.jp" ~ imgpng_electric_kak;
		    string fullImgURL_geomagnetic_mmb = "http://www.kakioka-jma.go.jp" ~ imgpng_geomagnetic_mmb;
		    string fullImgURL_electric_mmb = "http://www.kakioka-jma.go.jp" ~ imgpng_electric_mmb;
		    string fullImgURL_geomagnetic_kny = "http://www.kakioka-jma.go.jp" ~ imgpng_geomagnetic_kny;
		    string fullImgURL_electric_kny = "http://www.kakioka-jma.go.jp" ~ imgpng_electric_kny;
		    string fullImgURL_geomagnetic_cbi = "http://www.kakioka-jma.go.jp" ~ imgpng_geomagnetic_cbi;
		    string fullImgURL_electric_cbi = "http://www.kakioka-jma.go.jp" ~ imgpng_electric_cbi;
		    
		    try
		    {
				download(fullImgURL_geomagnetic_kak, geomagnetic_kak ~ to!string(currentdt.toISOString) ~ "_Kakioka.png");
				databaseinsert.kakiokajma_insert(currentdt.toISOString, "geomagnetic_kak", "Geoelectric", "Kakioka", "DONE");
			}

			catch(Exception e)
			{
				writeln("Can't load geomagnetic_kak");
			}

			try
			{
				download(fullImgURL_electric_kak, electric_kak ~ to!string(currentdt.toISOString) ~ "_Kakioka.png");
				databaseinsert.kakiokajma_insert(currentdt.toISOString, "electric_kak", "Atmospheric", "Kakioka", "DONE");
			}

			catch(Exception e)
			{
				writeln("Can't load electric_kak");
			}

			try
			{
				download(fullImgURL_geomagnetic_mmb, geomagnetic_mmb ~ to!string(currentdt.toISOString) ~ "_Memambetsu.png");
				databaseinsert.kakiokajma_insert(currentdt.toISOString, "geomagnetic_mmb", "Geoelectric", "Memambetsu", "DONE");
			}

			catch(Exception e)
			{
				writeln("Can't load geomagnetic_mmb");
			}

			try
			{
				download(fullImgURL_electric_mmb, electric_mmb ~ to!string(currentdt.toISOString) ~ "_Memambetsu.png");
				databaseinsert.kakiokajma_insert(currentdt.toISOString, "electric_mmb", "Atmospheric", "Memambetsu", "DONE");
			}

			catch(Exception e)
			{
				writeln("Can't load electric_mmb");
			}
			
			try
			{
				download(fullImgURL_geomagnetic_kny, geomagnetic_kny ~ to!string(currentdt.toISOString) ~ "_Kanoya.png");
				databaseinsert.kakiokajma_insert(currentdt.toISOString, "geomagnetic_kny", "Geoelectric", "Kanoya", "DONE");	
			}

			catch(Exception e)
			{
				writeln("Can't load geomagnetic_kny");
			}

			try
			{
				download(fullImgURL_electric_kny, electric_kny ~ to!string(currentdt.toISOString) ~ "_Kanoya.png");
				databaseinsert.kakiokajma_insert(currentdt.toISOString, "electric_kny", "Atmospheric", "Kanoya", "DONE");	
			}

			catch(Exception e)
			{
				writeln("Can't load electric_kny");
			}

			try
			{
				download(fullImgURL_geomagnetic_cbi, geomagnetic_cbi ~ to!string(currentdt.toISOString) ~ "_Chichijima.png");
				databaseinsert.kakiokajma_insert(currentdt.toISOString, "geomagnetic_cbi", "Geoelectric", "Chichijima", "DONE");	
			}

			catch(Exception e)
			{
				writeln("Can't load geomagnetic_cbi");
			}
			
			try
			{
				download(fullImgURL_electric_cbi, electric_cbi ~ to!string(currentdt.toISOString) ~ "_Chichijima.png");	
				databaseinsert.kakiokajma_insert(currentdt.toISOString, "electric_cbi", "Atmospheric", "Chichijima", "DONE");	
			}

			catch(Exception e)
			{
				writeln("Can't load electric_cbi");
			}
			
		}

		catch(Exception e)
		{
			writeln(e.msg);
			writeln("Try to turn off section kakiokajma in config.ini");
		}

	}

}
