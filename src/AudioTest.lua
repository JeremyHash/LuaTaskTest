-- AudioTest
-- Author:LuatTest
-- CreateDate:20200717
-- UpdateDate:20200717

module(..., package.seeall)

local AudioTestConfig = {
    AudioPlayTest     = true,
    AMRFilePlayTest   = false,
    SPXFilePlayTest   = false,
    PCMFilePlayTest   = false
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

local function consumer()
    sys.taskInit(function()
        audio.setVolume(1)
        while true do
            while #tBuffer==0 do
                sys.waitUntil("DATA_STREAM_IND")
            end

            local data = table.remove(tBuffer, 1)
            log.info("testAudioStream.consumer remove", data:len())
            local procLen = audiocore.streamplay(tStreamType, data)
            if procLen<data:len() then
                log.warn("produce fast")
                table.insert(tBuffer,1,data:sub(procLen+1,-1))
                sys.wait(5)
            end
        end
    end)
end


local function producer(streamType)
    sys.taskInit(function()
        while true do
            log.info("文件名",streamType)
            tStreamType = streamType
            local tAudioFile =
            {
                [audiocore.AMR] = "tip.amr",
                [audiocore.SPX] = "record.spx",
                [audiocore.PCM] = "alarm_door.pcm",
            }
            
            local fileHandle = io.open("/lua/"..tAudioFile[streamType],"rb")
            if not fileHandle then
                log.error("testAudioStream.producer open file error")
                return
            end
            
            while true do
                local data = fileHandle:read(streamType==audiocore.SPX and 1200 or 1024)
                if not data then fileHandle:close() return end
                table.insert(tBuffer,data)
                if #tBuffer==1 then sys.publish("DATA_STREAM_IND") end
                log.info("testAudioStream.producer",data:len())
                sys.wait(10)
            end  
        end
    end)
end

-- playFileTestCb回调
local function playFileTestCb(result)
    if result == 0 then
        log.info("playFileTestCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("playFileTestCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("playFileTestCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("playFileTestCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("playFileTestCb.result","Aborted by new playback request:",result)
    elseif result == 5 then
        log.info("playFileTestCb.result","调用audio.stop接口主动停止:",result)
    end
end


-- testPlayTts回调
local function playTtsTestCb(result)
    if result == 0 then
        log.info("playTtsTestCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("playTtsTestCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("playTtsTestCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("playTtsTestCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("playTtsTestCb.result","Aborted by new playback request:",result)
    elseif result == 5 then
        log.info("playTtsTestCb.result","调用audio.stop接口主动停止:",result)
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
        while true do
            if AudioTestConfig.AudioPlayTest == true then
            
                -- 播放音频文件
                log.info("AudioPlayTest.Vol", vol)
                log.info("AudioPlayTest.PlayFileTest", "第" .. count .. "次")
                audio.play(CALL, "FILE", "/lua/call.mp3", vol, playFileTestCb)
                sys.wait(waitTime1)
                audio.stop(testPlayStopCb)
                sys.wait(waitTime2)
                
                -- tts播放时，请求播放新的tts
                log.info('AudioPlayTest.Speed', speed)
                log.info("AudioPlayTest.PlayTtsTest", "第" .. count .. "次")
                audio.setTTSSpeed(speed)
                audio.play(TTS, "TTS", ttsStr, vol, playTtsTestCb)
                sys.wait(waitTime2)
                --设置优先级相同时的播放策略，1表示停止当前播放，播放新的播放请求
                audio.setStrategy(1)
                audio.play(TTS, "TTS", ttsStr, vol, playTtsTestCb)
                sys.wait(waitTime2)
                --设置优先级相同时的播放策略，0表示继续播放正在播放的音频，忽略请求播放的新音频
                audio.setStrategy(0)
                audio.play(TTS, "TTS", ttsStr, vol, playTtsTestCb)
                sys.wait(waitTime1)
            
                -- 播放冲突1
                log.info("AudioPlayTest.PlayConflictTest1", "第" .. count .. "次")
                -- 循环播放来电铃声
                audio.play(CALL, "FILE", "/lua/call.mp3", vol, playConflictTestCb, true)
                sys.wait(waitTime1)
                --5秒钟后，播放开机铃声
                audio.play(PWRON, "FILE", "/lua/pwron.mp3", vol, playPwronTestCb)
                sys.wait(waitTime1)       
            
                -- 播放冲突2
                log.info("AudioPlayTest.PlayConflictTest2", "第" .. count .. "次")
                -- 播放来电铃声
                audio.play(CALL, "FILE", "/lua/call.mp3", vol, playConflictTestCb)
                sys.wait(waitTime2)  
                --5秒钟后，尝试循环播放新短信铃声，但是优先级不够，不会播放
                audio.play(SMS, "FILE", "/lua/sms.mp3", vol, playSmsTest8Cb)
                sys.wait(waitTime1)  
            
                -- 播放冲突3
                log.info("testPlayConflict3", "第" .. count .. "次")
                -- 循环播放TTS
                audio.play(TTS, "TTS", ttsStr, vol, playTtsTestCb, true)
                --5秒钟后，播放开机铃声
                sys.wait(waitTime1)
                audio.play(PWRON, "FILE", "/lua/pwron.mp3", vol, playPwronTestCb)
                sys.wait(waitTime1)
            
                count = count + 1
                vol = (vol == 7) and 1 or (vol + 1)
                speed = (speed == 100) and 4 or (speed + 16)
            end
        
            if AudioTestConfig.AMRFilePlayTest == true then
                producer(audiocore.AMR)
                consumer()
                sys.wait(25000)
            end
        
            if AudioTestConfig.SPXFilePlayTest == true then
                producer(audiocore.SPX)
                consumer()
                sys.wait(10000)
            end
        
            if AudioTestConfig.PCMFilePlayTest == true then
                producer(audiocore.PCM)
                consumer()
                sys.wait(15000)
            end
        end
end)
