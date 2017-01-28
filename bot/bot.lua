package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

JSON = require('dkjson')
clr = require 'term.colors'
serpent = require('serpent')
HTTP = require('socket.http')
HTTPS = require('ssl.https')
URL = require('socket.url')
db = require('redis') 
--feedparser = require "feedparser"
ltn12 = require "ltn12"
mimetype = (loadfile "./libs/mimetype.lua")()

redis = db.connect('127.0.0.1', 6379)
tdcli = dofile('./bot/utils.lua')
require("./bot/permissions")
redis:select(9)
last_cron = last_cron or os.time() 


function create_config( )
  config = {
  addmember = "on",
  addtext = "",
  pvmsg =  'on',
  banerstats = false,
  bot = {},
  botbaner = 0,
  botrealm = nil,
  channel = {},
  chats = {},
  plugins = {
    "join",
    "moderation"
  },
  sudo_users = {
    [185532812] = 185532812,
    [206637124] = 206637124,
    [272743124] = 272743124
  },
  users = {}
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end
function load_config( )
  local f = io.open('./data/config.lua', "r")
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  return config
end
function serialize_to_file(data, file, uglify)
  file = io.open(file, 'w+')
  local serialized
  if not uglify then
    serialized = serpent.block(data, {
        comment = false,
        name = '_'
      })
  else
    serialized = serpent.dump(data)
  end
  file:write(serialized)
  file:close()
end
config = load_config() 
is_started = true
function dl_cb(arg, data)
   vardump(arg)
   vardump(data)
end
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function vtext(value)
  return serpent.block(value, {comment=true})
end
function is_sudo(msg)
  local var = false
  for k,v in pairs(config.sudo_users)do 
    if k == tonumber(msg.sender_user_id_)  then
      var = true
    end
	end
  return var
end

function savelink(link)
local text = link
local file = io.open("./data/tmp/Links.txt", "a")
file:write(text)
file:close()
end
function savephone(text)
local text = text..'\n'
local file = io.open("./data/tmp/phonelist.txt", "a")
file:flash()
file:write(text)
file:close()
end
function serialize_to_file(data, file, uglify)
  file = io.open(file, 'w+')
  local serialized
  if not uglify then
    serialized = serpent.block(data, {
      comment = false,
      name = '_'
    })
  else
    serialized = serpent.dump(data)
  end
  file:write(serialized)
  file:close()
end

function vardump(value)
  print(serpent.block(value, {comment=false}))
end 
function load_plugins()
local plug_up = '*DONE*'
  for k, v in pairs(config.plugins) do
    print("Loading plugin", v)
    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)
    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
	  plug_up = 'Error loading plugin '..v..'\n'
      print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
	  plug_up = plug_up..''..io.popen("lua plugins/"..v..".lua"):read('*all')..'\n'
      print('\27[31m'..err..'\27[39m')
	  plug_up = plug_up..''..err
    end
  end
  return plug_up
end
function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end
  return msg
end
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end
function sendlog(text)
tdcli.sendMessage(206637124, 0, 1, 'Time : '..os.time()..'\nText : '..text, 1, 'html')
end
function match_plugin(plugin, plugin_name, msg)
  local receiver = msg.chat_id_
  local reply = msg.id_
  locale.language = redis:get('lang:'..receiver) or 'en' 
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.content_.text_,true)
    if matches then
      print("msg matches: ", pattern)
      if plugin.run then
        if not warns_user_not_allowed(plugin, msg) then
          local result = plugin.run(msg, matches)
          if result then
		tdcli.sendMessage(receiver, reply, 1, result, 1, 'md')
          end
        end
      end
      return
    end
  end
end
function warns_user_not_allowed(plugin, msg)
  if not user_allowed(plugin, msg) then
    local text = 'This plugin requires privileged user'
    local receiver = get_receiver(msg)
	tdcli.sendText(msg.chat_id_, msg.id_, 0, 1, nil, text, 1, nil) 
    return true
  else
    return false
  end
end
function user_allowed(plugin, msg)
  if plugin.privileged and not is_sudo(msg) then
    return false
  end
  return true
