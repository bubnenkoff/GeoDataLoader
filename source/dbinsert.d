module dbinsert;

import std.stdio;
import std.file;
import std.string;
import std.array;
import std.conv;
import std.regex;
import std.path;
import std.range;
import std.format;
import std.algorithm;
import std.datetime;
import std.parallelism;
import std.zip;
import colorize;
import vibe.d;

//import dbconnect;
import seismodownload;
//import ddbc.all;
import parseconfig;
import dbconnect;

//DBConnect db = new DBConnect();

class DataBaseInsert
{
	Config config;
	DBConnect db;
	
	this(Config config, DBConnect db)
	{
		this.config = config;
		this.db = db;
	}


	 void EQInsert(EQ[] eqs) // getting EQ data and pasting them. Because instance is already exists!
	 	{		

	 	 //EQ[] eqs;	
			try 
				{
					string eq_before;
					auto request_before = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".eq");
					while(request_before.next())
							eq_before = request_before.getString(1);

					foreach(eq; eqs)
					{
						//simple insert
						//string sqlinsert = ("INSERT INTO " ~ parseconfig.dbname ~ "." ~ parseconfig.dbtablename_eq ~ "(DateTime, Points, Lat, Lon, Magnitude, Depth, Region) VALUES (" "'"~ eq.time ~ "',"  ~ "GeomFromText('POINT(" ~ eq.lat ~ " " ~ eq.lon ~ ")'," ~ parseconfig.dataproj ~ ")," ~ eq.lat ~ ", " ~ eq.lon ~ ", " ~ eq.magnitude ~ ", " ~ eq.depth ~ ", " ~ "'" ~ eq.region ~ "');");
						
						// insert and update
						string sqlinsert = ("INSERT INTO " ~ config.dbname ~ ".eq " ~ "(Date, Time, Lat, Lon, Magnitude, Depth, Region, Type) VALUES (" "'" ~ eq.date ~ "', '" ~ eq.time ~ "',"  ~ eq.lat ~ ", " ~ eq.lon ~ ", " ~ eq.magnitude ~ ", " ~ eq.depth ~ ",'" ~  eq.region ~ "', '" ~ eq.type ~ "'" ~ ") " ~ " ON DUPLICATE KEY UPDATE Lat= " ~ eq.lat ~ ", Lon=" ~ eq.lon ~ ", Magnitude=" ~ eq.magnitude ~ ", Depth=" ~ eq.depth ~ ", Region='" ~ eq.region ~ "';").replace("\"\"","\"");
						//writeln(sqlinsert);
					 	auto rs = db.stmt.executeUpdate(sqlinsert);

					 }
					
					string eq_after;
					auto request_after = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".eq;");
					while(request_after.next())
						eq_after = request_after.getString(1);

