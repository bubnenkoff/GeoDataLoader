import std.stdio;
import std.file;
import std.datetime;

import vibe.core.log;
import vibe.http.client;
import vibe.stream.operations;
import vibe.http.status;

import colorize;
import parseconfig;

// stand alone function
bool checkLink(string link) // we need to check all links to be sure if they are alive
{
	try
	{
		uint status;
		bool isalive;

		requestHTTP(link, (scope req) 
			{
				req.method = HTTPMethod.GET;
			},
			(scope res) 
			{
				if ((res.statusCode) == 200)
					{
						isalive = true;
						cwritefln("%s response code: %s".color(fg.green), link, (res.statusCode)); 
					}	
				else
					{
						isalive = false;
						cwritefln("ERROR: %s response code: %s".color(fg.red), link, (res.statusCode)); 
					}
			}
		);

		return isalive;
	}
	
	catch(Exception ex)	
	{
		writeln(ex.msg);
		return false;
	}
}

void makeDir(string mypath)
{
	
	try 
	{
		mkdirRecurse(mypath);
		writeln("dir created: ", mypath);
	}

	catch (Exception e)
	{
		writeln("Can't create dir: ", mypath);
	}
}



//REMOVE DATA OLDER 365 DAYS
void getDirList(string mypath)
{
	auto allEntrys = dirEntries(mypath,"*", SpanMode.depth);
	foreach(entry; allEntrys)
	{
		if(entry.isDir)
		{
			
			if (!entry.name.canFind("Project") && !entry.name.canFind("data")) // exclude Dirs
			{
				writeln("is dir: ", entry);
				removeOld(entry.name); // pass FOLDER FULL NAME
			}
		}
			
	}
}


void removeOld(string dir)
{
	try
	{
		writeln("dir for lookup: ", dir);
		auto current_dt = (Clock.currTime);
		auto last_year = (Clock.currTime - 365.days);
		auto files = dirEntries(dir,"*.*", SpanMode.depth);
			foreach(file; files) //iterate FILES ONLY!
			{
				if (file.timeLastModified < (current_dt - 365.days)) // less then preview year
					try {
							writeln("File was removed: ",  file);
							file.remove;
						}
					catch (Exception e)
					{
						writeln("Can't remove file: ", file);
						writeln(e.msg);
					}
					
			}
	}
	
	catch (Exception e)
	{
		writeln("exeption in path: ", dir);
		writeln(e.msg);
	}
}

///////