/**
 * DDBC - D DataBase Connector - abstraction layer for RDBMS access, with interface similar to JDBC. 
 * 
 * Source file ddbc/drivers/pgsqlddbc.d.
 *
 * DDBC library attempts to provide implementation independent interface to different databases.
 * 
 * Set of supported RDBMSs can be extended by writing Drivers for particular DBs.
 * Currently it only includes MySQL driver.
 * 
 * JDBC documentation can be found here:
 * $(LINK http://docs.oracle.com/javase/1.5.0/docs/api/java/sql/package-summary.html)$(BR)
 *
 * This module contains implementation of PostgreSQL Driver
 * 
 *
 * You can find usage examples in unittest{} sections.
 *
 * Copyright: Copyright 2013
 * License:   $(LINK www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Author:   Vadim Lopatin
 */
module ddbc.drivers.pgsql;

import std.algorithm;
import std.conv;
import std.datetime;
import std.exception;
import std.stdio;
import std.string;
import std.variant;

version(USE_PGSQL) {
    
    
    version (Windows) {
        pragma (lib, "libpq");
        //pragma (lib, "pq");
    } else version (linux) {
        pragma (lib, "pq");
    } else version (Posix) {
        pragma (lib, "pq");
    } else version (darwin) {
        pragma (lib, "pq");
    } else {
        pragma (msg, "You will need to manually link in the LIBPQ library.");
    } 


    string bytesToBytea(byte[] bytes) {
        if (bytes is null)
            return null;
        string res;
        foreach(b; bytes) {
            if (b == 0)
                res ~= "\\0";
            else if (b == '\r')
                res ~= "\\r";
            else if (b == '\n')
                res ~= "\\n";
            else if (b == '\t')
                res ~= "\\t";
            else if (b == '\\')
                res ~= "\\\\";
            else
                res ~= cast(char)b;
        }
        return res;
    }

    string ubytesToBytea(ubyte[] bytes) {
        if (bytes is null)
            return null;
        string res;
        foreach(b; bytes) {
            if (b == 0)
                res ~= "\\0";
            else if (b == '\r')
                res ~= "\\r";
            else if (b == '\n')
                res ~= "\\n";
            else if (b == '\t')
                res ~= "\\t";
            else if (b == '\\')
                res ~= "\\\\";
            else
                res ~= cast(char)b;
        }
        return res;
    }

    byte[] byteaToBytes(string s) {
        if (s is null)
            return null;
        byte[] res;
        bool lastBackSlash = 0;
        foreach(ch; s) {
            if (ch == '\\') {
                if (lastBackSlash) {
                    res ~= '\\';
                    lastBackSlash = false;
                } else {
                    lastBackSlash = true;
                }
            } else {
                if (lastBackSlash) {
                    if (ch == '0') {
                        res ~= 0;
                    } else if (ch == 'r') {
                        res ~= '\r';
                    } else if (ch == 'n') {
                        res ~= '\n';
                    } else if (ch == 't') {
                        res ~= '\t';
                    } else {
                    }
                } else {
                    res ~= cast(byte)ch;
                }
                lastBackSlash = false;
            }
        }
        return res;
    }

    ubyte[] byteaToUbytes(string s) {
        if (s is null)
            return null;
        ubyte[] res;
        bool lastBackSlash = 0;
        foreach(ch; s) {
            if (ch == '\\') {
                if (lastBackSlash) {
                    res ~= '\\';
                    lastBackSlash = false;
                } else {
                    lastBackSlash = true;
                }
            } else {
                if (lastBackSlash) {
                    if (ch == '0') {
                        res ~= 0;
                    } else if (ch == 'r') {
                        res ~= '\r';
                    } else if (ch == 'n') {
                        res ~= '\n';
                    } else if (ch == 't') {
                        res ~= '\t';
                    } else {
                    }
                } else {
                    res ~= cast(byte)ch;
                }
                lastBackSlash = false;
            }
        }
        return res;
    }
    

    // C interface of libpq is taken from https://github.com/adamdruppe/misc-stuff-including-D-programming-language-web-stuff/blob/master/postgres.d
    

    extern(C) {
        struct PGconn {};
        struct PGresult {};
        
        void PQfinish(PGconn*);
        PGconn* PQconnectdb(const char*);
        PGconn *PQconnectdbParams(const char **keywords, const char **values, int expand_dbname);
        
        int PQstatus(PGconn*); // FIXME check return value
        
        const (char*) PQerrorMessage(PGconn*);
        
        PGresult* PQexec(PGconn*, const char*);
        void PQclear(PGresult*);
        
        
        int PQresultStatus(PGresult*); // FIXME check return value
        char *PQcmdTuples(PGresult *res);
        
        int PQnfields(PGresult*); // number of fields in a result
        const(char*) PQfname(PGresult*, int); // name of field
        
        int PQntuples(PGresult*); // number of rows in result
        const(char*) PQgetvalue(PGresult*, int row, int column);
        
        size_t PQescapeString (char *to, const char *from, size_t length);
        
        enum int CONNECTION_OK = 0;
        enum int PGRES_COMMAND_OK = 1;
        enum int PGRES_TUPLES_OK = 2;
        enum int PGRES_COPY_OUT = 3;             /* Copy Out data transfer in progress */
        enum int PGRES_COPY_IN = 4;              /* Copy In data transfer in progress */
        enum int PGRES_BAD_RESPONSE = 5;         /* an unexpected response was recv'd from the backend */
        enum int PGRES_NONFATAL_ERROR = 6;       /* notice or warning message */
        enum int PGRES_FATAL_ERROR = 7;          /* query failed */
        enum int PGRES_COPY_BOTH = 8;            /* Copy In/Out data transfer in progress */
        enum int PGRES_SINGLE_TUPLE = 9;          /* single tuple from larger resultset */
        
        int PQgetlength(const PGresult *res,
                        int row_number,
                        int column_number);
        int PQgetisnull(const PGresult *res,
                        int row_number,
                        int column_number);
        
        alias ulong Oid;
        
        Oid PQftype(const PGresult *res,
                    int column_number);
        Oid PQoidValue(const PGresult *res);
        
        int PQfformat(const PGresult *res,
                      int column_number);

        Oid PQftable(const PGresult *res,
                     int column_number);

        PGresult *PQprepare(PGconn *conn,
                            const char *stmtName,
                            const char *query,
                            int nParams,
                            const Oid *paramTypes);

        PGresult *PQexecPrepared(PGconn *conn,
                                 const char *stmtName,
                                 int nParams,
                                 const char * *paramValues,
                                 const int *paramLengths,
                                 const int *paramFormats,
                                 int resultFormat);

        PGresult *PQexecParams(PGconn *conn,
                               const char *command,
                               int nParams,
                               const Oid *paramTypes,
                               const char * *paramValues,
                               const int *paramLengths,
                               const int *paramFormats,
                               int resultFormat);

        char *PQresultErrorMessage(const PGresult *res);

        const int BOOLOID = 16;
        const int BYTEAOID = 17;
        const int CHAROID = 18;
        const int NAMEOID = 19;
        const int INT8OID = 20;
        const int INT2OID = 21;
        const int INT2VECTOROID = 22;
        const int INT4OID = 23;
        const int REGPROCOID = 24;
        const int TEXTOID = 25;
        const int OIDOID = 26;
        const int TIDOID = 27;
        const int XIDOID = 28;
        const int CIDOID = 29;
        const int OIDVECTOROID = 30;
        const int JSONOID = 114;
        const int XMLOID = 142;
        const int PGNODETREEOID = 194;
        const int POINTOID = 600;
        const int LSEGOID = 601;
        const int PATHOID = 602;
        const int BOXOID = 603;
        const int POLYGONOID = 604;
        const int LINEOID = 628;
        const int FLOAT4OID = 700;
        const int FLOAT8OID = 701;
        const int ABSTIMEOID = 702;
        const int RELTIMEOID = 703;
        const int TINTERVALOID = 704;
        const int UNKNOWNOID = 705;
        const int CIRCLEOID = 718;
        const int CASHOID = 790;
        const int MACADDROID = 829;
        const int INETOID = 869;
        const int CIDROID = 650;
        const int INT4ARRAYOID = 1007;
        const int TEXTARRAYOID = 1009;
        const int FLOAT4ARRAYOID = 1021;
        const int ACLITEMOID = 1033;
        const int CSTRINGARRAYOID = 1263;
        const int BPCHAROID = 1042;
        const int VARCHAROID = 1043;
        const int DATEOID = 1082;
        const int TIMEOID = 1083;
        const int TIMESTAMPOID = 1114;
        const int TIMESTAMPTZOID = 1184;
        const int INTERVALOID = 1186;
        const int TIMETZOID = 1266;
        const int BITOID = 1560;
        const int VARBITOID = 1562;
        const int NUMERICOID = 1700;
        const int REFCURSOROID = 1790;
        const int REGPROCEDUREOID = 2202;
        const int REGOPEROID = 2203;
        const int REGOPERATOROID = 2204;
        const int REGCLASSOID = 2205;
        const int REGTYPEOID = 2206;
        const int REGTYPEARRAYOID = 2211;
        const int UUIDOID = 2950;
        const int TSVECTOROID = 3614;
        const int GTSVECTOROID = 3642;
        const int TSQUERYOID = 3615;
        const int REGCONFIGOID = 3734;
        const int REGDICTIONARYOID = 3769;
        const int INT4RANGEOID = 3904;
        const int RECORDOID = 2249;
        const int RECORDARRAYOID = 2287;
        const int CSTRINGOID = 2275;
        const int ANYOID = 2276;
        const int ANYARRAYOID = 2277;
        const int VOIDOID = 2278;
        const int TRIGGEROID = 2279;
        const int EVTTRIGGEROID = 3838;
        const int LANGUAGE_HANDLEROID = 2280;
        const int INTERNALOID = 2281;
        const int OPAQUEOID = 2282;
        const int ANYELEMENTOID = 2283;
        const int ANYNONARRAYOID = 2776;
        const int ANYENUMOID = 3500;
        const int FDW_HANDLEROID = 3115;
        const int ANYRANGEOID = 3831;
        const int TYPTYPE_BASE = 'b';
        const int TYPTYPE_COMPOSITE = 'c';
        const int TYPTYPE_DOMAIN = 'd';
        const int TYPTYPE_ENUM = 'e';
        const int TYPTYPE_PSEUDO = 'p';
        const int TYPTYPE_RANGE = 'r';
        const int TYPCATEGORY_INVALID = '\0';
        const int TYPCATEGORY_ARRAY = 'A';
        const int TYPCATEGORY_BOOLEAN = 'B';
        const int TYPCATEGORY_COMPOSITE = 'C';
        const int TYPCATEGORY_DATETIME = 'D';
        const int TYPCATEGORY_ENUM = 'E';
        const int TYPCATEGORY_GEOMETRIC = 'G';
        const int TYPCATEGORY_NETWORK = 'I';
        const int TYPCATEGORY_NUMERIC = 'N';
        const int TYPCATEGORY_PSEUDOTYPE = 'P';
        const int TYPCATEGORY_RANGE = 'R';
        const int TYPCATEGORY_STRING = 'S';
        const int TYPCATEGORY_TIMESPAN = 'T';
        const int TYPCATEGORY_USER = 'U';
        const int TYPCATEGORY_BITSTRING = 'V';
        const int TYPCATEGORY_UNKNOWN = 'X';

    
    }
    
} else { // version(USE_PGSQL)
    immutable bool PGSQL_TESTS_ENABLED = false;
}

