-- RilTest
-- Author:LuatTest
-- CreateDate:20200908
-- UpdateDate:20200908

module(...,package.seeall)

local rilTestCount = 1

sys.taskInit(
    function()
        while true do
            log.info("RilTest.rilTestCount", "第"..rilTestCount.."次测试开始")
            ril.request("AT+CSQ")
            sys.wait(2000)
            ril.request("AT+CGDCONT?")
            sys.wait(2000)
            ril.request("AT+CGATT?")
            sys.wait(2000)
            ril.request("AT+EEMGINFO?")
            sys.wait(2000)
            log.info("RilTest.rilTestCount", "第"..rilTestCount.."次测试完成")
            rilTestCount = rilTestCount + 1
        end
    end
)