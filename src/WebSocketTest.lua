-- WebsocketTest
-- Author:LuatTest
-- CreateDate:20210526
-- UpdateDate:20210526


module(..., package.seeall)
-- -- 创建 websocket 对象
-- local ws = websocket.new("ws://121.40.165.18:8800")

local tag = "WebSocketTest"
local ws = websocket.new("ws://airtest.openluat.com:2900/websocket")
ws:on("open", function()
    ws:send("websocket server start")
end)
ws:on("message", function(msg)
    log.info(tag .. ".receive", msg)
    if msg=="www.openluat.com" then 
        log.info(tag .. ".receive","接收SUCCESS" )
    else 
        log.info(tag..".receive","接收FAIL" )
    end
end)

ws:on("sent", function()
    log.info(tag..".sent", "发送SUCCESS")
end)
ws:on("error", function(msg)
    log.error(tag..".error:", msg)
end)
ws:on("close", function(code)
    log.info(tag..".closed,关闭码:", code)
end)
-- 启动任务进程
sys.taskInit(ws.start, ws, 180)

sys.taskInit(function ()
    while true do
        sys.wait(2000)
        ws:send("www.openluat.com", true)
    end
end)