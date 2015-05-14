-- Resuscitate dead wasp.--
-----------------------------

--this script runs from a schedule on the nas and will deactivate and activate wasp
--Steps description
  -- call wasp
  -- call UMP robot   
  -- then invoke probe_deactivate on the controller of UMP robot
  --Wait WASP and DAP to died.
         -- wait is how long (seconds) we wait wasp probe to stop
  -- invoke probe_activate
  
--------------------------------
--Script can be corelate with E2E login to nimsoft portal . At fail run action -> run the script
 


probe = 'wasp' 
robot = '/Syntax/SYNNIMSOFT1/synnimsoft2' -- UMP server, this could be picked up from the alarm. E2E for portal,alarm->run the script
wait = 30 -- time to let probe stop
param = pds.create()
pds.putString (param, "name", probe)

-- Stop it first
result, rc = nimbus.request (robot.."/controller", "probe_deactivate", param)
if rc == 0 then
print "restart command sent OK"
else
print ("Failed, nimbus error code: ",rc)
end

-- wait for a bit
sleep (wait)

-- restart
result, rc = nimbus.request (robot.."/controller", "probe_activate", param)
if rc == 0 then
print "restart command sent OK"
else
print ("Failed, nimbus error code: ",rc)
end
-----We 
