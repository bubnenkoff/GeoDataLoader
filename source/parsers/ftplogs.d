module ftplogs;

import std.stdio;
import std.algorithm;
import std.file;
import std.string;
import std.array;
import std.conv;
import std.path;
import std.conv;
import std.range;
import std.datetime;
import std.net.curl;

import utils; // checkURL 
import dbconnect;
import dbinsert;
import parseconfig;
import colorize;




class FTP
{
	DataBaseInsert databaseinsert;
	Config config;
	DBConnect db;
	
	this(DataBaseInsert databaseinsert, Config config, DBConnect db)
	{
		this.databaseinsert = databaseinsert;
		this.config = config;
		this.db = db;
	}

	string [] lognames;
	string [] logfullname;

	void getLogsList(string path)
	{
		try
		{
			if (!exists(path))
			{
				cwriteln("\nFTP local path do not exists".color(fg.red));
				writeln("Please use tool ftpuse and mount FTP to local folder");
				core.thread.Thread.sleep(dur!("seconds")(10));
				return;
			}

			if (!exists(path))
			{
				cwriteln("\nFTP local path (shgm3) do not exists".color(fg.red));
				writeln("Please use tool ftpuse and mount FTP to local folder");
				core.thread.Thread.sleep(dur!("seconds")(10));
				return;
			}

			auto logfiles = dirEntries(path, "*.{log,zip}", SpanMode.breadth);
			foreach(name; logfiles)
			{
				lognames ~= baseName(name);
				logfullname ~= name;
				//writeln(name);
			}

			databaseinsert.getFTPLogContent(logfullname); // sending array of names to db instance


		}

		catch (Exception e)
		{
			writeln("Error in getLogsList section");
			writeln(e.msg);
		}

	}


}