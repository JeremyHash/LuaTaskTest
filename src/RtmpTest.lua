-- WebsocketTest
-- Author:LuatTest
-- CreateDate:20210526
-- UpdateDate:20210526

module(...,package.seeall)

--需要带rtmp功能固件
local tag = "RtmpTest"
--pins.setup(15,1)
audio.setChannel(1)
audio.setVolume(7)
local g_play_continue = false
local function audioMsg(msg)
	--[[
		result_code：
			0  ==  播放成功
			1  ==  播放失败
			2  ==  停止成功
			3  ==  停止失败
			4  ==  接收超时
			5  ==  连接失败
	]]
    log.info(tag..".audioMsgCb",msg.result,msg.result_code)
    if msg.result_code ==0 then
		log.info(tag,"播放SUCCESS")
	end
	if msg.result_code ==1 then
		log.info(tag,"播放FAIL")
	end
	if msg.result_code ==2 then
		log.info(tag,"停止SUCCESS")
	end
	if msg.result_code ==3 then
		log.info(tag,"停止FAIL")
	end
	if msg.result_code ==4 then
		log.info(tag,"接收超时")
	end
	if msg.result_code ==5 then
		log.info(tag,"连接FAIL")
	end
	--sys.publish("RTMP_PLAY_OVER")
	if msg.result_code == 2 then
		sys.publish("RTMP_STOP_OK")
	end
end

rtos.on(rtos.MSG_RTMP, audioMsg)

--打印RAM空间
local function onRsp(currcmd, result, respdata, interdata)

	log.info("HEAPINFO: ",respdata)

end

sys.taskInit(function()
    while true do
		print("ready network ok")
        while not socket.isReady() do sys.wait(1000) end  --循环等待网络就绪
        log.info(tag,"网络就绪")
		sys.wait(5000)
		audio.setVolume(1)
		audio.setChannel(2)
		g_play_continue = false
		log.info(tag,"rtmp open")
		--[[
			功能：打开rtmp播放
			参数：rtmp的链接地址
			返回：成功为1，失败为0
		]]
		if not audiocore.rtmpopen("rtmp://wiki.airm2m.com:41935/live/test") then 
			continue
		end
		sys.wait(20000)
		log.info(tag,"rtmp close")
		audiocore.rtmpclose()
		sys.waitUntil("RTMP_STOP_OK")
		ril.request("AT^HEAPINFO",nil,onRsp)
    end
end)