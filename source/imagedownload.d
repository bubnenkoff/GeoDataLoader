module imagedownload;

import parseconfig;

import std.file;
import std.string;
import std.datetime;
import std.path;
import std.net.curl;
import std.stdio;
import std.xml;
import std.regex;
import std.conv;
import std.algorithm;
import std.uni; // for toLower
import std.typecons;
import std.exception;

import dbconnect;
import dbinsert;
import reproj; // for gdal reprojection
import utils; // checkURL, makeDir 

static import dom = arsd.dom; //to prevent name collision with xml
import colorize;

class IMGDownload
{
	DataBaseInsert databaseinsert;
	DBConnect db;
	Config config;

	// statistic
	int img_before; // we need to declarate it's here or var would not be viible
	int img_after; // we need to declarate it's here or var would not be visible
	int total; // COUNT OF ALL rows (with any status)
	
	this(DataBaseInsert databaseinsert, DBConnect db, Config config)
	{
		writefln("[Image Downloading]");
		this.databaseinsert = databaseinsert;
		this.db = db;
		this.config = config;
	}


	struct DBDatas 
	{
		string id;
		string url;
		string name;
		string myalias;
		string month;
		string year;
	}


	void runReferenceDownloadedImgs (Date dateStart, Date dateEnd) // spatial reference loaded images that was loaded, but not referenced
	{
		GDALProcessing gdalprocessing = new GDALProcessing(db); // create gdal instance
		string sql; 
		try
		{
			if (config.test_mode == "true") // reproject
			{
				sql = ("select * from " ~ config.dbname ~ ".imgs WHERE reproj_status IS NULL AND status = 'DONE' group by url;");
				writeln("test_mode is set to true!");
				writeln("Only one copy of each source will be PROJECT!");
				writeln(sql);
				readln;
			}

			else
			{
				sql = ("select * from " ~ config.dbname ~ ".imgs WHERE Date IN (SELECT Date from test.imgs WHERE (Date BETWEEN '" ~ dateStart.toISOExtString() ~ "' AND '" ~ dateEnd.toISOExtString() ~ "')) AND status = 'DONE' AND reproj_status IS NULL"); 
			}
				auto newimages = db.stmt.executeQuery(sql); // Request for NO Value in field
				//writeln(sql);
				//readln;

				DBDatas dbdata;  // fill struct
				int count;
				while(newimages.next())
				{

					dbdata.id = newimages.getString(1);
					dbdata.url = newimages.getString(4);
					dbdata.name = newimages.getString(6);
					dbdata.myalias = newimages.getString(10);

					dbdata.month = newimages.getString(11);
					dbdata.year = newimages.getString(12);

					try
					{
						string imageFullName = buildPath(config.rootImgsPath, dbdata.myalias, dbdata.year[2..4] ~ dbdata.month, dbdata.name); // original imageFullName
						string reprojectedImageFullName = buildPath(config.rootImgsPath_projected, dbdata.myalias, dbdata.year[2..4] ~ dbdata.month, dbdata.name); // reprojected imageFullName
						
						string folderWithDataFilesForReproj = buildPath(config.rootImgsPath, dbdata.myalias); // myalias shuld include this file
						//gdalProcessFile should return reprojected name
														// we should pass orifinal FullName, FullReprojectedName (another dir) and 
						string imageReprojectedName = baseName(gdalprocessing.gdalProcessFile(imageFullName, reprojectedImageFullName, dbdata.myalias)); // from module reproject.d dbdata.myalias need to get section name
						string sqlupdate; // SQL body
						if(imageReprojectedName == null) //If imageReprojectedName return null GDAL reprojection FAILURE
							sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET reproj_name='" ~ imageReprojectedName ~ `', reproj_status='FAILURE'` ~ `WHERE id='` ~ dbdata.id ~ "'");
						else //need to update field reproj_name to new name (reprojected file name)
							sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET reproj_name='" ~ imageReprojectedName ~ `', reproj_status='Done'` ~ `WHERE id='` ~ dbdata.id ~ "'");
						
						auto rs = db.stmt.executeUpdate(sqlupdate);
					}

					catch (Exception e)
					{
						writeln("----------------------------------------------------");
						writeln("[ERROR] Can't do image reprojection");
						writeln("You may try to set \"reprojection_allow\" to false");
						writeln(e);
						writeln("----------------------------------------------------");

						//In case of error
						string sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET reproj_status='FAILURE' WHERE src='" ~ dbdata.url ~ "'");
						auto rs = db.stmt.executeUpdate(sqlupdate);
					}

					
					//if success we should update status
					string sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET reproj_status='DONE' WHERE src='" ~ dbdata.url ~ "'");
					auto rs = db.stmt.executeUpdate(sqlupdate);	


			}

			

			if(count == 0)
			{
				writeln("No images for reprojecting in DB for dates (No images with status DONE): ");
				writeln("dateStart: ", dateStart.toISOExtString());
				writeln("dateEnd: ", dateEnd.toISOExtString());
				writeln("-----");
				writeln(sql);
				writeln("-----");

			}
			
		}

		catch(Exception ex)
		{
			writeln(ex.msg);
			writeln("Can't get for geo-reference (from already downloaded section)");

		}



	}




