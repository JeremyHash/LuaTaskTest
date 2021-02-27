-- AudioTest
-- Author:LuatTest
-- CreateDate:20200717
-- UpdateDate:20210222

module(..., package.seeall)

local waitTime1 = 3000
local waitTime2 = 1000

--音频播放优先级，数值越大，优先级越高
local PWRON, CALL, SMS, TTS, REC = 4, 3, 2, 1, 0

--每次读取的录音文件长度
local RCD_READ_UNIT = 1024

local recordBuf = ""

local tAudioFile =
{
    -- [audiocore.WAV] = "tip.wav",
    [audiocore.AMR] = "tip.amr",
    [audiocore.SPX] = "record.spx",
    [audiocore.PCM] = "alarm_door.pcm",
    [audiocore.MP3] = "sms.mp3"
}

-- TODO 需要模拟数据从网络侧获得、串口获得
local function audioStreamPlayTest(streamType)
    sys.taskInit(
        function()
		    log.info("AudioTest.AudioStreamTest", "AudioStreamPlay Start", tAudioFile[streamType])
            
            local fileHandle = io.open("/lua/" .. tAudioFile[streamType], "rb")
            if not fileHandle then
                log.error("AudioTest.AudioStreamTest", "Open file fail")
                return
            end
            while true do
                local data = fileHandle:read(streamType == audiocore.SPX and 1200 or 1024)
                if not data then 
                    fileHandle:close()
                    while audiocore.streamremain() ~= 0 do
                        sys.wait(20)	
                    end
                    sys.wait(1000)
                    audiocore.stop()
                    log.info("AudioTest.AudioStreamTest", "AudioStreamPlay Over")
                    return
                end
                local data_len = string.len(data)
                local curr_len = 1
                while true do
                    curr_len = curr_len + audiocore.streamplay(streamType, string.sub(data, curr_len, -1))
                    if curr_len >= data_len then
                        break
                    elseif curr_len == 0 then
                        log.error("AudioTest.AudioStreamTest", "AudioStreamPlay Error", tAudioFile[streamType])
                        audiocore.stop()
                        return
                    end
                    sys.wait(10)
                end
                sys.wait(10)
            end
        end
    )
end

local function recordPlayCb(result)
    log.info("AudioTest.RecordTest.PlayCb", result)
    log.info("AudioTest.RecordTest", "录音播放结束")
    --删除录音文件
    record.delete()
end

function recordCb1(result, size)
    log.info("AudioTest.RecordTest.RecordCb", "录音结束")
    log.info("AudioTest.RecordTest.RecordCb.result, size", result, size)
    if result then
        log.info("AudioTest.RecordTest.RecordCb", "录制成功SUCCESS")
        log.info("AudioTest.RecordTest.GetData", record.getData(0, size))
        log.info("AudioTest.RecordTest.GetSize", record.getSize())
        -- TODO 对返回值验证
        log.info("AudioTest.RecordTest.Exists", record.exists())
        log.info("AudioTest.RecordTest.IsBusy", record.isBusy())
        log.info("AudioTest.RecordTest.filePath", record.getFilePath())
        --播放录音内容
        log.info("AudioTest.RecordTest", "开始播放录音")
        audio.play(REC, "FILE", record.getFilePath(), 7, recordPlayCb)
    else
        log.info("AudioTest.RecordTest.RecordCb", "录制失败FAIL")
    end
end

function recordCb2(result, size, tag)
    log.info("AudioTest.RecordTest.RecordCb", result, size, tag)
    if tag == "STREAM" then
        local s = audiocore.streamrecordread(size)
        recordBuf = recordBuf .. s
    else
        log.info("AudioTest.RecordTest.SPX.StreamPlay.TotalLen", recordBuf:len())
        --audiocore.streamplay返回接收的buffer长度
        --此处并没有将录音数据全部播放完整
        log.info("AudioTest.RecordTest.SPX.StreamPlay", "开始流录音播放")
        log.info("AudioTest.RecordTest.SPX.StreamPlay.AcceptLen", audiocore.streamplay(audiocore.SPX, recordBuf))
        
        sys.timerStart(
            function()
                audiocore.stop()
                record.delete()
            end,
            6000
        )
        
        recordBuf = ""     
    end
end

