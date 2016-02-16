// SOLAR INDEX = SolarIndex + Geomagnetic index
module solarindex;

import std.datetime;
import std.net.curl;
import std.stdio;
import std.file;
import std.conv;
import std.path;
import std.array;
import std.string;
import std.algorithm;

import parseconfig;
import dbconnect;
import dbinsert;
import utils;
static import dom = arsd.dom; //to prevent name collision with xml

class SolarIndex
{
	DataBaseInsert databaseinsert; 
	Config config;
	DBConnect db;

	this(DataBaseInsert databaseinsert, Config config, DBConnect db)
	{
		writefln("[SolarIndex]");
		this.databaseinsert = databaseinsert;
		this.config = config;
		this.db = db;
	}

	// we do not need collect commented dates...
	string [] date;
/*	string [] ghz;
	string [] magnetic_2K;
	string [] magnetic_1K;
	string [] noaa;
	string [] star;
	string [] potsdam;
	string [] daily;
	string [] planetary;
*/
	string [] boulder;

/*	string [] solarwind; */

//	string [] number_c;
//	string [] number_m;
//	string [] number_x;
	string [] sqls; // data for inserting



	void parse()
	{
		try
		{
			if(checkLink(config.solarindex)) 
				string content = get(config.solarindex).idup;
		}

		catch(Exception e)
		{
			writefln("Can't get content from %s", config.solarindex);
		}

	try
	{
		string content = get(config.solarindex).idup;

		auto document = new dom.Document(content);

	    foreach(row; document.querySelectorAll("tr"))
	    {
	    	auto data = row.querySelectorAll("td");
	    	if(data.length == 0)
	    		continue;
	    	//writeln(data[0].innerText, " ", data[1].innerText, " ", data[2].innerText);
	    
	    	date ~= to!string(data[0].innerText);
	/*		ghz ~= to!string(data[1].innerText);
			magnetic_2K ~= to!string(data[2].innerText);
			magnetic_1K ~= to!string(data[3].innerText);
			noaa ~= to!string(data[4].innerText);
			star ~= to!string(data[5].innerText);
			potsdam ~= to!string(data[6].innerText);
			daily ~= to!string(data[7].innerText);
			planetary ~= to!string(data[8].innerText); */

			boulder ~= (to!string(data[9].innerText)).map!(a => format("%s ", a)).join;
			//auto boulder = boulder.map!(a => format("%s ", a)).join;

	/*		solarwind ~= to!string(data[10].innerText); */
			// temporary commented till find way to replace &nbsp; 		
			//number_c ~= to!string(data[11].innerText);
			//number_m ~= to!string(data[12].innerText);
			//number_x ~= to!string(data[13].innerText);

	    }
	    
	    // we need to do reverse order, because other table table habe another date order
	    foreach_reverse (i, d; date)
	    {
	    	// full old version // string sql = format("INSERT INTO test.solarindex (date, ghz, magnetic_2K, magnetic_1K, noaa, star, potsdam, daily, planetary, boulder, solarwind) VALUES (%s, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ON DUPLICATE KEY UPDATE date=%s;",  d, ghz[i], magnetic_2K[i], magnetic_1K[i], noaa[i], star[i], potsdam[i], daily[i], planetary[i], boulder[i], solarwind[i], d);
			string sql = format("INSERT INTO " ~ config.dbname ~ ".geomagnetic_index (date, boulder) VALUES ('%s', '%s') ON DUPLICATE KEY UPDATE boulder='%s';",  d, boulder[i], boulder[i]);	    	
	    	//writeln(sql);
	    	sqls ~= sql;
	    }

	    // befor sending it's to insert we need to create array of strings
	    databaseinsert.solarindexinsert(sqls);

	}

	catch(Exception e)
	{
		writefln("Error in parsing section!");
	}


	}

}