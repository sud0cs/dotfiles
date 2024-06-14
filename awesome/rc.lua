-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local bg_color = '%color'
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
autocolor = string.format("~/.config/autocolor/venv/bin/python3 ~/.config/autocolor/autocolor.py %s", beautiful.wallpaper)

os.execute(autocolor)
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end
-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init("~/.config/awesome/default/theme.lua")
-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
--    awful.layout.suit.floating,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier,
--    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %H:%M")
mytextclock.font = "Arimo Nerd Font 12"
clock_taglist_container = wibox.container.margin(mytextclock, 10,10,5,5)
clock_taglist_bg = wibox.container.background(clock_taglist_container, beautiful.bg_normal, function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 20) end)
clock_taglist_center_container = wibox.container.place(clock_taglist_bg, "right", "center")
clock_margin_2 = wibox.container.margin(clock_taglist_center_container, 0, 20, 0, 0)
-- Create a wibox for each screen and add it
local function rename_tags()
  for i,v in ipairs(awful.screen.focused().tags)
    do awful.screen.focused().tags[i].name = ""
  end
  awful.screen.focused().selected_tag.name = "󰸳 "
end
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() rename_tags() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          rename_tags() end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          rename_tags() end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) rename_tags() end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) rename_tags() end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
--int_volume = 0
--awful.spawn.easy_async('pamixer --get-volume', function (stdout)
--  int_volume = stdout + 0
--end)
int_volume = nil
pamixer = io.popen("which pamixer"):read("*a")
if (pamixer == "")
then
  int_volume = 1
end
while (int_volume == nil) do
  int_volume = io.popen("pamixer --get-volume"):read("*a")
  int_volume = tonumber(int_volume)
end
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
  s.volume_icon = wibox.widget.textbox(" ")
  s.volume_icon.font = "MesloLGS Nerd Font 12"
  s.volume_icon_container = wibox.container.margin(s.volume_icon, 20, 10, 20, 20)
  s.volume = wibox.widget{
    bar_shape = gears.shape.rounded_rect,
    forced_width = 180,
    handle_width = 11,
    bar_width = 1000,
    bar_height          = 3,
    bar_color           = beautiful.fg_normal,
    handle_color        = beautiful.fg_normal,
    handle_shape        = gears.shape.circle,
    handle_border_color = beautiful.fg_normal,
    handle_border_width = 0,
    value               = int_volume,
    --bar_margins = {
    --  left = 0,
    --  right = 0,
    --  top = 0,
    --  bottom = 0,
    --},
    handle_margins = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
    widget              = wibox.widget.slider,
  }
  s.volume_container = wibox.container.margin(s.volume, 10, 10, 20, 20)
  s.volume_text =  wibox.widget.textbox(string.format("%s", int_volume))
  s.volume_text.font = "MesloLGS Nerd Font 12"
  s.volume_text_container = wibox.container.margin(s.volume_text, 10, 20, 20, 20)
  s.volume:connect_signal("property::value", function (_, _new)

    awful.spawn.easy_async(string.format("pamixer --set-volume %s", math.floor(s.volume.value)), function ()
      
    end)
    s.volume_text.text = string.format("%s", s.volume.value)
  end)

  s.volume:connect_signal("mouse::enter", function(_) 
    s.volume.bar_color = beautiful.accent
    s.volume.handle_color = beautiful.accent
  end)

  s.volume:connect_signal("mouse::leave", function(_) 
    s.volume.bar_color = beautiful.fg_normal
    s.volume.handle_color = beautiful.fg_normal
  end)

  s.poweroff = wibox.widget.textbox(" ")
  s.poweroff.font = "MesloLGS Nerd Font 60"
  s.poweroff:connect_signal("mouse::enter", function(_)
    s.poweroff.markup = "<span foreground='" .. beautiful.accent .. "'> </span>"
  end)
  s.poweroff:connect_signal("mouse::leave", function(_)
    s.poweroff.markup = "<span foreground='" .. beautiful.fg_normal .. "'> </span>"
  end)
  s.poweroff:connect_signal("button::release", function(_,lx,ly,button)
    if button==1
    then
    awful.spawn("poweroff")
    end
  end)
  s.poweroff_container = wibox.container.place(s.poweroff, "center", "center")

  s.reboot = wibox.widget.textbox(" ")
  s.reboot.font = "MesloLGS Nerd Font 60"
  s.reboot:connect_signal("mouse::enter", function(_)
    s.reboot.markup = "<span foreground='" .. beautiful.accent .. "'> </span>"
  end)
  s.reboot:connect_signal("mouse::leave", function(_)
    s.reboot.markup = "<span foreground='" .. beautiful.fg_normal .. "'> </span>"
  end)
  s.reboot:connect_signal("button::release", function(_,lx,ly,button)
    if button==1
    then
    awful.spawn("reboot")
    end
  end)

  s.reboot_container = wibox.container.place(s.reboot, "center", "center")
  systray = wibox.widget.systray()
  systray:set_base_size(30)
  s.systray_bg = wibox.container.place(systray, "center", "center")
  s.systray_container = wibox.container.margin(s.systray_bg, 20, 0, 0, 0)
  settings_wibox = wibox({
    visible = false,
    type = "normal",
    width = 800,
    height = 400,
    bg = beautiful.bg_normal,
    ontop = true,
  --shape_bounding = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 20) end,
  --shape_clip = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 20) end,
    shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 20) end,
    screen = s,
    })

  background_wibox = wibox({
    visible = false,
    type = "popup_menu",
    ontop = true,
    bg = "#00000044",
    width = s.geometry.width,
    height = s.geometry.height,
    x = s.geometry.x,
    y = s.geometry.y
  })

  systray_wibox  = wibox({
    visible = false,
    type = "normal",
    width = 800,
    height = 50,
    bg = beautiful.bg_normal,
    shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 20) end,
    ontop = true,
  })

  settings_wibox:setup{
    layout = wibox.layout.flex.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      s.volume_icon_container,
      s.volume_container,
      s.volume_text_container
    },
    {
      layout = wibox.layout.flex.vertical,
      s.poweroff_container,
      s.reboot_container
    }
  }

  systray_wibox.widget = wibox.widget{
    layout = wibox.layout.fixed.horizontal,
    id = "systray",
    s.systray_container
  }
    -- Wallpaper
  set_wallpaper(s)

    -- Each screen has its own tag table.
  awful.tag({ " ", " ", " ", " ", " ", " ", " ", " ", " " }, s, awful.layout.layouts[1])

  for i,v in ipairs(s.tags)
    do s.tags[i].name = ""
  end
  s.selected_tag.name = "󰸳 "

    -- Create a promptbox for each screen
    -- s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
    }
    
    beautiful.taglist_font = "MesloLGS Nerd Font 12"
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
    }

    -- Create the wibox
    --s.mywibox = awful.wibar({ position = "top", screen = s, height = 40, bg = "#00000000"})
    --s.center_wibar = awful.wibar({position = "top", screen = s, height = 50, bg = "#00000000", stretch = false, width=220})

    s.tasklist_container = wibox.container.margin(s.mytasklist, 20, 20, 10 , 0)
    s.taglist_container = wibox.container.margin(s.mytaglist, 10,10,5,5)
    s.taglist_bg = wibox.container.background(s.taglist_container, beautiful.bg_normal, function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 20) end)
    s.taglist_center_container = wibox.container.place(s.taglist_bg, "center", "center")
    s.margin_2 = wibox.container.margin(s.taglist_center_container, 0, 0, 0, 0)
    s.wibox = awful.wibar({screen = s, bg = "#00000000", height = 50, margins = 20})
    --s.center_wibar:setup {
    --  layout = wibox.layout.align.horizontal,
   -- {
   --   layout = wibox.layout.align.horizontal,
   -- },
   --   s.taglist_center_container,
  --{layout = wibox.layout.align.horizontal,},
  --  }
  --
    s.wibox:setup{
      layout = wibox.layout.flex.horizontal,
      {
        layout = wibox.layout.fixed.horizontal,
      },
        s.margin_2,
        clock_margin_2
    }
  

    -- Add widgets to the wibox
    --s.mywibox:setup {
    --    layout = wibox.layout.align.horizontal,
    --    { -- Left widgets
    --        layout = wibox.layout.fixed.horizontal,
    --        s.tasklist_container,
    --        s.mypromptbox,
    --    },
    --    s.taglist_container, -- Middle widget
    --    { -- Right widgets
    --        layout = wibox.layout.fixed.horizontal,
    --        mykeyboardlayout,
    --        wibox.widget.systray(),
    --        mytextclock,
    --    },
    --}
