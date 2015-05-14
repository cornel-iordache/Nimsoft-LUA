-- script:      removeOldQosData
-- purpose:     this script will delete all qos-data-sources and their data which have not delivered qos-values in a specified time
-- author:      chris.luekermann@nimsoft.com
-- date:        2014/05/13
-- (c) 2014 Nimsoft
iDays = 7   -- delete qos-sources which did not deliver values in the past X days. Only specify FULL days here
sDatabaseType = "sqlserver" -- specify the database type you're using. Valid values: sqlserver | mysql
-- if you have oracle, write me a e-mail
bHot = 0   -- set this to 0 if you do not want the script to perform any real modifications

-- do not modify after this line unless you know what you're doing --
database.open("provider=nis;database=nis;driver=none")   -- open the database

 -- first, find all used RN_TABLES
sSql = "select distinct r_table from s_qos_data"
tRtables = database.query(sSql )

if bHot == 0 then
   print( "-- table count: "..#tRtables.." RN-Tables" )
   print( "-- the following output is valid SQL, you can copy this and execute it in your database shell manually" )
else
   print( "housekeeping will delete data from "..#tRtables.." RN-Tables" )
end 

-- now iterate over all rn_tables and determine orphaned qos-data 
for iIx, tRow in pairs(tRtables) do
   sDelQuery = ""
   if sDatabaseType == "sqlserver" then   
         sDelQuery = "delete from s_qos_data where table_id in (select table_id from "..tRow["r_table"].." group by table_id having datediff(day, max(sampletime), getdate() ) > "..iDays.." );"
      end
      if sDatabaseType == "mysql" then
         sDelQuery = "delete from s_qos_data where table_id in (select table_id from "..tRow["r_table"].." group by table_id having max(sampletime) < date_add( now(), INTERVAL -"..iDays.." DAY);"
   end

   if bHot ~= 1 then
      print( sDelQuery )
   else
      print( "deleting orphaned qos-data for table "..tRow["r_table"] )
      database.query(sDelQuery)
   end

   sDelUndeliveredQuery = "delete from s_qos_data where r_table='"..tRow["r_table"].."' and table_id not in (select distinct table_id from "..tRow["r_table"]..")"
   if bHot ~= 1 then
      print( sDelUndeliveredQuery )
   else
      print( "deleting never delivered qos-data for table "..tRow["r_table"] )
      database.query( sDelUndeliveredQuery )
   end
end

print( "-- housekeeping done." )

database.close()





