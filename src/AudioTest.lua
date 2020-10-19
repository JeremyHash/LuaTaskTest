-- AudioTest
-- Author:LuatTest
-- CreateDate:20200717
-- UpdateDate:20200717

module(..., package.seeall)

local AudioTestConfig = {
    playAudio     = true,
    playAMRFile   = false,
    playSPXFile   = false,
    playPCMFile   = false
}

local waitTime1 = 5000
local waitTime2 = 1000

--音频播放优先级，对应audio.play接口中的priority参数；数值越大，优先级越高，用户根据自己的需求设置优先级
--PWRON：开机铃声
--CALL：来电铃声
--SMS：新短信铃声
--TTS：TTS播放
--REC:录音音频
PWRON,CALL,SMS,TTS,REC = 4,3,2,1,0

local tBuffer = {}
local tStreamType

local function consumer()
    sys.taskInit(function()
        audio.setVolume(1)
        while true do
            while #tBuffer==0 do
                sys.waitUntil("DATA_STREAM_IND")
            end

            local data = table.remove(tBuffer,1)
            log.info("testAudioStream.consumer remove",data:len())
            local procLen = audiocore.streamplay(tStreamType,data)
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

-- testPlayFileCb回调
local function testPlayFileCb(result)
    if result == 0 then
        log.info("testPlayFileCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("testPlayFileCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("testPlayFileCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("testPlayFileCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("testPlayFileCb.result","Aborted by new playback request:",result)
    elseif result == 5 then
        log.info("testPlayFileCb.result","调用audio.stop接口主动停止:",result)
    end
end


-- testPlayTts回调
local function testPlayTtsCb(result)
    if result == 0 then
        log.info("testPlayTtsCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("testPlayTtsCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("testPlayTtsCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("testPlayTtsCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("testPlayTtsCb.result","Aborted by new playback request:",result)
    elseif result == 5 then
        log.info("testPlayTtsCb.result","调用audio.stop接口主动停止:",result)
    end
end

-- testPlayConflict回调
local function testPlayConflictCb(result)
    if result == 0 then
        log.info("testPlayConflictCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("testPlayConflictCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("testPlayConflictCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("testPlayConflictCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("testPlayConflictCb.result","Aborted by new playback request:",result)
    elseif result == 5 then
        log.info("testPlayConflictCb.result","调用audio.stop接口主动停止:",result)
    end
end

-- testPlayPwron回调
local function testPlayPwronCb(result)
    if result == 0 then
        log.info("testPlayPwronCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("testPlayPwronCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("testPlayPwronCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("testPlayPwronCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("testPlayPwronCb.result","Aborted by new playback request:",result)
    elseif result == 5 then
        log.info("testPlayPwronCb.result","调用audio.stop接口主动停止:",result)
    end
end

-- testPlaySms回调
local function testPlaySmsCb(result)
    if result == 0 then
        log.info("testPlaySmsCb.result","SUCCESS:",result)
    elseif result == 1 then
        log.info("testPlaySmsCb.result","FAIL:",result)
    elseif result == 2 then
        log.info("testPlaySmsCb.result","Play priority is not enough, no play:",result)
    elseif result == 3 then
        log.info("testPlaySmsCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("testPlaySmsCb.result","被新的播放请求中止:",result)
    elseif result == 5 then
        log.info("testPlaySmsCb.result","调用audio.stop接口主动停止:",result)
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

local ttsStr = "上海合宙通信科技有限公司欢迎您"

sys.taskInit(function()
    local vol = 1
    local count = 1
    local speed = 4
    while true do
        if AudioTestConfig.playAudio == true then

            -- 设置麦克音量等级
            audio.setMicVolume(vol)
            level = audio.getMicVolume()
            log.info('Mic volume level: ', level)

            -- 播放音频文件
            log.info("vol",vol)
            log.info("testPlayFile","testPlayFile:第"..count.."次")
            audio.play(CALL,"FILE","/lua/call.mp3",vol,testPlayFileCb)
            sys.wait(waitTime1)
            audio.stop(testPlayStopCb)
            sys.wait(waitTime2)
            
            -- tts播放时，请求播放新的tts
            log.info("vol",vol)
            log.info('speed', speed)
            log.info("testPlayTts","testPlayTts:第"..count.."次")
            audio.setTTSSpeed(speed)
            audio.play(TTS,"TTS",ttsStr,vol,testPlayTtsCb)
            sys.wait(waitTime2)
            --设置优先级相同时的播放策略，1表示停止当前播放，播放新的播放请求
            audio.setStrategy(1)
            audio.play(TTS,"TTS",ttsStr,vol,testPlayTtsCb)
            sys.wait(waitTime2)
            --设置优先级相同时的播放策略，0表示继续播放正在播放的音频，忽略请求播放的新音频
            audio.setStrategy(0)
            audio.play(TTS,"TTS",ttsStr,vol,testPlayTtsCb)
            sys.wait(waitTime1)

            -- 播放冲突1
            log.info("vol",vol)
            log.info("testPlayConflict1","testPlayConflict1:第"..count.."次")
            -- 循环播放来电铃声
            audio.play(CALL,"FILE","/lua/call.mp3",vol,testPlayConflictCb, true)
            sys.wait(waitTime1)
            --5秒钟后，播放开机铃声
            audio.play(PWRON,"FILE","/lua/pwron.mp3",vol,testPlayPwronCb)
            sys.wait(waitTime1)       

            -- 播放冲突2
            log.info("vol",vol)
            log.info("testPlayConflict2","testPlayConflict2:第"..count.."次")
            -- 播放来电铃声
            audio.play(CALL,"FILE","/lua/call.mp3",vol,testPlayConflictCb)
            sys.wait(waitTime2)  
            --5秒钟后，尝试循环播放新短信铃声，但是优先级不够，不会播放
            audio.play(SMS,"FILE","/lua/sms.mp3",vol,testPlaySmsCb)
            sys.wait(waitTime1)  

            -- 播放冲突3
            log.info("vol",vol)
            log.info("testPlayConflict3","testPlayConflict3:第"..count.."次")
            -- 循环播放TTS
            audio.play(TTS,"TTS",ttsStr,vol,testPlayTtsCb, true)
            --5秒钟后，播放开机铃声
            sys.wait(waitTime1)
            audio.play(PWRON,"FILE","/lua/pwron.mp3",vol,testPlayPwronCb)
            sys.wait(waitTime1)

            count = count + 1
            vol = (vol==7) and 1 or (vol+1)
            speed = (speed==100) and 4 or (speed+16)
        end

        if AudioTestConfig.playAMRFile == true then
            producer(audiocore.AMR)
            consumer()
            sys.wait(25000)
        end

        if AudioTestConfig.playSPXFile == true then
            producer(audiocore.SPX)
            consumer()
            sys.wait(10000)
        end

        if AudioTestConfig.playPCMFile == true then
            producer(audiocore.PCM)
            consumer()
            sys.wait(15000)
        end

    end
end)