-- audioPlayTestCb回调
local function audioPlayTestCb(result)
    local tag = "AudioTest.audioPlayTestCb"
    if result == 0 then
        log.info(tag, "播放成功SUCCESS")
    elseif result == 1 then
        log.info(tag, "播放出错FAIL")
    elseif result == 2 then
        log.info(tag, "播放优先级不够，没有播放")
    elseif result == 3 then
        log.info(tag, "传入的参数出错，没有播放")
    elseif result == 4 then
        log.info(tag, "被新的播放请求中止")
    elseif result == 5 then
        log.info(tag, "调用audio.stop接口主动停止")
    end
end

-- playStopCb回调
local function playStopCb(result)
    local tag = "AudioTest.playStopCb"
    if result == 0 then
        log.info(tag, "SUCCESS")
    elseif result == 1 then
        log.info(tag, "please wait")
    end
end

local function headsetCb(msg)  
    if msg.type == 1 then
        log.info("音频通道切换为耳机")
        audiocore.setchannel(1, 0)
    elseif msg.type == 2 then
        log.info("音频通道切换为喇叭")
        audiocore.setchannel(2, 0)
    elseif msg.type == 3 then
        log.info("耳机按键按下")
    elseif msg.type == 4 then
        log.info("耳机按键弹起")
    end
end  
--注册core上报的rtos.MSG_AUDIO消息的处理函数  
-- rtos.on(rtos.MSG_HEADSET, headsetCb)

-- audiocore.headsetinit(0)

