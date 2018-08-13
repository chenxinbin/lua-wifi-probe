print()
aps = {}
mobs = {}

CH = 1
LOOP = 0


function upload()
    print(station_cfg)
    print("connect AP (" ..  station_cfg.ssid ..")")
    wifi.monitor.stop()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    wifi.sta.connect()

    tmr.alarm(2, 2000, tmr.ALARM_AUTO, checkconn)
end

function checkconn()
  if wifi.sta.getip()==nil then
      print "Not connected to wifi."
      if(wifi.sta.status()==0) then
        wifi.sta.connect()
      end
  else
    print "Already wifi."
    -- Connected to the wifi
    tmr.stop(2)

    --UPLOAD UDP packets
    data = ""
    for key, value in pairs(mobs) do  
          data = data .. key .."|" .. value .. "\n"
    end 
    

    srv = net.createUDPSocket()
    srv:send(2347,"192.168.2.100", data)
    srv:close()
    
    tmr.alarm(1, 1000, tmr.ALARM_AUTO, scan)

  end
end



function scan()
    wifi.monitor.stop()
    
    if(CH>15)  then
        CH=1
        LOOP=LOOP+1
    end
    print("CH=="..CH .." LOOP="..LOOP)
    if(CH==1 and LOOP>2) then
        --Connect WIFI , UPLOAD DATA
        tmr.stop(1)

        upload()
        LOOP = 0
    end

    --time = 
    sec, usec, rate = rtctime.get()


    print("switch channel=" .. CH)    
    wifi.monitor.channel(CH)
    CH=CH+1
    wifi.monitor.start(function(pkt)
        ftype = pkt:frame_byte(1)
        srcmac =  pkt.srcmac_hex
        dstmac = pkt.dstmac_hex
    
        if(ftype==0x80) then
            if aps[pkt.bssid_hex] == nil then
                print ('Beacon: ' .. srcmac .. " /" .. dstmac .. " /"  .. pkt.bssid_hex .. " '" .. pkt[0] .. "' ch "  ..  pkt[3]:byte(1) .. "," .. pkt.rssi)
                aps[pkt.bssid_hex] = pkt[0]
            end
        elseif(ftype==0x40) 
        then
            k = srcmac .. '|' .. dstmac
            if mobs[k] == nil then
                mobs[k] = pkt.rssi .. '|' .. sec
                print ("Probe request,"  .. srcmac .. " /" .. dstmac.. " /" ..  " /"  .. pkt.bssid_hex .. " '" .. pkt[0] .. "' ch " ..  pkt.channel .. "," .. pkt.rssi)
            end
        elseif(ftype==0xd0 ) --
        then
            k = srcmac .. '|' .. dstmac
            if mobs[k] == nil then
                mobs[k] = pkt.rssi .. '|' .. sec
                print ("Action," .. srcmac .. " /" .. dstmac .. " /" .. " /"  .. pkt.bssid_hex .. " '" ..  "' ch " .. pkt.channel .. "," .. pkt.rssi)
            end
        elseif(ftype==0x50) --
        then
            --print ("Probe response," .. pkt.type .."," .. srcmac .. " /" .. dstmac .. " /" .. " /"  .. pkt.bssid_hex .. " '" .. pkt[0] .. "' ch " .. ftype .. "," .. pkt.rssi)
        elseif(ftype==0x02 ) --
        then
            k = srcmac .. '|' .. dstmac
            if mobs[k] == nil then
                mobs[k] = pkt.rssi .. '|' .. sec
                print ("Probe request," .. srcmac .. " /" .. dstmac .. " /" .. " /"  .. pkt.bssid_hex .. " '" ..  "' ch " .. pkt.channel .. "," .. pkt.rssi)
            end
        else
            print (ftype.."," .. pkt.type .."," .. srcmac .. " /" .. dstmac .. " /" .. " /"  .. pkt.bssid_hex .. " '" .. "' ch " .. ftype .. "," .. pkt.rssi)
    
        end
    end)
end


tmr.alarm(1, 1000, tmr.ALARM_AUTO, scan)
