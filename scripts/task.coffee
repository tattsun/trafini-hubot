# Description:
#   trafini
#
# Commands:
#   None

module.exports = (robot) ->
  trafini = "http://localhost/"
  apikey = "your_api_key"

  query = (args, handler) ->
    robot.http(trafini)
      .query({
        q: JSON.stringify(args),
        apikey: apikey
      })
      .post() (err, res, body) ->
        handler body
  isOneByteChar = (ch) ->
    if ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'.indexOf(ch) >= 0
      return true
    else
      return false
  # len: 半角でカウント
  cutStrIn = (str, len) ->
    newlen = 0
    newstr = ""
    for i in [0..str.length-1]
      if newlen >= len
        break
      if isOneByteChar(str[i])
        newstr += str[i]
        newlen += 1
      else
        newstr += str[i]
        newlen += 2
    while newlen < len
      newstr += " "
      newlen += 1
    return newstr


  robot.respond /(t|task) (.*)/i, (msg) ->
    args = msg.match[2].split(" ")
    cmd = args[0]
    handler = (res) ->
      o = "```"
      switch cmd
        when "show"
          o += "----------------------------------------------------------------------\n"
          for t in res
            finishchk = if t.Finished then "x" else " "
            o += "#{t.Id} [#{finishchk}] #{cutStrIn(t.Priority+"", 3)} #{cutStrIn(t.Summary, 50)}"
            o += " #{t.Tags}\n"
        when "d", "detail"
          if res.Id?
            t = res
            finishchk = if t.Finished then "x" else " "
            o += "#{t.Id} [#{finishchk}]\n"
            o += "Priority: #{t.Priority}\n"
            o += "Tags:     #{t.Tags}\n"
            o += "Summary:  #{t.Summary}\n"
            o += "Detail:   #{t.Detail}\n"
          else
            o += res
        when "s", "set"
          o += "successfully updated"
        when "a", "add"
          o += res
        when "finish"
          o += "successfully updated"
        when "unfinish"
          o += "successfully updated"
        else
          o += "不明なコマンドです: #{cmd}"
      o += "```"
      o
    query args, (res) ->
      msg.send handler(JSON.parse(res))
