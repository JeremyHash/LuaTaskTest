-- LvglTest
-- Author:LuatTest
-- CreateDate:20210609
-- UpdateDate:20210609
module(..., package.seeall)

local tag = "LvglTest"

--lcd_config
local function init()
    local para =
    {
        width = 128, --分辨率宽度，128像素；用户根据屏的参数自行修改
        height = 160, --分辨率高度，160像素；用户根据屏的参数自行修改
        bpp = 16, --位深度，彩屏仅支持16位
        bus = lvgl.BUS_SPI4LINE, --LCD专用SPI引脚接口，不可修改
        xoffset = 2, --X轴偏移
        yoffset = 1, --Y轴偏移
        freq = 13000000, --spi时钟频率，支持110K到13M（即110000到13000000）之间的整数（包含110000和13000000）
        pinrst = pio.P0_14, --reset，复位引脚
        pinrs = pio.P0_18, --rs，命令/数据选择引脚
        --初始化命令
        --前两个字节表示类型：0001表示延时，0000或者0002表示命令，0003表示数据
        --延时类型：后两个字节表示延时时间（单位毫秒）
        --命令类型：后两个字节命令的值
        --数据类型：后两个字节数据的值
        initcmd =
        {
            0x00020011,
            0x00010078,
            0x000200B1,
            0x00030002,
            0x00030035,
            0x00030036,
            0x000200B2,
            0x00030002,
            0x00030035,
            0x00030036,
            0x000200B3,
            0x00030002,
            0x00030035,
            0x00030036,
            0x00030002,
            0x00030035,
            0x00030036,
            0x000200B4,
            0x00030007,
            0x000200C0,
            0x000300A2,
            0x00030002,
            0x00030084,
            0x000200C1,
            0x000300C5,
            0x000200C2,
            0x0003000A,
            0x00030000,
            0x000200C3,
            0x0003008A,
            0x0003002A,
            0x000200C4,
            0x0003008A,
            0x000300EE,
            0x000200C5,
            0x0003000E,
            0x00020036,
            0x000300C0,
            0x000200E0,
            0x00030012,
            0x0003001C,
            0x00030010,
            0x00030018,
            0x00030033,
            0x0003002C,
            0x00030025,
            0x00030028,
            0x00030028,
            0x00030027,
            0x0003002F,
            0x0003003C,
            0x00030000,
            0x00030003,
            0x00030003,
            0x00030010,
            0x000200E1,
            0x00030012,
            0x0003001C,
            0x00030010,
            0x00030018,
            0x0003002D,
            0x00030028,
            0x00030023,
            0x00030028,
            0x00030028,
            0x00030026,
            0x0003002F,
            0x0003003B,
            0x00030000,
            0x00030003,
            0x00030003,
            0x00030010,
            0x0002003A,
            0x00030005,
            0x00020029,
        },
        --休眠命令
        sleepcmd = {
            0x00020010,
        },
        --唤醒命令
        wakecmd = {
            0x00020011,
        }
    }
    lvgl.disp_init(para)
end

--控制SPI引脚的电压域
pmd.ldoset(15,pmd.LDO_VLCD)

init()

--LCD适配
local disp_pin = pins.setup(11, 0)

--LCD分辨率的宽度和高度(单位是像素)
WIDTH, HEIGHT, BPP = lvgl.disp_get_lcd_info()
--1个ASCII字符宽度为8像素，高度为16像素；汉字宽度和高度都为16像素
CHAR_WIDTH = 8

sys.taskInit(function()
    disp_pin(1)
end)

