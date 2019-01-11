-- INSTRUCTIONS:
-- 1.  Copy this code into the translator of a "From Translator, To Channel" channel
-- 2.  Create the following 2 email rules:
 
-- ALERTS:
-- Source Type: [All Entries]
-- Type:        Informational
-- Text Query:  /MIN-MAX ALERT/
 
 
-- DAILY REPORT:
-- Source Type: [All Entries]
-- Type:        Informational
-- Text Query:  /DAILY SYSTEM REPORT/
 
params = {alert={max={}, min={}}, daily={}}
 
-- These are the min/max values that trigger an alert
params.alert.max.TotalErrors =        5
params.alert.max.TotalServiceErrors = 5
params.alert.min.DiskFreeMB =         1024
params.alert.max.LogsUsedMB =         2048
params.alert.max.OpenFD =             100
params.alert.max.ThreadCount =        50
params.alert.max.CPUPercent =         90
params.alert.max.SocketsOpen =        1
params.alert.max.Queued =             50
params.alert.max.QueuedType =         "Across all channels"
 
 
 
function main()
   
   -- This is a channel that will query and store stats on the
   -- health of IGUANA.  We will set some configurable thresholds
   -- and when they are exceeded, create log messages that can
   -- be used for alerting. It can also send a daily emails.
 
   iguana.stopOnError(false)
 
   -- Get stats from IGUANA
   local Status = iguana.status()
   
   local S = xml.parse{data=Status}
   
   -- Loop through items we want to be alerted about
   local logMsg = ''
         
   for i,j in pairs(params.alert.max) do
      if i:sub(1,6) ~= 'Queued' then
         if tonumber(S.IguanaStatus[i]:nodeValue()) > j then
            logMsg = logMsg .. i .. ' has exceeded its threashold\n'
         end
      elseif i == 'Queued' then
         local queued = 0
         for y=1, S.IguanaStatus:childCount("Channel") do
            if params.alert.max.QueuedType == "Across all channels" then
               queued = queued + tonumber(
                  S.IguanaStatus:child('Channel', y).MessagesQueued:nodeValue()
               )
            else
               if tonumber(
                     S.IguanaStatus:child('Channel', y)
                     .MessagesQueued:nodeValue()) > params.alert.max.Queued then
                  logMsg = logMsg .. 'Channel: ' ..
                     S.IguanaStatus:child('Channel', y).Name ..
                     ' has exceeded its queued message threashold\n'
               end
            end
         end
         if params.alert.max.QueuedType == "Across all channels" then
            if queued > params.alert.max.Queued then
               logMsg = logMsg ..
                  'The total queue count has ' ..
                  'exceeded its queued message threashold\n'
            end
         end
      end
   end 
   for i,j in pairs(params.alert.min) do 
      if tonumber(S.IguanaStatus[i]:nodeValue()) < j then
         logMsg = logMsg .. i .. ' is below its threashold\n'
      end
   end  
 
   -- Generate log message if needed.
   if logMsg ~= '' then 
      logMsg = 'MIN-MAX ALERT: \n\n' .. logMsg
      iguana.logInfo(logMsg)
   end
   
   
end