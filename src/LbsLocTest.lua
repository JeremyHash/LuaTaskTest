module(...,package.seeall)

function getLocCb(result,lat,lng,addr)
    log.info("testLbsLoc.getLocCb",result,lat,lng,addr)
end

sys.taskInit(
function()
    while true do
        lbsLoc.request(getLocCb)
        sys.wait(5000)
    end
end
)