lvgl.SYMBOL_AUDIO="\xef\x80\x81"
lvgl.SYMBOL_VIDEO="\xef\x80\x88"
lvgl.SYMBOL_LIST="\xef\x80\x8b"
lvgl.SYMBOL_OK="\xef\x80\x8c"
lvgl.SYMBOL_CLOSE="\xef\x80\x8d"
lvgl.SYMBOL_POWER="\xef\x80\x91"
lvgl.SYMBOL_SETTINGS="\xef\x80\x93"
lvgl.SYMBOL_HOME="\xef\x80\x95"
lvgl.SYMBOL_DOWNLOAD="\xef\x80\x99"
lvgl.SYMBOL_DRIVE="\xef\x80\x9c"
lvgl.SYMBOL_REFRESH="\xef\x80\xa1"
lvgl.SYMBOL_MUTE="\xef\x80\xa6"
lvgl.SYMBOL_VOLUME_MID="\xef\x80\xa7"
lvgl.SYMBOL_VOLUME_MAX="\xef\x80\xa8"
lvgl.SYMBOL_IMAGE="\xef\x80\xbe"
lvgl.SYMBOL_EDIT="\xef\x8C\x84"
lvgl.SYMBOL_PREV="\xef\x81\x88"
lvgl.SYMBOL_PLAY="\xef\x81\x8b"
lvgl.SYMBOL_PAUSE="\xef\x81\x8c"
lvgl.SYMBOL_STOP="\xef\x81\x8d"
lvgl.SYMBOL_NEXT="\xef\x81\x91"
lvgl.SYMBOL_EJECT="\xef\x81\x92"
lvgl.SYMBOL_LEFT="\xef\x81\x93"
lvgl.SYMBOL_RIGHT="\xef\x81\x94"
lvgl.SYMBOL_PLUS="\xef\x81\xa7"
lvgl.SYMBOL_MINUS="\xef\x81\xa8"
lvgl.SYMBOL_EYE_OPEN="\xef\x81\xae"
lvgl.SYMBOL_EYE_CLOSE="\xef\x81\xb0"
lvgl.SYMBOL_WARNING="\xef\x81\xb1"
lvgl.SYMBOL_SHUFFLE="\xef\x81\xb4"
lvgl.SYMBOL_UP="\xef\x81\xb7"
lvgl.SYMBOL_DOWN="\xef\x81\xb8"
lvgl.SYMBOL_LOOP="\xef\x81\xb9"
lvgl.SYMBOL_DIRECTORY="\xef\x81\xbb"
lvgl.SYMBOL_UPLOAD="\xef\x82\x93"
lvgl.SYMBOL_CALL="\xef\x82\x95"
lvgl.SYMBOL_CUT="\xef\x83\x84"
lvgl.SYMBOL_COPY="\xef\x83\x85"
lvgl.SYMBOL_SAVE="\xef\x83\x87"
lvgl.SYMBOL_CHARGE="\xef\x83\xa7"
lvgl.SYMBOL_PASTE="\xef\x83\xAA"
lvgl.SYMBOL_BELL="\xef\x83\xb3"
lvgl.SYMBOL_KEYBOARD="\xef\x84\x9c"
lvgl.SYMBOL_GPS="\xef\x84\xa4"
lvgl.SYMBOL_FILE="\xef\x85\x9b"
lvgl.SYMBOL_WIFI="\xef\x87\xab"
lvgl.SYMBOL_BATTERY_FULL="\xef\x89\x80"
lvgl.SYMBOL_BATTERY_3="\xef\x89\x81"
lvgl.SYMBOL_BATTERY_2="\xef\x89\x82"
lvgl.SYMBOL_BATTERY_1="\xef\x89\x83"
lvgl.SYMBOL_BATTERY_EMPTY="\xef\x89\x84"
lvgl.SYMBOL_USB="\xef\x8a\x87"
lvgl.SYMBOL_BLUETOOTH="\xef\x8a\x93"
lvgl.SYMBOL_TRASH="\xef\x8B\xAD"
lvgl.SYMBOL_BACKSPACE="\xef\x95\x9A"
lvgl.SYMBOL_SD_CARD="\xef\x9F\x82"
lvgl.SYMBOL_NEW_LINE="\xef\xA2\xA2"

--page1
function page1create()
    scr = lvgl.cont_create(nil, nil)
    cv = lvgl.canvas_create(scr, nil)
	lvgl.canvas_set_buffer(cv, 100, 100)
    lvgl.obj_align(cv, nil, lvgl.ALIGN_CENTER, 0, 0)
    layer_id = lvgl.canvas_to_disp_layer(cv)
    disp.setactlayer(layer_id)
    width, data = qrencode.encode('http://www.openluat.com')
    l_w, l_h = disp.getlayerinfo()
    displayWidth = 100
    disp.putqrcode(data, width, displayWidth, (l_w-displayWidth)/2, (l_h-displayWidth)/2)
    disp.update()
    label = lvgl.label_create(scr, nil)
    lvgl.label_set_recolor(label, true)
    lvgl.label_set_text(label, "#008080 上海合宙")
    lvgl.obj_align(label, cv, lvgl.ALIGN_OUT_BOTTOM_MID, 0, 2)
    return scr
end

--page2
arc = nil

angles = 0

local function arc_loader()
	angles = angles + 5
	if angles < 180 then
		lvgl.arc_set_angles(arc, 180-angles, 180)
	else
		lvgl.arc_set_angles(arc, 540-angles, 180)
	end
	if angles == 360 then
		angles = 0
	end
