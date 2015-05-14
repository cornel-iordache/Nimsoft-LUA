--This script runs from a schedule on the nas and will test a number of local probes 
--sending a probe_activate to any that are dead. It does this a max of once per half hour per probe. 
--It sends an alarm of escalating severity on every subsequent event for the same probe.

-- aed (Automatic Electronic Defibrillator)
--This script suppose to be a .bat  :)
-- yes,yes,yes you heard well .bat in CA UIM :D
-- request for create a .bat has come for our architect .. not, not buildings architect ...IT one :D ..scripter too
-- resuscitate dead probes.
--
-- call the _status method on a list of probes. If one fails to reply
-- then invoke probe_activate on the controller against the dead probe.
--
-- This will happen a (configurable)  max of every half hour, not more because
-- there may be a good reason why the probe is dead

-- delay is how long (seconds) we wait before we try to restart it again
-- half hour is my suggested value.
delay       = (30 * 60)

-- this is a list of probes to check, httpd makes a nice test case
resuscitate = {"e2e", "cdm", "controler", "dap", "nis", "nas, "data_engine", "sqlserver"}

controller = nimbus.request("controller","get_info")
print ("Robotname: ",controller.robotname)

for _,probe in pairs (resuscitate) do
   status = nimbus.request(probe,"_status")
   if status == nil then
      nextkick = getvariable("nextkick_"..probe)
      -- check we did not shock this one recently
      if nextkick ~= nil and timestamp.now () < tonumber(nextkick) then
          print ("probe ",probe," still dead, time now is ",timestamp.now()," waiting until ",nextkick," to kick it again")
      else
         print ("probe: ",probe," needs a shock")
         -- probe did not reply, probably dead, time to get the paddles out
         -- charging...
         param = pds.create()
         pds.putString (param, "name", probe)
         -- clear
         result, rc = nimbus.request ("controller", "probe_activate", param)
         if rc == 0 then
            print "restart command sent OK"
         else
            print ("Failed, nimbus error code: ",rc)
         end
         -- store a variable when we may next kick it
         setvariable("nextkick_"..probe, (timestamp.now()+delay) )
         -- see how frequently we are kicking it and send an appropriate level alarm
         kicked = getvariable("status_"..probe)
         if kicked == nil then
            kicked = 0
         else
            kicked = tonumber(kicked)
         end
         kicked = kicked + 1
         if kicked == 6 then kicked = 5 end
         nimbus.alarm (kicked, "sent "..kicked.." restarts to probe: "..probe, "restart/"..probe)
         setvariable("status_"..probe, kicked)
      end
   else
      -- print ("probe: ",probe," all OK")
      setvariable("status_"..probe, 0)
   end
end
