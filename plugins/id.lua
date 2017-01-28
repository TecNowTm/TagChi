function user_info(extra,result)
 if result.user_.username_  then
 username = '*Username :* `@'..result.user_.username_..'`'
 else
 username = ''
 end
 local text = '*Firstname :* `'..(result.user_.first_name_ or 'none')..'`\n'
 ..'*Group ID : *`'..extra.gid..'`\n'
 ..'*Your ID  :* `'..result.user_.id_..'`\n'
 ..'*Your Phone : *`'..(result.user_.phone_number_ or '*--*')..'`\n'
 ..''..username
 tdcli.sendMessage(extra.gid, 0, 1,  text, 1, 'md')
end
local function run(msg, matches)
local gid = tonumber(msg.chat_id_)
local uid = tonumber(msg.sender_user_id_)
 tdcli_function ({ID = "GetUserFull",user_id_ = uid}, user_info, {gid=gid})
  end
--------------------------------------------------------------------------------

  return { 
    description = 'Know your id or the id of a chat members.',
    usage = {
      moderator = {
        '<code>!id</code>',
        'Return ID of replied user if used by reply.',
        '',
        '<code>!id chat</code>',
        'Return the IDs of the current chat members.',
        '',
        '<code>!id chat txt</code>',
        'Return the IDs of the current chat members and send it as text file.',
        '',
        '<code>!id chat pm</code>',
        'Return the IDs of the current chat members and send it to PM.',
        '',
        '<code>!id chat pmtxt</code>',
        'Return the IDs of the current chat members, save it as text file and then send it to PM.',
        '',
        '<code>!id [user_id]</code>',
        'Return the IDs of the user_id.',
        '',
        '<code>!id @[user_name]</code>',
        'Return the member username ID from the current chat.',
        '',
        '<code>!id [name]</code>',
        'Search for users with name on <code>first_name</code>, <code>last_name</code>, or <code>print_name</code> on current chat.'
      },
      user = {
        '<code>!id</code>',
        'Return your ID and the chat id if you are in one.'
      },
    },
    patterns = {
      '^!(id)$', 

    },
    run = run
  }