end

function page2create()
    scr = lvgl.cont_create(nil, nil)
    style = lvgl.style_t()
    lvgl.style_copy(style, lvgl.style_plain)
    style.line.color = lvgl.color_hex(0x800000)
    style.line.width = 4

    arc = lvgl.arc_create(scr, nil)
    lvgl.arc_set_style(arc, lvgl.ARC_STYLE_MAIN, style)
    lvgl.arc_set_angles(arc, 180, 180)
    lvgl.obj_set_size(arc, 40, 40)
    lvgl.obj_align(arc, nil, lvgl.ALIGN_CENTER, -30, -30)
    arc_label = lvgl.label_create(scr, nil)
    lvgl.label_set_text(arc_label, "加载器")
    lvgl.obj_align(arc_label, arc, lvgl.ALIGN_OUT_RIGHT_MID, 4, 0)

    btn = lvgl.btn_create(scr, nil)
    btn_label = lvgl.label_create(btn, nil)
    lvgl.label_set_text(btn_label, "按钮")
    lvgl.obj_align(btn, nil, lvgl.ALIGN_CENTER, 0, 40)
    lvgl.obj_set_size(btn, 60, 60)

    sys.timerLoopStart(arc_loader, 100)

    return scr
end

--page3
btn = nil

local function set_y(btn, value)
	lvgl.obj_set_y(btn, value)
end

anim = nil

local function stop_anim()
	lvgl.anim_del(anim, set_y)
	lvgl.obj_set_y(btn, 10)
end

function page3create()
	theme = lvgl.theme_material_init(460, nil)
	lvgl.theme_set_current(theme)
    scr = lvgl.cont_create(nil, nil)
    btn = lvgl.btn_create(scr, nil)
    lvgl.obj_set_pos(btn, 10, 10)
    lvgl.obj_set_size(btn, 80, 50)
    label = lvgl.label_create(btn, nil)
    lvgl.label_set_text(label, "动画")
    anim = lvgl.anim_t()
 
    lvgl.anim_set_values(anim, -lvgl.obj_get_height(btn), lvgl.obj_get_y(btn), lvgl.ANIM_PATH_OVERSHOOT)
    lvgl.anim_set_time(anim, 300, -2000)
    lvgl.anim_set_repeat(anim, 500)
    lvgl.anim_set_playback(anim, 500)
    lvgl.anim_set_exec_cb(anim, btn, set_y)
    lvgl.anim_create(anim)

    btn2 = lvgl.btn_create(scr, nil)
    lvgl.obj_set_pos(btn2, 10, 80)
    lvgl.obj_set_size(btn2, 100, 50)
    btn2_label = lvgl.label_create(btn2, nil)
    lvgl.label_set_text(btn2_label, "样式动画")

    btn2_style = lvgl.style_t()
    lvgl.style_copy(btn2_style, lvgl.btn_get_style(btn, lvgl.BTN_STYLE_REL))
    lvgl.btn_set_style(btn2, lvgl.BTN_STYLE_REL, btn2_style)
    style_anim = lvgl.anim_t()
    lvgl.style_anim_init(style_anim)
    lvgl.style_anim_set_styles(style_anim, btn2_style, lvgl.style_btn_rel, lvgl.style_pretty)
    lvgl.style_anim_set_time(style_anim, 500, 500)
    lvgl.style_anim_set_playback(style_anim, 500)
    lvgl.style_anim_set_repeat(style_anim, 500)
    lvgl.style_anim_create(style_anim)
    sys.timerStart(stop_anim, 3000)
    return scr
end

--page4
function page4create()
	black = lvgl.color_make(0, 0, 0)
	white = lvgl.color_make(0xff, 0xff, 0xff)
    scr = lvgl.cont_create(nil, nil)
    style_sb = lvgl.style_t()
    style_sb.body.main_color = black
    style_sb.body.grad_color = black
    style_sb.body.border.color = white
    style_sb.body.border.width = 1
    style_sb.body.border.opa = lvgl.OPA_70
    style_sb.body.radius = lvgl.RADIUS_CIRCLE
    style_sb.body.opa = lvgl.OPA_60
    style_sb.body.padding.right = 3
    style_sb.body.padding.bottom = 3
    style_sb.body.padding.inner = 8

    page = lvgl.page_create(scr, nil)
    lvgl.obj_set_size(page, 100, 150)
    lvgl.obj_align(page, nil, lvgl.ALIGN_CENTER, 0, 0)
    lvgl.page_set_style(page, lvgl.PAGE_STYLE_SB, style_sb)

    label = lvgl.label_create(page, nil)
    lvgl.label_set_long_mode(label, lvgl.LABEL_LONG_BREAK)
    lvgl.obj_set_width(label, lvgl.page_get_fit_width(page))
    lvgl.label_set_recolor(label, true)
    lvgl.label_set_text(label, [[
    	Air722UG
    	Air724UG
    	行1
    	行2
    	行3]])
    return scr
