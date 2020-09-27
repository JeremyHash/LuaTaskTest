-- FsTest
-- Author:LuatTest
-- CreateDate:20200927
-- UpdateDate:20200927

module(..., package.seeall)

local function readFile(filename)
	local filehandle = io.open(filename, "r")
	if filehandle then
		local fileval = filehandle:read("*all")
		if fileval then
		   print(fileval)
		   filehandle:close()
	  	else
		   log.info("FsTest.ReadFile", "文件内容为空")
	  	end
	else
		log.error("FsTest.readFile", "文件不存在或文件输入格式不正确")
	end
end

local function writeFileA(filename, value)
	local filehandle = io.open(filename, "a+")
	if filehandle then
		filehandle:write(value)
		filehandle:close()
	else
		log.error("FsTest.WriteFileA", "文件不存在或文件输入格式不正确")
	end
end

local function writeFileW(filename, value)
	local filehandle = io.open(filename, "w")
	if filehandle then
		filehandle:write(value)
		filehandle:close()
	else
		log.error("FsTest.WriteFileW", "文件不存在或文件输入格式不正确")
	end
end

local function deleteFile(filename)
	os.remove(filename)
end

local getDirContent

getDirContent = function (dirPath)
    if io.opendir(dirPath) then
    	local dirTable = {}
    	log.info("FsTest.Directory", dirPath)
    	while true do
    	    local fType, fName, fSize = io.readdir()
    	    if fType == 32 then
    	        log.info("FsTest.File", dirPath .. "/" .. fName, fSize)               
    	    elseif fType == 16 then
    	        table.insert(dirTable, dirPath .. "/" .. fName)
    	    elseif fType == nil then
    	        io.closedir(dirPath)
    	        while #dirTable > 0 do
    	            getDirContent(table.remove(dirTable, 1))
    	        end
    	        break
    	    end
		end
	end
end

-- local getDirContent

-- getDirContent =  function (dirPath)
--     if io.opendir(dirPath) then
--         while true do
--             local fType, fName, fSize = io.readdir()
--             if fType == 32 then
--                 log.info("FsTest.SdCard0.File", fName, fSize)               
--             elseif fType == 16 then
--                 log.info("FsTest.SdCard0.Directory", fName, fSize)
--                 getDirContent(dirPath .. "/" .. fName)
--             elseif fType == nil then
--                 break
--             end
--         end
--         io.closedir(dirPath)
--     end
-- end

sys.taskInit(
    function()

        sys.wait(5000)
        --挂载SD卡
        io.mount(io.SDCARD)
        
        --第一个参数1表示sd卡
        --第二个参数1表示返回的总空间单位为KB
        local sdCardTotalSize = rtos.get_fs_total_size(1, 1)
        log.info("FsTest.SdCard0.TotalSize", sdCardTotalSize .. " KB")
        
        local sdCardFreeSize = rtos.get_fs_free_size(1, 1)
        log.info("FsTest.SdCard0.FreeSize", sdCardFreeSize .. " KB")
        
        getDirContent("/sdcard0")

        --向sd卡根目录下写入一个pwron.mp3
		io.writeFile("/sdcard0/pwron.mp3", io.readFile("/lua/pwron.mp3"))
		
        --播放sd卡根目录下的pwron.mp3
        audio.play(0, "FILE","/sdcard0/pwron.mp3", 1, function() sys.publish("AUDIO_PLAY_END") end)
        sys.waitUntil("AUDIO_PLAY_END")


        --卸载SD卡
        io.unmount(io.SDCARD)
    end
)

sys.taskInit(
	function ()
		local testPath = "/FsTestPath"
		while true do
			print("get_fs_free_size: "..rtos.get_fs_free_size().." Bytes")
			if rtos.make_dir(testPath) then
				
			end
			sys.wait(1000)
		end
	end
)
