-- USBAudioTest
-- Author:LuatTest
-- CreateDate:20210304
-- UpdateDate:20210304

module(..., package.seeall)

-- 串口配置
local uartId = uart.USB
local baud = 115200
local databits = 8

local audioTmp = {}

sys.taskInit(
    function()
        while true do
            log.info("len of audiotmp", #audioTmp)
            if #audioTmp > 0 then
                log.info("audioTmp", "start play")
                local audioData = table.remove(audioTmp, 1)
                local data_len = string.len(audioData)
                local curr_len = 1
                while true do
                    curr_len = curr_len + audiocore.streamplay(audiocore.MP3, string.sub(audioData, curr_len, -1))
                    if curr_len >= data_len then
                        break
                    elseif curr_len == 0 then
                        audiocore.stop()
                        break
                    end
                end
            end
            sys.wait(100)
        end
    end
)

local function read()
    local uartData = ""
    while true do
        local uartData = uart.read(uartId, "*l")

        log.info("uartData", uartData)
    
        if not uartData or string.len(uartData) == 0 then
            while audiocore.streamremain() ~= 0 do
            end
            audiocore.stop()
            break 
        end

        table.insert(audioTmp, uartData)
    end
end

uart.setup(uartId, baud, databits, uart.PAR_NONE, uart.STOP_1)
uart.on(uartId, "receive", read)