end

--page5

function page5create()
    scr = lvgl.cont_create(nil, nil)
    list = lvgl.list_create(scr, nil)
    lvgl.obj_set_size(list, 100, 140)
    lvgl.obj_align(list, nil, lvgl.ALIGN_CENTER, 0, 0)
    lvgl.list_add_btn(list, lvgl.SYMBOL_LIST, "我是列表")
    lvgl.list_add_btn(list, lvgl.SYMBOL_OK, "确认")
    lvgl.list_add_btn(list, lvgl.SYMBOL_PAUSE, "暂停")
    return scr
end

--page6

cb = nil

test_data = "blablabla"

local function test_cb(cb, e)
	if e == lvgl.EVENT_CLICKED then
		lvgl.cb_set_checked(cb, true)
		print(lvgl.event_get_data())
	end
end

local function click()
	lvgl.event_send(cb, lvgl.EVENT_CLICKED, test_data)
end

function page6create()
    scr = lvgl.cont_create(nil, nil)
    cb = lvgl.cb_create(scr, nil)
    lvgl.cb_set_text(cb, "我同意")
    lvgl.obj_align(cb, nil, lvgl.ALIGN_CENTER, 0, 0)
    lvgl.obj_set_event_cb(cb, test_cb)
    sys.timerStart(click, 2000)
    return scr
end

--page7

scr2 = nil

local function close_win(btn, event)
	if event == lvgl.EVENT_RELEASED then
		win = lvgl.win_get_from_btn(btn)
		lvgl.obj_del(win)
		lvgl.disp_load_scr(scr2)
	end
end

function page7create()
    scr = lvgl.cont_create(nil, nil)
    scr2 = lvgl.cont_create(nil, nil)
    win = lvgl.win_create(scr, nil)

    lvgl.win_set_title(win, "标题")

    close_btn = lvgl.win_add_btn(win, lvgl.SYMBOL_CLOSE)
    lvgl.obj_set_event_cb(close_btn, close_win)
    lvgl.win_add_btn(win, lvgl.SYMBOL_SETTINGS)

    txt = lvgl.label_create(win, nil)
    lvgl.label_set_recolor(txt, true)
    lvgl.label_set_text(txt, [[This #987654 is the# content of the window
                           You can add control buttons to
                           the window header
                           The content area becomes automatically
                           scrollable is it's large enough.
                           You can scroll the content
                           See the scroll bar on the right!]])

    ml = lvgl.label_create(scr2, nil)
    lvgl.label_set_recolor(ml, true)
    lvgl.label_set_text(ml, "#123456 窗口# #897632 已关闭#")
    lvgl.obj_align(ml, nil, lvgl.ALIGN_CENTER, 0, 0)
    sys.timerStart(lvgl.event_send, 3000, close_btn, lvgl.EVENT_RELEASED, nil)
    return scr
end

--page8
function page8create()
    scr = lvgl.cont_create(nil, nil)
    style_bg = lvgl.style_t()
    style_indic = lvgl.style_t()
    style_knob = lvgl.style_t()

    lvgl.style_copy(style_bg, lvgl.style_pretty)
    style_bg.body.main_color = lvgl.color_hex(0x00ff00)
    style_bg.body.grad_color = lvgl.color_hex(0x000080)
    style_bg.body.radius = lvgl.RADIUS_CIRCLE
    style_bg.body.border.color = lvgl.color_hex(0xffffff)

    lvgl.style_copy(style_indic, lvgl.style_pretty_color)
    style_indic.body.radius = lvgl.RADIUS_CIRCLE
    style_indic.body.shadow.width = 8
    style_indic.body.shadow.color = style_indic.body.main_color
    style_indic.body.padding.left = 3
    style_indic.body.padding.right = 3
    style_indic.body.padding.top = 3
    style_indic.body.padding.bottom = 3

    lvgl.style_copy(style_knob, lvgl.style_pretty)
    style_knob.body.radius = lvgl.RADIUS_CIRCLE
    style_knob.body.opa = lvgl.OPA_70
    style_knob.body.padding.top = 10
    style_knob.body.padding.bottom = 10

    slider = lvgl.slider_create(scr, nil)
    lvgl.obj_set_size(slider, 100, 20)
    lvgl.slider_set_style(slider, lvgl.SLIDER_STYLE_BG, style_bg)
    lvgl.slider_set_style(slider, lvgl.SLIDER_STYLE_INDIC, style_indic)
    lvgl.slider_set_style(slider, lvgl.SLIDER_STYLE_KNOB, style_knob)
    lvgl.obj_align(slider, nil, lvgl.ALIGN_CENTER, 0, 0)

    label = lvgl.label_create(scr, nil)
    lvgl.label_set_text(label, "滑动条")
    lvgl.obj_align(label, slider, lvgl.ALIGN_OUT_BOTTOM_MID, 0, 0)
    return scr
