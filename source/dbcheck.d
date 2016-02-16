module dbcheck;

import std.file;
import std.string;
import std.stdio;
import std.path;
import std.string;

import dbconnect;
import dbinsert;
import parseconfig;

// For checkImgsExists
//because inside foreach we need access to url and myalias for matching them. 
//Path on FS consist myalias + year + month. Like: \navy-stitched_vis \201501

//now we should check if any of images that exist in DB was removed from FS.
//and then clean up DB from them
//images can be removing, but links in DB are stay
//function have same logic as imagedownload
//if row was marked as FAILURE, but after new run image was founded it will be mark as EXISTS

class DBWork
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
	
	void checkImgsExists()
	{
		writeln("Checking DB...");
		
		struct DBDatas 
		{
			string id;
			string url;
			string name;
			string myalias;
			string month;
			string year;
		}

		try
		{
			string sql = (`select * from ` ~ config.dbname ~ `.imgs WHERE status = "DONE"`); 
			writeln(sql);
			int count;
			auto images = db.stmt.executeQuery(sql); 

			DBDatas dbdata;  // fill struct
			
			while(images.next())	
			{
				dbdata.id = images.getString(1);
				dbdata.url = images.getString(4);
				dbdata.name = images.getString(6);
				dbdata.myalias = images.getString(10);

				dbdata.month = images.getString(11);
				dbdata.year = images.getString(12);
				count++;

				//check if some fields are empty!
				if (dbdata.id == null)
				{
					writeln("dbdata.id == null");
					readln;
				}
				if (dbdata.url == null)
				{
					writeln("dbdata.url == null");
					readln;
				}
				if (dbdata.name == null)
				{
					writeln("dbdata.name == null");
					readln;
				}
				if (dbdata.myalias == null)
				{
					writeln("dbdata.myalias == null");
					readln;
				}
				if (dbdata.month == null)
				{
					writeln("dbdata.month == null");
					readln;
				}
				if (dbdata.year == null)
				{
					writeln("dbdata.year == null");
					readln;
				}

				// DEAD IMAGES
				string imageFullName = buildPath(config.rootImgsPath, dbdata.myalias, dbdata.year[2..4] ~ dbdata.month, dbdata.name); // original
				string projectedImageFullName = buildPath(config.rootImgsPath_projected, dbdata.myalias, dbdata.year[2..4] ~ dbdata.month, dbdata.name); // projected

				//if imageFullName and projectedImageFullName do not exists row from DB immediately 
				if(!imageFullName.exists && !projectedImageFullName.exists)
				{
					string sqlupdate = ("DELETE FROM " ~ config.dbname ~ ".imgs WHERE id='" ~ dbdata.id ~ "'");
					auto rs = db.stmt.executeUpdate(sqlupdate);		
				}


				if(imageFullName.exists)
				{
					string sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET checkFileExists=NULL WHERE id='" ~ dbdata.id ~ "'");
					auto rs = db.stmt.executeUpdate(sqlupdate);		
				}

				if(!imageFullName.exists)
				{
					string sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET checkFileExists='FAILURE' WHERE id='" ~ dbdata.id ~ "'");
					auto rs = db.stmt.executeUpdate(sqlupdate);		
				}


				if(projectedImageFullName.exists)
				{
					string sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET checkReprojectedFileExists=NULL WHERE id='" ~ dbdata.id ~ "'");
					auto rs = db.stmt.executeUpdate(sqlupdate);		
				}				



				if(!projectedImageFullName.exists)
				{
					string sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET checkReprojectedFileExists='FAILURE' WHERE id='" ~ dbdata.id ~ "'");
					auto rs = db.stmt.executeUpdate(sqlupdate);		
				}	


				if (count == 0)
					writeln("All images from DB exists on FS");

				
				
			}

		
			
		}
		
		catch (Exception e)
		{
			writeln(e.msg);
		}


	
	}
	
}
	