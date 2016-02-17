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

	struct DBDatas 
	{
		string myalias;
		string type;
		string url;
		string prefix;
		string dateformat;
		string postfix;
		string interval;
	}


	void imgPattern()
	{
		DBDatas dbdatas;
		string sql = ("select * from " ~ config.dbname ~ ".img_patterns;");
		auto patterns = db.stmt.executeQuery(sql);

		while(patterns.next())
		{
			dbdatas.myalias = patterns.getString(1);
			dbdatas.type = patterns.getString(2);
			dbdatas.url = patterns.getString(3);
			dbdatas.prefix = patterns.getString(4);
			dbdatas.dateformat = patterns.getString(5);
			dbdatas.postfix = patterns.getString(6);
			dbdatas.interval = patterns.getString(7);

			writeln(dbdatas.url);

		}

	}


}