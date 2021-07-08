-- PwmTest
-- Author:LuatTest
-- CreateDate:20210708
-- UpdateDate:20210708

module(...,package.seeall)

local tag = "PwmTest"
sys.taskInit(
    function ()
        while true do
            log.info(tag,"open pwm 50")
            --pio.pin.pwm参数（管脚号，高电平时长，低电平时长，-1代表一直发）
            pio.pin.pwm(11,50,100,-1)
            sys.wait(10000)
            log.info(tag,"close pwm 50")
            pio.pin.pwm(11,0,0,-1)
            sys.wait(10000)
            --将管脚11电平拉高
            pio.pin.sethigh(11)
            log.info(tag,"open pwm 400")
            pio.pin.pwm(11,300,400,-1)
            sys.wait(10000)
        end
    end
)