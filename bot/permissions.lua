function is_administrate(msg, gid)
  local var = true
  if not config.administration[gid] then
    var = false
	tdcli.sendMessage(gid, msg.id_, 1,  '<b>I do not administrate this group</b>', 1, 'html')
	
  end
  return var
end
function is_sudo(user_id)
  local var = false
  if config.sudo_users[user_id] then
    var = true
  end
  return var
end
function is_admin(user_id)
  local var = false
  if config.administrators[user_id] then
    var = true
  end
  if config.sudo_users[user_id] then
    var = true
  end
  return var
end
function is_owner(msg, chat_id, user_id)
  local var = false
  local data = load_data(config.administration[chat_id])
  if data.owners == nil then
    var = false
  elseif data.owners[user_id] then
    var = true
  end
  if config.administrators[user_id] then
    var = true
  end
  if config.sudo_users[user_id] then
    var = true
  end
  return var
end
function is_mod(msg, chat_id, user_id)
  local var = false
  local data = load_data(config.administration[chat_id])
  if data.moderators == nil then
    var = false
  elseif data.moderators[user_id] then
    var = true
  end
  if data.owners == nil then
    var = false
  elseif data.owners[user_id] then
    var = true
  end
  if config.administrators[user_id] then
    var = true
  end
  if config.sudo_users[user_id] then
    var = true
  end
  return var
end
