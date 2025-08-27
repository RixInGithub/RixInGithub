function main()
	dkjson = require("dkjson")
	http = require("http.request")
	issId, issTtl, issUsr = table.unpack(arg)
	issId = tonumber(issId)
	issKey = issTtl:match("^kbd:(%d+)$")
	if issKey == nil then -- its up to me to handle (some ppl are stupid)
		return
	end
	issKey = issKey + 0

	gql = dkjson.encode({
		query = "mutation H($input:CloseIssueInput!){closeIssue(input:$input)}",
		variables = {
			input = {
				issueId = issId.."", -- living the days of number+"" amiright?
				stateReason = "COMPLETED"
			}
		}
	})
	
	hdrs = require("http.headers").new()
	hdrs:append(":method", "POST")
	hdrs:append("content-type", "application/json")
	hdrs:append("authorization", "Bearer "..os.getenv("GH_TOKEN"))
	
	closeReq = http.new_from_uri("https://api.github.com/graphql", hdrs)
	closeReq:set_body(gql)
	
	rmIO = io.open("README.md", "r")
	modsIO = io.open("mods.md", "r")
	readme = rmIO:read("*all")
	mods = {}
	b4ModsData = table.concat({modsIO:read("*line"), modsIO:read("*line")},"\n") -- doesnt end with "\n"
	meCaps, meShift = false, false
	while true do
		local m = modsIO:read("*line")
		if m == nil then break end
		local user,caps,shift = m:match("^|@([^|]-)|([^|]-)|([^|]-)|$")
		if user == nil then break end -- user will only be nil because string.match will return nil into the first var which is user in my case
		caps = caps == "y"
		shift = shift == "y"
		if user==issUsr then
			meCaps = caps
			meShift = shift
			goto continue0 -- do not include user
		end
		table.insert(mods,{user,caps,shift})
		::continue0::
	end
	rmIO:close()
	modsIO:close()
	b4, data, after = readme:match("(.-)<!%-%-HTXT%-%->(.-)<!%-%-HTXT%-%->(.*)")
	b4Txt, txt, afterTxt = data:match("(.-)```\n(.-)\n```(.*)")
	ins = meShift~=meCaps
	ins = ((ins and "H")or"h")
	ins = ({"\t","","","",ins,"\n"})[issKey+1]
	if ins == "" then
		if issKey == 1 then -- caps
			meCaps = not meCaps
		end
		if issKey == 2 then -- shift
			meShift = not meShift
		end
		if issKey == 3 then -- backspace
			txt = txt:sub(1,-2)
		end
	end
	txt = txt .. ins -- if we pressed a char that isnt supposed to be printed, simply concats nothing. makes sure data is a string, idfk
	reconstructed = b4.."<!--HTXT-->"..b4Txt.."```\n"..txt.."\n```"..afterTxt.."<!--HTXT-->"..after
	-- reconstructed is new README.md
	rmIO = io.open("README.md", "w")
	rmIO:write(reconstructed)
	rmIO:close()
	modsIO = io.open("mods.md", "w")
	modsIO:write(b4ModsData)
	for k,a in ipairs(mods) do
		local user,caps,shift = table.unpack(a)
		if not (caps or shift) then goto continue1 end
		if user == issUsr then goto continue1 end
		caps = (caps and "y") or "n"
		shift = (shift and "y") or "n"
		modsIO:write(string.format("\n|@%s|%s|%s|", user, caps, shift))
		::continue1::
	end
	if meCaps or meShift then
		modsIO:write(string.format("\n|@%s|%s|%s|", issUsr, meCaps, meShift))
	end
	closeReq:go()
end

main()