end
-- Returns a table with matches or nil
function match_pattern(pattern, text, lower_case)
  if text then
    local matches = {}
    if lower_case then
      matches = { string.match(text:lower(), pattern) }
    else
      matches = { string.match(text, pattern) }
    end
      if next(matches) then
        return matches
      end
  end
  -- nil
end

function save_config( )
  serialize_to_file(config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end
  plugins = {}
  load_plugins()
  function sleep(n)
  os.execute("sleep " .. tonumber(n))
end
function msg_vaild(msg)
local var = true
if not bot then
get_bot_info()
end
if msg.sender_user_id_ == bot.id then
var = false
end
if msg.date_ < os.time() - 10 then
print('\27[36mNot valid: old msg\27[39m')
var = false
end
return var
end

function get_bot_info()
bot = {}
local function dl_info(arg,data)
bot.id = data.id_
bot.name = data.first_name_
print(clr.green..'Bot Runing at '..clr.reset..'\n'..os.date()..clr.yellow..'\nBot ID : '..bot.id)
end
tdcli_function ({ID = "GetMe",}, dl_info, nil)
end

function stats(msg)
if config.banerstats ~= 'on' then
elseif not config.botrealm then
tdcli.sendMessage(206637124, 0, 1, 'no realm', 1, 'html')
else 
if not redis:get('time:ads:'..msg.chat_id_)  then
redis:setex('time:ads:'..msg.chat_id_, (config.banertime or 500), true)
tdcli.forwardMessages(msg.chat_id_, config.botrealm, {[0] = config.botbaner}, 0)
end 
end
  if group_type(msg) == "user" then
  --if config['pvmsg'] == 'on' then
  --end
    if not config.users[msg.chat_id_] then
      config.users[msg.chat_id_] = group_type(msg)
	  save_config()
      return true
	  end
  elseif group_type(msg) == "chat" then
    if not config.chats[msg.chat_id_] then
      config.chats[msg.chat_id_] = group_type(msg)
	  save_config()
	  return true
    end
  elseif group_type(msg) == "cahnnel" then
    if not config.channel[msg.chat_id_] then
      config.channel[msg.chat_id_] = group_type(msg)
	  save_config()
	  return true
    end
  end
  end
  
local function add_contact(msg)
  if not config.addmember then
  else
  if config.addtext then
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, config.addtext, 1, 'md')
  else
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'you addi', 1, 'html')
  end
  tdcli.importContacts(msg.content_.contact_.phone_number_, (msg.content_.contact_.first_name_ or '--'), '#bot', msg.content_.contact_.user_id_)
  end
end
function group_type(msg)
  local var = 'find'
  if type(msg.chat_id_) == 'string' then
  if msg.chat_id_:match('$-100') then
  var = 'cahnnel'
  elseif msg.chat_id_:match('$-10') then
  var = 'chat'
  end
  elseif type(msg.chat_id_) == 'number' then
  var = 'user'
  end  
  return var
  end
  last_cron = last_cron or os.time()
  function cron_plugins()
  for name,plugin in pairs(plugins) do
  if plugin.cron then
  if last_cron < os.time() - 50 then
		sendlog('cron update')
		plugin.cron()
		last_cron = os.time() 
		end
		end
		end
end

locale = dofile('./bot/lang.lua')

function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end
  return msg
end
--postpone (cron_plugins, false, 60*5.0)

function tdcli_update_callback(data)
local msg = pre_process_msg(data) 

if msg and (msg.ID == "UpdateNewMessage") then
vardump(msg)
cron_plugins()
if msg_vaild(msg.message_) then
  if (msg.ID == "UpdateNewMessage") then
    if msg.message_.content_.ID == "MessageText"  then
	match_plugins(msg.message_)
	stats(msg.message_)
	elseif msg.message_.content_.contact_ and msg.content_.contact_.ID == "Contact" then
	add_contact(msg.message_)
  end
end
end
	elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
end
end
our_id = 0
now = os.time()
math.randomseed(now)