end

--page9
sw = nil

local function sw_on()
	lvgl.sw_on(sw, lvgl.ANIM_ON)
end

local function sw_off()
	lvgl.sw_off(sw, lvgl.ANIM_ON)
end

local function sw_toggle(on)
	if on then
		sw_on()
	else
		sw_off()
	end
	sys.timerStart(sw_toggle, 1000, not on)
end

function page9create()
	scr = lvgl.cont_create(nil, nil)
	bg_style = lvgl.style_t()
	indic_style = lvgl.style_t()
	knob_on_style = lvgl.style_t()
	knob_off_style = lvgl.style_t()

	lvgl.style_copy(bg_style, lvgl.style_pretty)
	bg_style.body.radius = lvgl.RADIUS_CIRCLE
	bg_style.body.padding.top = 6
	bg_style.body.padding.bottom = 6

	lvgl.style_copy(indic_style, lvgl.style_pretty_color)
	indic_style.body.radius = lvgl.RADIUS_CIRCLE
	indic_style.body.main_color = lvgl.color_hex(0x9fc8ef)
	indic_style.body.grad_color = lvgl.color_hex(0x9fc8ef)
	indic_style.body.padding.left = 0
	indic_style.body.padding.right = 0
	indic_style.body.padding.top = 0
	indic_style.body.padding.bottom = 0

	lvgl.style_copy(knob_off_style, lvgl.style_pretty_color)
	knob_off_style.body.radius = lvgl.RADIUS_CIRCLE
	knob_off_style.body.shadow.width = 4
	knob_off_style.body.shadow.type = lvgl.SHADOW_BOTTOM

	lvgl.style_copy(knob_on_style, lvgl.style_pretty_color)
	knob_on_style.body.radius = lvgl.RADIUS_CIRCLE
	knob_on_style.body.shadow.width = 4
	knob_on_style.body.shadow.type = lvgl.SHADOW_BOTTOM

	sw = lvgl.sw_create(scr, nil)
	lvgl.obj_align(sw, nil, lvgl.ALIGN_CENTER, 0, 0)

	lvgl.sw_set_style(sw, lvgl.SW_STYLE_BG, bg_style)
	lvgl.sw_set_style(sw, lvgl.SW_STYLE_INDIC, indic_style)
	lvgl.sw_set_style(sw, lvgl.SW_STYLE_KNOB_ON, knob_on_style)
	lvgl.sw_set_style(sw, lvgl.SW_STYLE_KNOB_OFF, knob_off_style)

	label = lvgl.label_create(scr, nil)
	lvgl.label_set_text(label, "开关")
	lvgl.obj_align(label, sw, lvgl.ALIGN_OUT_BOTTOM_MID, 0, 2)
	sys.timerStart(sw_toggle, 1000, true)
	return scr

end

scrs = {page1create, page2create, page3create, page4create, page5create, page6create, page7create, page8create, page9create}

local function empty()
	c = lvgl.cont_create(nil, nil)
	img = lvgl.img_create(c, nil)
	lvgl.img_set_src(img, "/lua/logo.png")
	lvgl.obj_align(img, nil, lvgl.ALIGN_CENTER, 0, 0)
	lvgl.disp_load_scr(c)
end

sys.taskInit(function ()
    local count = 1
    lvgl.init(empty, nil)
    while true do 
       sys.wait(2000)
       log.info(tag , "第" .. count .. "次")
       sys.wait(1000)
       for k, v in ipairs(scrs) do
    	   c = v()
    	   lvgl.disp_load_scr(c)
    	   sys.wait(5000)
       end
       count = count + 1
    end
end)
