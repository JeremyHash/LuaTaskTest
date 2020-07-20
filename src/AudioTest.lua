-- AudioTest
-- Author:LuatTest
-- CreateDate:20200717
-- UpdateDate:20200717

module(...,package.seeall)

require "record"
require "audio"
require "common"

--音频播放优先级，对应audio.play接口中的priority参数；数值越大，优先级越高，用户根据自己的需求设置优先级
--PWRON：开机铃声
--CALL：来电铃声
--SMS：新短信铃声
--TTS：TTS播放
--REC:录音音频
PWRON,CALL,SMS,TTS,REC = 4,3,2,1,0

-- testPlayFileCb回调
local function testPlayFileCb(result)
    if result == 0 then
        log.info("testPlayFileCb.result","音频文件播放成功结束:",result)
    elseif result == 1 then
        log.info("testPlayFileCb.result","播放出错:",result)
    elseif result == 2 then
        log.info("testPlayFileCb.result","播放优先级不够，没有播放:",result)
    elseif result == 3 then
        log.info("testPlayFileCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("testPlayFileCb.result","被新的播放请求中止:",result)
    elseif result == 5 then
        log.info("testPlayFileCb.result","调用audio.stop接口主动停止:",result)
    end
end


-- testPlayTts回调
local function testPlayTtsCb(result)
    if result == 0 then
        log.info("testPlayTtsCb.result","TTS播放成功结束:",result)
    elseif result == 1 then
        log.info("testPlayTtsCb.result","播放出错:",result)
    elseif result == 2 then
        log.info("testPlayTtsCb.result","播放优先级不够，没有播放:",result)
    elseif result == 3 then
        log.info("testPlayTtsCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("testPlayTtsCb.result","被新的播放请求中止:",result)
    elseif result == 5 then
        log.info("testPlayTtsCb.result","调用audio.stop接口主动停止:",result)
    end
end


-- newtestPlayTts回调
local function newtestPlayTtsCb(result)
    if result == 0 then
        log.info("newtestPlayTtsCb.result","新的TTS播放成功结束:",result)
    elseif result == 1 then
        log.info("newtestPlayTtsCb.result","播放出错:",result)
    elseif result == 2 then
        log.info("newtestPlayTtsCb.result","播放优先级不够，没有播放:",result)
    elseif result == 3 then
        log.info("newtestPlayTtsCb.result","传入的参数出错，没有播放:",result)
    elseif result == 4 then
        log.info("newtestPlayTtsCb.result","被新的播放请求中止:",result)
    elseif result == 5 then
        log.info("newtestPlayTtsCb.result","调用audio.stop接口主动停止:",result)
    end
end

-- testPlayConflict回调
local function testPlayConflictCb(result)
    if result then
        log.info("testPlayConflictCb.result","来电铃声播放成功:",result)
    else
        log.info("testPlayConflictCb.result","来电铃声播放失败:",result)
    end
end

-- testPlayPwron回调
local function testPlayPwronCb(result)
    if result then
        log.info("testPlayPwronCb.result","开机铃声播放成功:",result)
    else
        log.info("testPlayPwronCb.result","开机铃声播放失败:",result)
    end
end

-- testPlaySms回调
local function testPlaySmsCb(result)
    if result then
        log.info("testPlaySmsCb.result","短信铃声播放成功:",result)
    else
        log.info("testPlaySmsCb.result","短信铃声播放失败:",result)
    end
end

-- testPlayRec回调
local function testPlayRecCb(result)
    if result then
        log.info("testPlayRecCb.result","录音播放成功:",result)
    else
        log.info("testPlayRecCb.result","录音播放失败:",result)
    end
end

-- testRec回调
local function testRecCb(result)
    if result then
        log.info("testRecCb.result","录音成功:",result)
    else
        log.info("testRecCb.result","录音失败:",result)
    end
end

local ttsStr = "上海合宙通信科技有限公司欢迎您"

sys.taskInit(function()
    local vol = 1
    local count = 1
    while true do
        -- 播放音频文件
        log.info("vol",vol)
        log.info("testPlayFile","testPlayFile:第"..count.."次")
        audio.play(CALL,"FILE","/lua/call.mp3",vol,testPlayFileCb)
        sys.wait(5000)

        -- 播放tts
        log.info("vol",vol)
        log.info("testPlayTts","testPlayTts:第"..count.."次")
        audio.play(TTS,"TTS",ttsStr,vol,testPlayTtsCb)
        sys.wait(5000)
          
        -- tts播放时，请求播放新的tts
        log.info("vol",vol)
        log.info("testPlayTts","testPlayTts:第"..count.."次")
        audio.play(TTS,"TTS",ttsStr,vol,testPlayTtsCb)
        sys.wait(2000)
        --设置优先级相同时的播放策略，1表示停止当前播放，播放新的播放请求
        audio.setStrategy(1)
        audio.play(TTS,"TTS",ttsStr,vol,newtestPlayTtsCb)
        sys.wait(5000)

        -- 播放冲突1
        log.info("vol",vol)
        log.info("testPlayConflict","testPlayConflict:第"..count.."次")
        -- 播放来电铃声
        audio.play(CALL,"FILE","/lua/call.mp3",vol,testPlayConflictCb)
        sys.wait(5000)
        --5秒钟后，播放开机铃声
        audio.play(PWRON,"FILE","/lua/pwron.mp3",vol,testPlayPwronCb)
        sys.wait(5000)       

        -- 播放冲突2
        log.info("vol",vol)
        log.info("testPlayConflict","testPlayConflict:第"..count.."次")
        -- 播放来电铃声
        audio.play(CALL,"FILE","/lua/call.mp3",vol,testPlayConflictCb)
        sys.wait(5000)  
        --5秒钟后，播放新短信铃声
        audio.play(SMS,"FILE","/lua/sms.mp3",vol,testPlaySmsCb)
        sys.wait(5000)  

        -- 播放冲突3
        log.info("vol",vol)
        log.info("testPlayConflict","testPlayConflict:第"..count.."次")
        -- 播放TTS
        audio.play(TTS,"TTS",ttsStr,vol,testPlayTtsCb)
        --10秒钟后，播放开机铃声
        sys.wait(10000)
        audio.play(PWRON,"FILE","/lua/pwron.mp3",vol,testPlayPwronCb)
        sys.wait(5000)

        -- 播放冲突4
        -- log.info("vol",vol)
        -- log.info("testPlayConflict","testPlayConflict:第"..count.."次")
        -- sys.wait(1000)
        -- 1秒后，录音5秒，之后进行播放冲突测试接口
        -- record.start(5,testRecCb)
        -- sys.wait(10000)
        -- -- 播放录音
        -- audio.play(REC,"RECORD",1,vol,testPlayRecCb)
        -- sys.wait(5000)
        -- 5秒钟后，播放开机铃声
        -- audio.play(PWRON,"FILE","/lua/pwron.mp3",vol,testPlayPwronCb)
        -- sys.wait(5000)

        count = count + 1
        vol = (vol==7) and 1 or (vol+1)
    end
end)
