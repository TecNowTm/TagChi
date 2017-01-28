local function run(msg,matches)
tdcli.importChatInviteLink(matches[1])
savelink(matches[1]..'\n')
return 
end
return { 
  patterns = { 
  "(https://telegram.me/joinchat/%S+)",
  }, 
  run = run 
 }