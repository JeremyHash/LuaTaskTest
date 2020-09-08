-- RilTest
-- Author:LuatTest
-- CreateDate:20200908
-- UpdateDate:20200908

module(...,package.seeall)

sys.taskInit(
    function()
        while true do
            ril.request("AT+CSQ")
            sys.wait(2000)
            ril.request("AT+CGDCONT?")
            sys.wait(2000)
            ril.request("AT+CGATT?")
            sys.wait(2000)
            ril.request("AT+EEMGINFO?")
            sys.wait(2000)
        end
    end
)