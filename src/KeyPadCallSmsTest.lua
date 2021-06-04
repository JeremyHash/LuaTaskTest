-- KeyPadCallSmsTest
-- Author:LuatTest
-- CreateDate:20200925
-- UpdateDate:20210319

module(..., package.seeall)

local phoneNum = ""

local function keyMsg(msg)
    -- msg.key_matrix_row：行
    -- msg.key_matrix_col：列
    -- msg.pressed：true表示按下，false表示弹起
    log.info("KeyPadTest.msg", msg.key_matrix_row, msg.key_matrix_col, msg.pressed)
end

local function keyMsgforCall(msg)
    -- msg.key_matrix_row：行
    -- msg.key_matrix_col：列
    -- msg.pressed：true表示按下，false表示弹起
    log.info("KeyPadTest.msg", msg.key_matrix_row, msg.key_matrix_col, msg.pressed)
    local row, col, pressed = msg.key_matrix_row, msg.key_matrix_col, msg.pressed
    if row == 2 and col == 0 and pressed then
        log.info("KeyPadTest", 1)
        if cc.anyCallExist() then
            cc.sendDtmf("1")
        else
            audio.play(0, "TTS", "1")
            phoneNum = phoneNum .. "1"
        end
    end
    if row == 2 and col == 1 and pressed then
        log.info("KeyPadTest", 2)
        if cc.anyCallExist() then
            cc.sendDtmf("2")
        else
            audio.play(0, "TTS", "2")
            phoneNum = phoneNum .. "2"
        end
    end
    if row == 2 and col == 2 and pressed then
        log.info("KeyPadTest", 3)
        if cc.anyCallExist() then
            cc.sendDtmf("3")
        else
            audio.play(0, "TTS", "3")
            phoneNum = phoneNum .. "3"
        end
    end
    if row == 2 and col == 3 and pressed then
        log.info("KeyPadTest", "A")
        if phoneNum ~= "" then
            audio.play(0, "TTS", "正在拨号")
            cc.dial(phoneNum)
        else
            audio.play(0, "TTS", "号码为空")
        end
    end
    if row == 3 and col == 0 and pressed then
        log.info("KeyPadTest", 4)
        if cc.anyCallExist() then
            cc.sendDtmf("4")
        else
            audio.play(0, "TTS", "4")
            phoneNum = phoneNum .. "4"
        end
    end
    if row == 3 and col == 1 and pressed then
        log.info("KeyPadTest", 5)
        if cc.anyCallExist() then
            cc.sendDtmf("5")
        else
            audio.play(0, "TTS", "5")
            phoneNum = phoneNum .. "5"
        end
    end
    if row == 3 and col == 2 and pressed then
        log.info("KeyPadTest", 6)
        if cc.anyCallExist() then
            cc.sendDtmf("6")
        else
            audio.play(0, "TTS", "6")
            phoneNum = phoneNum .. "6"
        end
    end
    if row == 3 and col == 3 and pressed then
        log.info("KeyPadTest", "B")
        if cc.anyCallExist() then
            cc.hangUp(phoneNum)
        end
    end
    if row == 4 and col == 0 and pressed then
        log.info("KeyPadTest", 7)
        if cc.anyCallExist() then
            cc.sendDtmf("7")
        else
            audio.play(0, "TTS", "7")
            phoneNum = phoneNum .. "7"
        end
    end
    if row == 4 and col == 1 and pressed then
        log.info("KeyPadTest", 8)
        if cc.anyCallExist() then
            cc.sendDtmf("8")
        else
            audio.play(0, "TTS", "8")
            phoneNum = phoneNum .. "8"
        end
    end
    if row == 4 and col == 2 and pressed then
        log.info("KeyPadTest", 9)
        if cc.anyCallExist() then
            cc.sendDtmf("9")
        else
            audio.play(0, "TTS", "9")
            phoneNum = phoneNum .. "9"
        end
    end
    if row == 4 and col == 3 and pressed then
        log.info("KeyPadTest", "C")
        if cc.anyCallExist() then
        else
            audio.play(0, "TTS", "归零")
            phoneNum = ""
        end
    end
    if row == 5 and col == 0 and pressed then
        log.info("KeyPadTest", "*")
        if cc.anyCallExist() then
            cc.sendDtmf("*")
        end
    end
    if row == 5 and col == 1 and pressed then
        log.info("KeyPadTest", 0)
        if cc.anyCallExist() then
            cc.sendDtmf("0")
        else
            audio.play(0, "TTS", "0")
            phoneNum = phoneNum .. "0"
        end
    end
    if row == 5 and col == 2 and pressed then
        log.info("KeyPadTest", "#")
        if cc.anyCallExist() then
            cc.sendDtmf("#")
        end
    end
    if row == 5 and col == 3 and pressed then
        log.info("KeyPadTest", "D")
    end