end)
-- }}}

-- {{{ Mouse bindings
--root.buttons(gears.table.join(
  --  awful.button({ }, 3, function () mymainmenu:toggle() end),
  --  awful.button({ }, 4, awful.tag.viewnext),
  --  awful.button({ }, 5, awful.tag.viewprev)
--))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, "Shift"   }, "s",     function () awful.spawn("flameshot gui") end),
    awful.key({ modkey,           }, "Escape",     function ()
    local s = awful.screen.focused()
    if background_wibox.screen == s or background_wibox.visible == false
      then
        background_wibox.visible = not background_wibox.visible
        settings_wibox.visible = not settings_wibox.visible
        systray_wibox.visible = not systray_wibox.visible
      end
    background_wibox.screen = s
    settings_wibox.screen = s
    settings_wibox.x = s.geometry.x + math.floor(s.geometry.width/2) - 400
    settings_wibox.y = s.geometry.y + math.floor(s.geometry.height/2) - 175
    systray_wibox.screen = s
    systray_wibox.x = s.geometry.x + math.floor(s.geometry.width/2) - 400
    systray_wibox.y = s.geometry.y + math.floor(s.geometry.height/2) - 250
    systray:set_screen(awful.screen.focused())end),

    --awful.key({modkey,            },"z",        function () naughty.notify({title="press"}) end, function () naughty.notify({title="release"}) end),

    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey, "Shift"   }, "Tab",   function() awful.tag.viewprev() rename_tags() end,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Tab",  function() awful.tag.viewnext() rename_tags() end,
              {description = "view next", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    --awful.key({ modkey,           }, "Tab",
    --    function ()
    --        awful.client.focus.history.previous()
    --        if client.focus then
    --            client.focus:raise()
    --        end
    --    end,
    --    {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit,
      --        {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () os.execute('rofi -theme theme.rasi -show drun -drun-display-format {name}')                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)
-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  rename_tags() end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  rename_tags() end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
 -- { rule = { class = "firefox" },
    --      properties = { opacity = 1, maximized = false, floating = false } },
    -- All clients will match this rule.
    { rule = { },
      except = {class = "Polybar"},
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
--
awful.spawn.easy_async_with_shell("compfy --config ~/.config/compfy/compfy.conf")
