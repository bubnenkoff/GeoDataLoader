module patternsloader;

import std.file;
import std.string;
import std.stdio;
import std.path;
import std.string;

import dbconnect;
import dbinsert;
import parseconfig;

import ddbc.all;
import ddbc.pods; // to get db.stmt.select work

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

	struct img_patterns 
	{
		string myalias;
		string type;
		string url;
		string prefix;
		string dateformat;
		string postfix;
	}

	void imgPattern()
	{
		auto patterns = db.stmt.select!img_patterns; //fixme

		foreach(p;patterns)
		{
			writeln(p);
		}
	}


}