end

local function procnewsms(num, data, datetime)
    log.info("SmsTest.procnewsms", num, data, datetime)
end

local function smsSendCb(result, num, data)
    log.info("SmsTest.smsSendCb", result, num, data)
end

if LuaTaskTestConfig.keyPadCallSmsTest.keypadTest then
    -- 注册按键消息处理函数
    rtos.on(rtos.MSG_KEYPAD, keyMsg)
    -- 初始化键盘阵列
    -- 第一个参数：固定为rtos.MOD_KEYPAD，表示键盘
    -- 第二个参数：目前无意义，固定为0
    -- 第三个参数：表示键盘阵列keyin标记，例如使用了keyin0、keyin1、keyin2、keyin3，则第三个参数为1<<0|1<<1|1<<2|1<<3 = 0x0F
    -- 第三个参数：表示键盘阵列keyout标记，例如使用了keyout0、keyout1、keyout2、keyout3，则第四个参数为1<<0|1<<1|1<<2|1<<3 = 0x0F
    rtos.init_module(rtos.MOD_KEYPAD, 0, 0x3C, 0x0F)
end

if LuaTaskTestConfig.keyPadCallSmsTest.callTest then
    -- 注册按键消息处理函数
    rtos.on(rtos.MSG_KEYPAD, keyMsgforCall)
    -- 初始化键盘阵列
    -- 第一个参数：固定为rtos.MOD_KEYPAD，表示键盘
    -- 第二个参数：目前无意义，固定为0
    -- 第三个参数：表示键盘阵列keyin标记，例如使用了keyin0、keyin1、keyin2、keyin3，则第三个参数为1<<0|1<<1|1<<2|1<<3 = 0x0F
    -- 第三个参数：表示键盘阵列keyout标记，例如使用了keyout0、keyout1、keyout2、keyout3，则第四个参数为1<<0|1<<1|1<<2|1<<3 = 0x0F
    rtos.init_module(rtos.MOD_KEYPAD, 0, 0x3C, 0x0F)
end

local function smsTest()
    sms.send("10086", "10086", smsSendCb)
    -- sms.send("10086", common.utf8ToGb2312("第2条短信"), smsSendCb)
    -- sms.send("10086", "qeiuqwdsahdkjahdkjahdkja122136489759725923759823hfdskfdkjnbzndkjhfskjdfkjdshfkjdsfks83478648732432qeiuqwdsahdkjahdkjahdkja122136489759725923759823hfdskfdkjnbzndkjhfskjdfkjdshfkjdsfks83478648732432qeiuqwdsahdkjahdkjahdkja122136489759725923759823hfdskfdkjnbzndkjhfskjdfkjdshfkjdsfks83478648732432", smsSendCb)
    -- sms.send("10086", common.utf8ToGb2312("华康是的撒qeiuqwdsahdkjahdkjahdkja122136489759725923759823hfdskfdkjnbzndkjhfskjdfkjdshfkjdsfks83478648732432qeiuqwdsahdkjahdkjahdkja122136489759725923759823hfdskfdkjnbzndkjhfskjdfkjdshfkjdsfks83478648732432qeiuqwdsahdkjahdkjahdkja122136489759725923759823hfdskfdkjnbzndkjhfskjdfkjdshfkjdsfks83478648732432"), smsSendCb)
end

if LuaTaskTestConfig.keyPadCallSmsTest.smsTest then
    require "sms"
    sms.setNewSmsCb(procnewsms)
    sys.timerLoopStart(smsTest, 30000)
end