sys.taskInit(
    function()
        local playVol = 0
        local micVol = 0
        local count = 1
        local speed = 4
        local ttsStr = "上海合宙通信科技有限公司欢迎您"
        sys.wait(1000)
        audiocore.setchannel(2, 0)

        -- 耳机插拔，音频通道自动切换
        -- audiocore.headsetinit(1)

        local isTTSVersion = rtos.get_version():upper():find("TTS")

        while true do
            -- audiocore.playdata(audioData,audioFormat[,audioLoop]) demo中没有
            -- audiocore.setpa(audioClass) audiocore.getpa() audiocore.pa(gpio,devout,[plus_count],[plus_period]) 不清楚什么意思
            -- audiocore.headsetinit(auto)
            -- audiocore.rtmpopen(url)

            audio.setVolume(playVol)
            -- audio.setMicVolume(micVol)
            local setMicResult = audio.setMicGain("record", micVol)

            if setMicResult == true then
                log.info("AudioTest.SetMicGain", "SUCCESS")
            else
                log.error("AudioTest.SetMicGain", "FAIL")
            end

            if LuaTaskTestConfig.audioTest.audioPlayTest then
                -- 播放音频文件
                log.info("AudioTest.AudioPlayTest.当前播放音量", playVol)
                log.info("AudioTest.AudioPlayTest.PlayFileTest", "第" .. count .. "次")
                audio.play(CALL, "FILE", "/lua/sms.mp3", playVol, audioPlayTestCb, true)
                sys.wait(waitTime1)
                audio.stop(playStopCb)
                log.info("AudioTest.AudioPlayTest.Stop", "播放中断")
                sys.wait(waitTime1)
                
                -- tts播放时，请求播放新的tts
                if isTTSVersion then
                    log.info('AudioTest.AudioPlayTest.speed', speed)
                    log.info("AudioTest.AudioPlayTest.PlayTtsTest", "第" .. count .. "次")
                    -- TODO 验证速度的值
                    audio.setTTSSpeed(speed)

                    --设置优先级相同时的播放策略，1表示停止当前播放，播放新的播放请求
                    audio.setStrategy(1)
                    audio.play(TTS, "TTS", ttsStr, playVol, audioPlayTestCb)
                    sys.wait(waitTime2)
                    log.info("AudioTest.AudioPlayTest.PlayTtsTest", "相同优先级停止当前播放")
                    audio.play(TTS, "TTS", ttsStr, playVol, audioPlayTestCb)
                    sys.wait(waitTime1)
                    
                    --设置优先级相同时的播放策略，0表示继续播放正在播放的音频，忽略请求播放的新音频
                    audio.setStrategy(0)
                    audio.play(TTS, "TTS", ttsStr, playVol, audioPlayTestCb)
                    sys.wait(waitTime2)
                    log.info("AudioTest.AudioPlayTest.PlayTtsTest", "当前播放不会被打断")
                    audio.play(TTS, "TTS", ttsStr, playVol, audioPlayTestCb)
                    sys.wait(waitTime1)
                end

                -- 播放冲突1
                log.info("AudioTest.AudioPlayTest.PlayConflictTest1", "第" .. count .. "次")
                -- 循环播放来电铃声
                log.info("AudioTest.AudioPlayTest.PlayConflictTest1", "优先级: ", CALL)
                audio.play(CALL, "FILE", "/lua/sms.mp3", playVol, audioPlayTestCb, true)
                sys.wait(waitTime1)
                --5秒钟后，播放开机铃声
                log.info("AudioTest.AudioPlayTest.PlayConflictTest1", "优先级较高的开机铃声播放")
                log.info("AudioTest.AudioPlayTest.PlayConflictTest1", "优先级: ", PWRON)
                audio.play(PWRON, "FILE", "/lua/sms.mp3", playVol, audioPlayTestCb)
                sys.wait(waitTime1)
            
                -- 播放冲突2
                log.info("AudioTest.AudioPlayTest.PlayConflictTest2", "第" .. count .. "次")
                -- 播放来电铃声
                log.info("AudioTest.AudioPlayTest.PlayConflictTest2", "优先级: ", CALL)
                audio.play(CALL, "FILE", "/lua/sms.mp3", playVol, audioPlayTestCb, true)
                sys.wait(waitTime1)  
                --5秒钟后，尝试循环播放新短信铃声，但是优先级不够，不会播放
                log.info("AudioTest.AudioPlayTest.PlayConflictTest2", "优先级较低的短信铃声不能播放")
                log.info("AudioTest.AudioPlayTest.PlayConflictTest2", "优先级: ", SMS)
                audio.play(SMS, "FILE", "/lua/sms.mp3", playVol, audioPlayTestCb)
                sys.wait(waitTime1)
                audio.stop(playStopCb)
                sys.wait(waitTime1)  
            
            end

            if LuaTaskTestConfig.audioTest.audioStreamTest then
                
                
                -- log.info("AudioTest.AudioStreamTest.WAVFilePlayTest", "Start")
                -- audioStreamPlayTest(audiocore.WAV)
                -- sys.wait(30000)
                
                log.info("AudioTest.AudioStreamTest.AMRFilePlayTest", "Start")
                audioStreamPlayTest(audiocore.AMR)
                sys.wait(30000)

                log.info("AudioTest.AudioStreamTest.SPXFilePlayTest", "Start")
                audioStreamPlayTest(audiocore.SPX)
                sys.wait(30000)

                -- log.info("AudioTest.AudioStreamTest.PCMFilePlayTest", "Start")
                -- audioStreamPlayTest(audiocore.PCM)
                -- sys.wait(30000)

                log.info("AudioTest.AudioStreamTest.MP3FilePlayTest", "Start")
                audioStreamPlayTest(audiocore.MP3)
                sys.wait(30000)
            end

            if LuaTaskTestConfig.audioTest.recordTest then
                -- TODO 缺少其他参数类型的测试 阀值是多少 默认是nil不合理
                
                log.info("AudioTest.RecordTest", "当前MIC音量：", micVol)
                log.info("AudioTest.RecordTest", "开始普通录音")
                record.start(5, recordCb1, "FILE", 2, 3)
                sys.wait(30000)

                log.info("AudioTest.RecordTest", "开始流录音")
                record.start(10, recordCb2, "STREAM", 1, 4)
                sys.wait(30000)
            end

            audio.setVolume(playVol)

            local getPlayVol = audio.getVolume()

            print(playVol, getPlayVol)

            if getPlayVol == playVol then
                log.info("AudioTest.PlayVolCheck", "SUCCESS")
            else
                log.error("AudioTest.PlayVolCheck", "FAIL")
            end

            local getMicVol = audio.getMicVolume()

            print(micVol, getMicVol)

            if getMicVol == micVol then
                log.info("AudioTest.MicVolCheck", "SUCCESS")
            else
                log.error("AudioTest.MicVolCheck", "FAIL")
            end


            count = count + 1
            playVol = (playVol == 7) and 0 or (playVol + 1)
            micVol = (micVol == 7) and 0 or (micVol + 1)
            speed = (speed == 100) and 4 or (speed + 16)
        end
end)

