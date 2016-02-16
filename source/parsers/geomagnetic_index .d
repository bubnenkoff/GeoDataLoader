// geomagnetic is part of SolarIndex
module geomagnetic_index;

import std.datetime;
import std.net.curl;
import std.stdio;
import std.conv;
import std.file;
import std.path;
import std.array;
import std.string;

import parseconfig;
import dbconnect;
import dbinsert;
import utils;
static import dom = arsd.dom; //to prevent name collision with xml

class geomagnetic_index 
{
	DataBaseInsert databaseinsert;
	Config config;
	DBConnect db;

	this(DataBaseInsert databaseinsert, Config config,  DBConnect db)
	{
		this.databaseinsert = databaseinsert;
		this.config = config;
		this.db = db;
	}

	string [] date;
	string [] fredericksburg;
	string [] college;
	string [] planetary;

	string [] sqls; // data for inserting


	void parse()
	{
		try
		{

		//	string url = "ftp://ftp.swpc.noaa.gov/pub/indices/DGD.txt";

			foreach(line; config.geomagnetic_index.byLine())
			{
				if (to!string((line[0])) != "2") continue; // stupid way to check header
				//writeln(line);
				//readln();
				date ~= (to!string(line)).replace(" ", "-")[0..10];
				
				fredericksburg ~= ((to!string(line)).replace("-", " ")[18..34]).strip;
				college ~= ((to!string(line)).replace("-", " ")[40..57]).strip;
				planetary ~= ((to!string(line)).replace("-", " ")[62..79]).strip;		

			}

			foreach (i, date; date)
			{
				string sqlinsert = format("INSERT INTO " ~ config.dbname ~ ".geomagnetic_index (`date`, `fredericksburg`, `college`, `planetary`) VALUES ('%s', '%s', '%s', '%s') ", date, fredericksburg[i], college[i], planetary[i]);
				//writeln(sqlinsert);
				string onDuplicateKey = format(" ON DUPLICATE KEY UPDATE fredericksburg='%s', college='%s', planetary='%s';", fredericksburg[i], college[i], planetary[i]);
				//writeln(onDuplicateKey);
				string sqlresult = sqlinsert ~ onDuplicateKey;
				sqls ~= sqlresult;
			}
		    databaseinsert.dgdindexinsert(sqls);

		}

		catch(Exception e)
		{
			writefln("Error in parsing section geomagnetic_index!");
		}


	}

}
