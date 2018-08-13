wifi.setmode(wifi.STATION)

station_cfg={}
station_cfg.ssid="SeeSea"
station_cfg.pwd="80983000x"
station_cfg.save=true
wifi.sta.config(station_cfg)
wifi.sta.connect()


ntped = 0

-- wait for an IP
print("connect AP (" ..  station_cfg.ssid ..")")
cnt = 10
tmr.alarm(0,1000,1,function()
  if wifi.sta.getip()==nil then
    cnt = cnt-1
    if cnt<=0 then
      tmr.stop(0)
      print "Not connected to wifi."
    end
  else
    -- Connected to the wifi
    tmr.stop(0)
    if(ntped==0)then
        sntp.sync("ntp1.aliyun.com",
          function(sec, usec, server, info)
            ntped=1
            print('sync', sec, usec, server)
            print("\nStarting main")
            dofile("main.lua")
          end,
          function()
           print('failed!')
          end
        )
    else
        print("\nStarting main")
        dofile("main.lua")
    end
    

  end
end)