	void imagedownload(Date dateStart, Date dateEnd) // standalone function for loading images 2FS
	{
		writeln("Downloading image start");
		int imgCount; //count downloaded images
		int imgTotal;


		//DBDatas [] dbdatas; // all data
		DBDatas dbdata; //fill and then ~= to dbdatas

		GDALProcessing gdalprocessing = new GDALProcessing(db); // create gdal instance

		try
		{
			
			string sql;
			if (config.test_mode == "true")
			{
				sql = ("select * from " ~ config.dbname ~ ".imgs WHERE status IS NULL group by url;");
				writeln("test_mode is set to true!");
				writeln("Only one copy of each source will be LOAD!");
				readln;
			}

			else
			{
				//auto total_request = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".imgs;");
				auto total_request = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".imgs WHERE Date IN (SELECT Date from test.imgs WHERE (Date BETWEEN '" ~ dateStart.toISOExtString() ~ "' AND '" ~ dateEnd.toISOExtString() ~ "')) AND status IS NULL");
				while(total_request.next())
				imgTotal = to!int(total_request.getString(1));

				auto request_before = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".imgs WHERE status='DONE';");
				while(request_before.next())
				img_before = to!int(request_before.getString(1));
				// see bottom for after request

				sql = ("select * from " ~ config.dbname ~ ".imgs WHERE Date IN (SELECT Date from test.imgs WHERE (Date BETWEEN '" ~ dateStart.toISOExtString() ~ "' AND '" ~ dateEnd.toISOExtString() ~ "')) AND status IS NULL"); 
			}
				auto newimages = db.stmt.executeQuery(sql); // Request for NO Value in field
				//writeln(sql);
				//readln;


				while(newimages.next()) // all this datas we would use in foreach loop
				{
					dbdata.id = newimages.getString(1);
					dbdata.url = newimages.getString(4);
					dbdata.name = newimages.getString(6);
					dbdata.myalias = newimages.getString(10);

					dbdata.month = newimages.getString(11);
					dbdata.year = newimages.getString(12);

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
					

					if (dbdata.url.checkLink) // if link alive	
						{			
							string resultPath;
							// create full path for destination dir
							resultPath = buildPath(config.rootImgsPath, dbdata.myalias, dbdata.year[2..4] ~ dbdata.month);
							

							if(!exists(buildPath(resultPath))) // from year we need last 2 digits
							{
								makeDir(resultPath); // stand alone function
							}

							writeln("destination dir exists: ", resultPath);

							try
							{
								download(dbdata.url, buildPath(config.rootImgsPath, dbdata.myalias, dbdata.year[2..4] ~ dbdata.month, dbdata.name));
								readln;
								writefln("Downloading: %s\n | %d / %d", dbdata.url, imgCount, imgTotal);
								
								string sqlupdate = ("UPDATE " ~ config.dbname ~ ".imgs SET status='DONE' WHERE id='" ~ dbdata.id ~ "'");
								auto rs = db.stmt.executeUpdate(sqlupdate);
							}

							catch (Exception e)
							{
								writeln("Can't download!");
								writeln(e.msg);
							}							

						}

					}
			
		}

		catch(Exception ex)
		{
			writeln(ex.msg);
			writeln("Can't get IMGs with status NULL");
		}



	}



}