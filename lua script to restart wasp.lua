
probe = 'wasp' -- put probe name here
robot = '/Syntax/SYNNIMSOFT1/synnimsoft2' -- this could also be picked up from the alarm
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
