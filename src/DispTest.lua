module(...,package.seeall)

--LCD分辨率的宽度和高度(单位是像素)
WIDTH, HEIGHT, BPP = disp.getlcdinfo()

log.info("DispTest", "更新屏幕")
-- 清空屏幕显示缓冲区
disp.clear()
-- 将天气信息渲染到相应位置
disp.puttext(common.utf8ToGb2312("TestTestTest"),0,10)
-- 更新屏幕显示内容
disp.update()