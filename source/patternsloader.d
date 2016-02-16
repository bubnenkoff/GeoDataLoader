import std.file;
import std.string;
import std.stdio;
import std.path;
import std.string;

import dbconnect;
import dbinsert;
import parseconfig;

class PatternLoader
{

	DataBaseInsert databaseinsert;
	DBConnect db;
	Config config;

	this(DataBaseInsert databaseinsert, DBConnect db, Config config)
	{
		this.databaseinsert = databaseinsert;
		this.db = db;
		this.config = config;
	}

	struct DBDatas 
	{
		string myalias;
		string type;
		string baseurl;
		string timeshift;
		string month;
		string year;
	}

	void imgPattern()
	{

	}


}