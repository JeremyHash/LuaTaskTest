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
		   log.info("FsTest.readFile." .. filename, fileval)
		   filehandle:close()
	  	else
		   log.info("FsTest.ReadFile." .. filename, "文件内容为空")
	  	end
	else
		log.error("FsTest.readFile." .. filename, "文件不存在或文件输入格式不正确")
	end
end

local function writeFileA(filename, value)
	local filehandle = io.open(filename, "a+")
	if filehandle then
		local res, info = filehandle:write(value)
		filehandle:close()
	else
		log.error("FsTest.WriteFileA." .. filename, "文件不存在或文件输入格式不正确")
	end
end

local function writeFileW(filename, value)
	local filehandle = io.open(filename, "w")
	if filehandle then
		filehandle:write(value)
		filehandle:close()
	else
		log.error("FsTest.WriteFileW." .. filename, "文件不存在或文件输入格式不正确")
	end
end

local function deleteFile(filename)
	os.remove(filename)
end

local getDirContent

getDirContent = function(dirPath, level)
    local ftb = {}
    local dtb = {}
    level = level or "    "
    local tag = " "
    if not io.opendir(dirPath) then return end
    while true do
        local fType, fName, fSize = io.readdir()
        if fType == 32 then
            table.insert(ftb, {name = fName, size = fSize})
        elseif fType == 16 then
            table.insert(dtb, {name = fName, path = dirPath .. "/" .. fName})
        else
            break
        end
    end
    io.closedir(dirPath)
    for i = 1, #ftb do 
        if i==#ftb then
            log.info(tag, level .. "└─", ftb[i].name, "[" .. ftb[i].size .. " Bytes]")
        else
            log.info(tag, level .. "├─", ftb[i].name, "[" .. ftb[i].size .. " Bytes]")
        end
    end
    for i = 1, #dtb do 
        if i==#dtb then
            log.info(tag, level.."└─", dtb[i].name)
            getDirContent(dtb[i].path, level .. "  ")
        else
            log.info(tag, level.."├─", dtb[i].name)
            getDirContent(dtb[i].path, level .. "│ ")
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

-- SD卡读写测试
sys.taskInit(
	function()
		local sdcardPath = "/sdcard0"
        sys.wait(5000)
        --挂载SD卡
        io.mount(io.SDCARD)
        
        --第一个参数1表示sd卡
        --第二个参数1表示返回的总空间单位为KB
        local sdCardTotalSize = rtos.get_fs_total_size(1, 1)
        log.info("FsTest.SdCard0.TotalSize", sdCardTotalSize .. " KB")
        
        local sdCardFreeSize = rtos.get_fs_free_size(1, 1)
        log.info("FsTest.SdCard0.FreeSize", sdCardFreeSize .. " KB")
        
        getDirContent(sdcardPath)

		local testPath = sdcardPath .. "/FsTestPath"
		local mkdirRes = rtos.make_dir(testPath)
		log.info("FsTest.SdCardTest.MkdirRes", mkdirRes)

		deleteFile(testPath .. "/FsWriteTest1.txt")
		if mkdirRes == true then
			while true do
				writeFileA(testPath .. "/FsWriteTest1.txt", "This is a FsWriteATest\n")
				readFile(testPath .. "/FsWriteTest1.txt")
				writeFileW(testPath .. "/FsWriteTest2.txt", "This is a FsWriteWTest\n")
				readFile(testPath .. "/FsWriteTest2.txt")
				sys.wait(20000)
			end
		end


        --卸载SD卡
        io.unmount(io.SDCARD)
    end
)

-- 模块内部FLASH读写测试
sys.taskInit(
	function ()
        sys.wait(5000)
		local testPath = "/FsTestPath"
		local mkdirRes = rtos.make_dir(testPath)
		log.info("FsTest.FlashTest.MkdirRes", mkdirRes)

		deleteFile(testPath .. "/FsWriteTest1.txt")
		if mkdirRes == true then
			while true do
				writeFileA(testPath .. "/FsWriteTest1.txt", "This is a FsWriteATest\n")
				readFile(testPath .. "/FsWriteTest1.txt")
				writeFileW(testPath .. "/FsWriteTest2.txt", "This is a FsWriteWTest\n")
				readFile(testPath .. "/FsWriteTest2.txt")
				sys.wait(20000)
			end
		end
	end
)