					auto delta = (to!int(eq_after)) - (to!int(eq_before));
					cwritefln("Total in DB: %s | New added: %s\n".color(fg.yellow), eq_before, delta);
					
				}

			catch (Exception ex)
				{
						cwriteln("Can't INSERT data to the table!".color(fg.red));
						writeln(ex.msg);
						return;
			 	}
		}

		void GeomagneticInsert(string [] sqlinserts) 
		{
			try
			{
				string geomagnetic_before;
				auto request_before = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".geomagnetic");
				while(request_before.next())
				geomagnetic_before = request_before.getString(1); // one = data 
				foreach(sql;sqlinserts)
				{
					auto rs = db.stmt.executeUpdate(sql);
			
				}

				string geomagnetic_after;
				auto request_after = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".geomagnetic");
				while(request_after.next())
					geomagnetic_after = request_after.getString(1);

				auto delta = (to!int(geomagnetic_after)) - (to!int(geomagnetic_before));

				cwritefln("Total in DB: %s | New added: %s\n".color(fg.yellow), geomagnetic_before, delta);
			}

			catch(Exception e)
			{
				writeln("Error in GeomagneticInsert section");
				writeln(e.msg);
			}

		}

		void IMGsInsert(string [] fullimgurl, string [] imgnames)
		{
			try
			{
				writeln("IMGsInsert in DB function start...\n");

				int len = fullimgurl.length;
				int step = to!int(len/75);
			//	writefln("step = %s, len=%s", step, len);

				//statistic part
				string img_before;
				try {
						auto request_before = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".imgs");
						
						while(request_before.next())
						img_before = request_before.getString(1); // one = data 
					}
				catch (Exception ex)
					{
						writeln(ex.msg);
						writeln("Some error when SELECT COUNT(*) occur");
					}

				auto starttime1 = Clock.currTime(UTC());
				foreach (i, url; fullimgurl)
				{
					// we need extract Date and Time from URL
					// get file name first
					//URL currentURL = URL(url);
					// = currentURL.host;
					writeln("url before: ", url);
					// if url.dirName not wnd with slash we should add it
					//if(!url.dirName.endsWith(`/`))
					//	url.dirName = url.dirName ~ `/`;
					//writeln("url after: ", url.dirName);

					// because we getting URL, but not FullURL(src) that include file name 

					writeln("_Procesing URL: ", url.dirName);
					string myalias;

						// url_pattern in DB can not include trail slash, but URL for select have it, so mysql can't find pattern
						// we need be sure that ALL url_pattern in DB have trail slash
					string sqlselect = `SELECT myalias FROM ` ~ config.dbname ~ `.img_url_aliases WHERE url_pattern LIKE '%` ~ url.dirName ~ `%'`;
					writeln(sqlselect);
					//readln;
					auto rs_alias = db.stmt.executeQuery(sqlselect);					
					while(rs_alias.next())
					{
						myalias = (rs_alias.getString(1));
						writeln("myalias: ", myalias);
						//readln;
					}
					if(myalias.empty) // if no alias in DB then return unknown
					{
						myalias = "unknown";
						writeln("myalias: ", myalias);
						//readln;
					}


					string imgbaseName = url.baseName; // extract file name
					// imgbaseName_clean base name including only digits
						// some section have at start: HS5Q
						// drop it ([a-zA-Z]([0-9]){1,2}[a-zA-Z])
							string imgbaseName_clean = imgbaseName.replace("HS5Q","").replace("HS5O","").replaceAll(regex("[^0-9.]"), "").replace(".","").replace("-","");
					
					string imgbaseName_date = imgbaseName_clean[0..8];
						writeln("imgbaseName_date: ", imgbaseName_date);
						
					//writeln("imgbaseName_clean --> ", imgbaseName_clean);
					//writeln("imgbaseName_date --> ", imgbaseName_date);
					string imgbaseName_time = imgbaseName_clean[8..12];
						writeln("imgbaseName_time: ", imgbaseName_time);
						// HACK!
						// if we insert in db 0600 it's become 00:06:00 not 06:00:00
						// in some date we can do slicing more then ..12 in come not
						// so we append 00 at the end of all time
						imgbaseName_time = imgbaseName_time ~ "00";
					//writeln(imgbaseName_clean);
					//writeln(imgbaseName_date);
					//writeln(imgbaseName_time);
				
		

					//working string! DST is dropped!
					//string sqlinsert = ("INSERT INTO " ~ parseconfig.dbname ~ ".imgs" ~ "(src, dst) VALUES (" "'"~ url ~ "', "~ "'"~ imgnames[i] ~ "')" );
					// year and moth we strip from filename. They are need to create catalogs on FS
					string _year;
					string _month;


					try 
					{
						//small hack to drop letters. Stay only digits. some names have letters at start
						_year = replaceAll(imgnames[i].replace("HS5Q","").replace("HS5O",""),regex("[^0-9]"),"")[0..4];
						_month = replaceAll(imgnames[i].replace("HS5Q","").replace("HS5O",""),regex("[^0-9]"),"")[4..6];

							writeln("_year", _year);
							writeln("_month", _month);
					}
					catch (Exception e)
					{
						writeln("Can't extract Year and Month from file name: ", imgnames[i]);
						writeln(e.msg);
					}

					//writeln("---------+----------");
					//writeln(_year);
					//writeln(_month);
					//readln;
					string sqlinsert; // url.dirName return url without trail slash, so we need to add it. see: url.dirName ~ '/'
					try 
					{
						sqlinsert = ("INSERT INTO " ~ config.dbname ~ ".imgs" ~ "(src, url, myalias, name, Date, Time, year, month) VALUES (" "'"~ url ~ "', '" ~ url.dirName ~ '/' ~ "','" ~ myalias ~ "', '"~ imgnames[i] ~ "', '" ~ imgbaseName_date ~ "', '" ~ imgbaseName_time ~ "', '" ~ _year ~ "', '" ~ _month ~ "')" ~ " ON DUPLICATE KEY UPDATE src =""'" ~ url ~ "'");
						auto rs = db.stmt.executeUpdate(sqlinsert);
					}
					catch (Exception e)
					{
						writeln("Can't Insert in DB SQL string: ");
						writeln(sqlinsert);
						writeln(e.msg);
					}
				}

				string img_after;
				auto request_after = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".imgs");
				while(request_after.next())
					img_after = request_after.getString(1);

				auto delta = (to!int(img_after)) - (to!int(img_before));

				auto resulttime1 = Clock.currTime(UTC()) - starttime1;

				cwritefln("Total in DB: %s | New added: %s".color(fg.yellow), img_before, delta);
				cwritefln("Insert time (ON DUPLICATE UPDATE): %s".color(fg.yellow), resulttime1);
			}

			catch(Exception e)
			{
				writeln("Error in IMGsInsert");
				writeln(e.msg);
			}


		}


	void solarindexinsert(string [] sqlinsert)
	{
		try
		{
			foreach (sql; sqlinsert)
			{
				auto rs = db.stmt.executeUpdate(sql);
			}
		}

		catch(Exception e)
		{
			writeln("Error in during pasting data to SQL in section solarindexinsert");
			writeln(e.msg);
		}
	}


	void dgdindexinsert(string [] sqlinsert)
	{
		try
		{
			writeln("geomagnetic_index (part of HTMP) index");
			int count_before;
			int count_after;
			auto total_before = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".geomagnetic_index;");
			while(total_before.next())
			count_before = to!int(total_before.getString(1));	

			foreach (sql; sqlinsert)
			{
				auto rs = db.stmt.executeUpdate(sql);
			}

			auto total_after = db.stmt.executeQuery("select COUNT(*) from " ~ config.dbname ~ ".geomagnetic_index;");
			while(total_after.next())
			count_after = to!int(total_after.getString(1));	

			int delta = (to!int(count_after)) - (to!int(count_before));
			cwritefln("Total in DB: %s | New added: %s".color(fg.yellow), count_before, delta);

				// hack to write it's to text file:
				string all_data;
				//DO NOT EDIT FORMATING
				string header = `Index:	B									M									H									P							
Date/Time	3	6	9	12	15	18	21	24		3	6	9	12	15	18	21	24		3	6	9	12	15	18	21	24		3	6	9	12	15	18	21	24` ~ "\n";

				auto all_index = db.stmt.executeQuery("select * from " ~ config.dbname ~ ".geomagnetic_index;");
				while(all_index.next())
					all_data ~= ((Date.fromSimpleString((all_index.getString(1)))).toISOExtString).replace("-",".") ~ "\t " ~ (all_index.getString(2).replace(" ", "\t") ~ "\t ") ~ all_index.getString(3).replace(" ", "\t") ~ "\t " ~ all_index.getString(4).replace(" ", "\t") ~ "\t " ~ all_index.getString(5).replace(" ", "\t") ~ "\n";

				File file = File(`sunIndex.txt"`, "w");
				file.write(header ~ all_data.replace(" ", "\t").replace("\t","\t"));


		}

		catch(Exception e)
		{
			writeln("Error in dgdindexinsert");
			writeln(e.msg);
		}
	}


	void getFTPLogContent(string [] logfullname)
	{
		// TODO: add intersection of zip and logs to prevent double insert
		foreach (file; logfullname)
		{
			if (file.endsWith("zip"))
			{
				auto zip = new ZipArchive(file.read);
				foreach(ArchiveMember am; zip.directory)
				{
					// we are passing FulFileName to be able than detect if what kind of logs we are pasting (shgm3 or not)
					loginsert(file.replace("zip", "log"), cast(string)zip.expand(am)); //pass unpacked element of archive. Replace zip to log because it's already unpacked
				}
			}

			if(file.endsWith("log"))
			{
				// we are passing FulFileName to be able than detect if what kind of logs we are pasting (shgm3 or not)
				string txtfile = readText(file);
				loginsert(file, txtfile);
			}

		}
	}

	void loginsert(string logfullname, string fcontent) // Tables with needed fields are create automatically! See code above. 
	{
		try
		{
			writefln("[LOGs from FTP]");
			string log_original = logfullname.baseName; // save original name
			// we mast to detect what kind of logs we are inserting shgm3 or no.
			// shgm3 logs are inserting in one table
			// adding case with "1" to prevent finding same pass
			if (logfullname.canFind(config.ftplocalpath)) // it's look like simple FTP LOGs
			{
				writeln("FTP standard logs");
				// we need split filename, to get from DESP-140101 ==> DESP AND from s1-DESP-140101 ==> S1-DESP
				// DO NOT CHANGE ORDER!!! OR WE WOULD CUT name FROM s1-DESP-140101 s1-DESP AND THEN CUT IT"S AGAIN!!!
				if (logfullname.baseName.countchars("-") == 1)
				{
					writeln("processing log: ",  logfullname);
					logfullname = logfullname.baseName.stripExtension.split("-")[0].replace("-","_"); //now we should give normal name for it. Ex: S1-ELISOVO-140511 -->  S1-ELISOVO
				}

				if (logfullname.baseName.countchars("-") == 2)
				{
					writeln("processing log: ",  logfullname);
					logfullname = logfullname.baseName.stripExtension.split("-")[0..2].join("-").replace("-","_"); //now we should give normal name for it. Ex: S1-ELISOVO-140511 -->  S1-ELISOVO
				}



				writeln("=>", logfullname);
				auto request_before = db.stmt.executeQuery("SELECT * FROM " ~ config.dbname ~ ".ftplogfiles WHERE name='" ~ log_original ~ "'");
				if(request_before.next() == false)
				{
					writefln("Do not in DB: %s", logfullname);		
					/////we need to check if table where we INSERT is exists!//////
					// this part if table DO NOT exists and we should create it!
					// FIXME: split should do splittings only after second "-", or tables may have different coloumns numbers
					auto dbshow = db.stmt.executeQuery("SHOW TABLES LIKE '" ~ logfullname ~ "';", );
				 	
				 	if(dbshow.next())
				 		cwritefln("Table: " ~ logfullname.color(fg.green) ~ " is exists");

				 	else
				 	{
					 	// Here we are checking numbers of colomns in text
					 	string[] lines = fcontent.splitLines();
					 	string head = lines[0].strip;
					 	string row = lines[0].split.map!(a=>format("`%s`, ", a)).join.chop.chop;
					 	int colnum = head.countchars(" "); // here we save number of columns

					 	// -1 REMOVED
					 	auto x = iota(0, colnum-1); // -1 to get actual number columns that we need
					 	string s_sequence_gen = to!string(x.map!(a => format("`S%s` VARCHAR(10) NULL DEFAULT NULL, ", a)).join).chop.chop ~ ");";	
						
					 	string create_d_t_sql = ("CREATE TABLE IF NOT EXISTS `" ~ logfullname ~ "` (`Date` DATE NULL DEFAULT NULL, `Time` TIME NULL DEFAULT NULL, ");
					 	auto rs = db.stmt.executeUpdate(create_d_t_sql ~ s_sequence_gen);
					 	// OK table with needed number of columns created

					}


				writeln("Processing standard insert operation...");
			 	foreach(line; fcontent.splitLines)
			 	{
			 		string row = line.split.map!(a=>format("'%s', ", a)).join.chop.chop; // constructor for S1 ... S(n)
			 		// ignore because it's rare situation when the data is already in the table
			 		if(config.ftp_load_only_1_minuts == "true")
			 		{
			 			string check_time = (line.split(" ")[1]).split(":")[2]; // getting last part of 12:14:_15_ now we check if it's one minute date.
			 			if(check_time != "00") continue;
			 		}

			 		//string sql = "INSERT IGNORE INTO test." ~ logfullname ~ " VALUES(" ~ row ~ ");";
			 		string sql = "INSERT IGNORE INTO " ~ config.dbname ~ "." ~ logfullname ~ " VALUES(" ~ row ~ ");";
			 		//Thread.sleep( dur!("msecs")( 200 ) );
			 		auto rs = db.stmt.executeUpdate(sql);

			 	}

		 	
			 	// Now we should write that data was processed
			 	//string sqlinsert = format("INSERT IGNORE INTO " ~ config.dbname ~ ".ftplogfiles (Name, Status) VALUES ('" ~ log_original ~ "', 'Done')");
			 	string sqlinsert = format("INSERT IGNORE INTO " ~ config.dbname ~ ".ftplogfiles (Name, Status) VALUES ('" ~ log_original ~ "', 'Done')");
				auto rs = db.stmt.executeUpdate(sqlinsert);
				core.thread.Thread.sleep( dur!("msecs")(300));	
			}

		 	else
		 		cwritefln("%s is already in DB", log_original.color(fg.red));
		}

		// we mast detect what kind of logs we are inserting shgm3 or no.
		// shgm3 logs are inserting in one table
		if (logfullname.canFind(config.ftplocalpath_shgm3)) // it's look like simple shgm3 LOGs
		{
			writeln("FTP shgm3");
			auto request_before = db.stmt.executeQuery("SELECT * FROM " ~ config.dbname ~ ".shgm3_stat WHERE name='" ~ log_original ~ "'");
			if(request_before.next() == false)
			{
				writeln(logfullname);
				writeln("Processing insert operation...");
				foreach(line; fcontent.splitLines)
				{
					string row = line.split.map!(a=>format("'%s', ", a)).join.chop.chop; // constructor for S1 ... S(n)
					// ignore because it's rare situation when the data is already in the table
					if(config.ftp_load_only_1_minuts == "true")
					{
						string check_time = (line.split(" ")[1]).split(":")[2]; // getting last part of 12:14:_15_ now we check if it's one munute date. We need at to ton past all
						if(check_time != "00") continue;
					}

					string sql = "INSERT IGNORE INTO " ~ config.dbname ~ ".shgm3 VALUES(" ~ row ~ ");";
					//writeln(sql);
				 	auto rs = db.stmt.executeUpdate(sql);
				}

				// Now we should write that data was processed
			 	string sqlinsert = format("INSERT IGNORE INTO " ~ config.dbname ~ ".shgm3_stat (Name, Status) VALUES ('" ~ log_original ~ "', 'Done')");
				auto rs = db.stmt.executeUpdate(sqlinsert);
				core.thread.Thread.sleep( dur!("msecs")(3000));	
			}
			
			else
			cwritefln("%s is already in DB", log_original.color(fg.red));


			}


	}

		catch(Exception e)
		{
			writeln("Error in loginsert");
			writeln(e.msg);
		}

	}


	void log_shgm3_insert(string logname, string fcontent)
	{
		/*
		try
		{	
			writefln("[LOGs SHGM3 from FTP]");
			Date logDate; // here we will store Date of latest log. Then get minus one day. And upload this file
			 // we need convert every log name to date. And compare it with current time. Coday log we may be get new data. 
			 // So we will upload it's multiple times (if it's changes -- the best variant).
			Date curdt = cast(Date)(Clock.currTime()); // name pattern is yymmdd (150101)
			string curdt_pattern = curdt.toISOString()[2..$]; // 20150210 --> 150210
			//writeln(curdt_pattern);
			foreach (i, logname; lognames)
			{
				writeln(logname);
				auto request_before = stmt.executeQuery("SELECT * FROM " ~ config.dbname ~ ".shgm3_stat WHERE name='" ~ logname ~ "'");
				if(request_before.next() == false)
				{
					writefln("Do not in DB: %s", logname);
					writefln(logfullname[i]);

					auto file = File(logfullname[i], "r");
					foreach (line; file.byLine)
	           		  {
	              		 char [][] colomns = line.split(" ");
	              		  string sqlinsert = format("INSERT INTO " ~ config.dbname ~ ".shgm3 (Date, Time, S1, S2, S3, S4) VALUES (" ~ "'"~ colomns[0] ~ "', '" ~ colomns[1] ~ "', " ~ "'"~ colomns[2] ~ "', " ~ "'"~ colomns[3] ~ "', '"~ colomns[4] ~ "', '"~ colomns[5] ~ "') " ~ "ON DUPLICATE KEY UPDATE Date = '" ~ colomns[0] ~ "', Time = '" ~ colomns[1] ~ "'");
	              		  //writefln(sqlinsert);
	               		  //stupid way to load only one one data string per minute
							if (config.ftp_load_only_1_minuts == "true")
							{
								if (colomns[1].split(":")[2].canFind("00")) //check time if seconds 00 than insert
								{
									auto rs = stmt.executeUpdate(sqlinsert);
								}
								else
									continue;
							}
							// if var is false we insert all date!
							else
							auto rs = stmt.executeUpdate(sqlinsert);
	               		  //FIX ME
	               		  // NEED UNIQ INDEX from two colomns!!!
	          		  }

	          		// trick! We will not put DONE status for current date, because file with date may be update!
	          		if (!logname.canFind(curdt_pattern)) // skip current date!
	          		{
	                	string sqlinsert = format("INSERT IGNORE INTO " ~ config.dbname ~ ".shgm3_stat (Name, Status) VALUES ('" ~ logname ~ "', 'Done')");
	                	//writefln(sqlinsert);
	                	auto rs = stmt.executeUpdate(sqlinsert);
	                }

				}
				else
					cwritefln("Already in DB: ", logname.color(fg.red));	
			}
		}
		
		catch(Exception e)	
		{
			writeln("Error in log_shgm3_insert");
			writeln(e.msg);
		}
		*/
	}

	void kakiokajma_insert(string name, string type, string razdel, string podrazdel, string status) //tellurika // name = date
	{
		try
		{
			
			string sqlinsert = ("INSERT IGNORE INTO " ~ config.dbname ~ ".tellurika (file, type, date, razdel, podrazdel, status) VALUES ('"~ name ~ "_" ~ podrazdel ~ ".png', '" ~ type ~ "', '" ~ name ~ "', '" ~ razdel ~ "', '" ~ podrazdel ~ "' , '" ~ status ~"');");
			//writeln(sqlinsert);
			//readln;
			//writeln("---------------");
			db.stmt.executeUpdate(sqlinsert);
		}

		catch(Exception e)
		{
			writeln("Error in kakiokajma_insert section"); //tellurika
			writeln(e.msg);
		}

	}
	
	
}