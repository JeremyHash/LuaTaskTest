-- AudioTest
-- Author:LuatTest
-- CreateDate:20200717
-- UpdateDate:20201022

module(..., package.seeall)

local AudioTestConfig = {
    AudioPlayTest     = false,
    AudioStreamTest   = true
}

local waitTime1 = 5000
local waitTime2 = 1000

--音频播放优先级，对应audio.play接口中的priority参数；数值越大，优先级越高，用户根据自己的需求设置优先级
--PWRON：开机铃声
--CALL：来电铃声
--SMS：新短信铃声
--TTS：TTS播放
--REC:录音音频
PWRON, CALL, SMS, TTS, REC = 4, 3, 2, 1, 0

local tBuffer = {}
local tStreamType
local producing = false
local streamPlaying = false

local function consumer()
    sys.taskInit(
        function()
            audio.setVolume(5)
            while true do
                while #tBuffer == 0 do
		    		if not producing then
		    			while audiocore.streamremain() ~= 0 do
		    				sys.wait(20)	
		    			end
		    			streamPlaying = false
		    			audiocore.stop() --添加audiocore.stop()接口，否则再次播放会播放不出来
		    			log.warn("AudioTest.AudioStreamTest", "AudioStreamPlay Over")
		    		end
                    sys.waitUntil("DATA_STREAM_IND")
                end
		    	streamPlaying = true
                local data = table.remove(tBuffer, 1)
                --log.info("testAudioStream.consumer remove",data:len())
                local procLen = audiocore.streamplay(tStreamType, data)
                log.info("AudioTest.AudioStreamTest.BufferLen", #tBuffer)
                if procLen < data:len() then
                    --log.warn("produce fast")
                    table.insert(tBuffer, 1, data:sub(procLen + 1, -1))
                    sys.wait(5)
                end
            end
        end
    )
end


local function producer(streamType)
    sys.taskInit(
        function()
            while true do
                tStreamType = streamType
		    	while streamPlaying do
		    		sys.wait(200)
		    	end
		    	log.info("AudioTest.AudioStreamTest", "AudioStreamPlay Start", streamType)
                local tAudioFile =
                {
                    [audiocore.AMR] = "tip.amr",
                    [audiocore.SPX] = "record.spx",
                    [audiocore.PCM] = "alarm_door.pcm",
                }
                local fileHandle = io.open("/lua/" .. tAudioFile[streamType], "rb")
                if not fileHandle then
                    log.error("AudioTest.AudioStreamTest", "Open file error")
                    return
                end

                while true do
                    local data = fileHandle:read(streamType == audiocore.SPX and 1200 or 1024)
                    if not data then 
		    			fileHandle:close() 
		    			producing = false 
                        -- if streamType == audiocore.PCM then
                        -- 	streamType = audiocore.AMR
                        -- else
                        -- 	streamType = audiocore.PCM
                        -- end
		    			return 
		    		end
                    table.insert(tBuffer, data)
		    		producing = true
                    if #tBuffer == 1 then
                        sys.publish("DATA_STREAM_IND")
                    end
                    --log.info("testAudioStream.producer",data:len())
                    sys.wait(10)
                end  
            end
        end
    )
end

-- playFileTestCb回调
local function playFileTestCb(result)
    if result == 0 then
        log.info("playFileTestCb.result", "SUCCESS:", result)
    elseif result == 1 then
        log.info("playFileTestCb.result", "FAIL:", result)
    elseif result == 2 then
        log.info("playFileTestCb.result", "Play priority is not enough, no play:", result)
    elseif result == 3 then
        log.info("playFileTestCb.result", "传入的参数出错，没有播放:", result)
    elseif result == 4 then
        log.info("playFileTestCb.result", "Aborted by new playback request:", result)
    elseif result == 5 then
        log.info("playFileTestCb.result", "调用audio.stop接口主动停止:", result)
    end
end


-- testPlayTts回调
local function playTtsTestCb(result)
    if result == 0 then
        log.info("playTtsTestCb.result", "SUCCESS:", result)
    elseif result == 1 then
        log.info("playTtsTestCb.result", "FAIL:", result)
    elseif result == 2 then
        log.info("playTtsTestCb.result", "Play priority is not enough, no play:", result)
    elseif result == 3 then
        log.info("playTtsTestCb.result", "传入的参数出错，没有播放:", result)
    elseif result == 4 then
        log.info("playTtsTestCb.result", "Aborted by new playback request:", result)
    elseif result == 5 then
        log.info("playTtsTestCb.result", "调用audio.stop接口主动停止:", result)
    end
end

-- testPlayConflict回调
local function playConflictTestCb(result)
    if result == 0 then
        log.info("playConflictTestCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("playConflictTestCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("playConflictTestCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("playConflictTestCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("playConflictTestCb.result","Aborted by new playback request:",result)
    elseif result == 5 then
        log.info("playConflictTestCb.result","调用audio.stop接口主动停止:",result)
    end
end

-- testPlayPwron回调
local function playPwronTestCb(result)
    if result == 0 then
        log.info("playPwronTestCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("playPwronTestCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("playPwronTestCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("playPwronTestCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("playPwronTestCb.result","Aborted by new playback request:",result)
    elseif result == 5 then
        log.info("playPwronTestCb.result","调用audio.stop接口主动停止:",result)
    end
end

-- testPlaySms回调
local function playSmsTest8Cb(result)
    if result == 0 then
        log.info("playSmsTest8Cb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("playSmsTest8Cb.result","FAIL:",result)
    elseif result == 2 then
        log.info("playSmsTest8Cb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("playSmsTest8Cb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("playSmsTest8Cb.result","被新的播放请求中止:",result)
    elseif result == 5 then
        log.info("playSmsTest8Cb.result","调用audio.stop接口主动停止:",result)
    end
end

-- testPlayStop回调
local function testPlayStopCb(result)
    if result == 0 then
        log.info('audio.stop','SUCCESS')
    elseif result == 1 then
        log.info('audio.stop','please wait')
    end
end

local ttsStr = "撸啊版本踢踢爱斯测试"

sys.taskInit(
    function()
        local vol = 1
        local count = 1
        local speed = 4
        sys.wait(1000)
        consumer()

        local isTTSVersion = rtos.get_version():upper():find("TTS")

        while true do
            if AudioTestConfig.AudioPlayTest == true then
            
                -- 播放音频文件
                log.info("AudioTest.AudioPlayTest.Vol", vol)
                log.info("AudioTest.AudioPlayTest.PlayFileTest", "第" .. count .. "次")
                audio.play(CALL, "FILE", "/lua/call.mp3", vol, playFileTestCb)
                sys.wait(waitTime1)
                audio.stop(testPlayStopCb)
                log.info("AudioTest.AudioPlayTest.Stop", "播放中断")
                sys.wait(waitTime1)
                
                -- tts播放时，请求播放新的tts
                if isTTSVersion then
                    log.info('AudioTest.AudioPlayTest.Speed', speed)
                    log.info("AudioTest.AudioPlayTest.PlayTtsTest", "第" .. count .. "次")
                    audio.setTTSSpeed(speed)

                    --设置优先级相同时的播放策略，1表示停止当前播放，播放新的播放请求
                    audio.setStrategy(1)
                    audio.play(TTS, "TTS", ttsStr, vol, playTtsTestCb)
                    sys.wait(waitTime2)
                    log.info("AudioTest.AudioPlayTest.PlayTtsTest", "相同优先级停止当前播放")
                    audio.play(TTS, "TTS", ttsStr, vol, playTtsTestCb)
                    sys.wait(waitTime1)
                    
                    --设置优先级相同时的播放策略，0表示继续播放正在播放的音频，忽略请求播放的新音频
                    audio.setStrategy(0)
                    audio.play(TTS, "TTS", ttsStr, vol, playTtsTestCb)
                    sys.wait(waitTime2)
                    log.info("AudioTest.AudioPlayTest.PlayTtsTest", "继续当前测试")
                    audio.play(TTS, "TTS", ttsStr, vol, playTtsTestCb)
                end

                
            
                -- 播放冲突1
                log.info("AudioTest.AudioPlayTest.PlayConflictTest1", "第" .. count .. "次")
                -- 循环播放来电铃声
                audio.play(CALL, "FILE", "/lua/call.mp3", vol, playConflictTestCb, true)
                sys.wait(waitTime1)
                --5秒钟后，播放开机铃声
                log.info("AudioTest.AudioPlayTest.PlayConflictTest1", "优先级较高的开机铃声播放")
                audio.play(PWRON, "FILE", "/lua/pwron.mp3", vol, playPwronTestCb)
                sys.wait(waitTime1)       
            
                -- 播放冲突2
                log.info("AudioTest.AudioPlayTest.PlayConflictTest2", "第" .. count .. "次")
                -- 播放来电铃声
                audio.play(CALL, "FILE", "/lua/call.mp3", vol, playConflictTestCb)
                sys.wait(waitTime1)  
                --5秒钟后，尝试循环播放新短信铃声，但是优先级不够，不会播放
                log.info("AudioTest.AudioPlayTest.PlayConflictTest2", "优先级较低的短信铃声不能播放")
                audio.play(SMS, "FILE", "/lua/sms.mp3", vol, playSmsTest8Cb)
                sys.wait(waitTime1)  
            
                count = count + 1
                vol = (vol == 7) and 1 or (vol + 1)
                speed = (speed == 100) and 4 or (speed + 16)
            end

            if AudioTestConfig.AudioStreamTest == true then
                audio.setVolume(4)
                log.info("AudioTest.AudioStreamTest.AMRFilePlayTest", "Start")
                producer(audiocore.AMR)
                sys.wait(30000)
                log.info("AudioTest.AudioStreamTest.SPXFilePlayTest", "Start")
                producer(audiocore.SPX)
                sys.wait(30000)
                log.info("AudioTest.AudioStreamTest.PCMFilePlayTest", "Start")
                producer(audiocore.PCM)
                sys.wait(30000)
            end
        end
end)
