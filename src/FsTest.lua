module(...,package.seeall)

local test_path = "/Jeremy"

local function writevala(filename,value)--在指定文件中添加内容,函数名最后一位就是打开的模式
    local filehandle = io.open(filename,"a+")--第一个参数是文件名，后一个是打开模式'r'读模式,'w'写模式，对数据进行覆盖,'a'附加模式,'b'加在模式后面表示以二进制形式打开
    if filehandle then
        filehandle:write(value)--写入要写入的内容
        filehandle:close()
    else
        print("文件不存在或文件输入格式不正确") --打开失败
    end
end

local function deletefile(filename)
    os.remove(filename)
end


sys.taskInit(
    function()
        while true do
            print("get_fs_free_size: "..rtos.get_fs_free_size().." Bytes")
            if rtos.make_dir(test_path) then
                print("get_fs_free_size: "..rtos.get_fs_free_size().." Bytes")
                log.info("testFs.writevala")
                writevala(test_path.."/test.txt","great")

                print("get_fs_free_size: "..rtos.get_fs_free_size().." Bytes")

                log.info("testFs.deletefile")
                deletefile(test_path.."/test.txt")
                print("get_fs_free_size: "..rtos.get_fs_free_size().." Bytes")
            end
            if rtos.remove_dir(test_path) then
                print("get_fs_free_size: "..rtos.get_fs_free_size().." Bytes")
            end
            sys.wait(5000)
        end
    end
)
