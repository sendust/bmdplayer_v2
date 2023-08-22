-- Script for Mark in and out point (by sendust 2019/6/27) Modified 2019/6/30
-- add fucntion writeinoutfile(a,b)  2019/7/10
-- add function fileLoaded   2019/7/11
-- add funcion read_file_line  2019/7/12
-- Modified 2019/7/19 (pause when press 'i')
-- add function chk_duration 2021/2/5
-- If File is not exist , return null table  2021/4/2
-- i ; mark in
-- o ; mark out
-- ctrl+i ; jump to in
-- ctrl+o ; jump to out
-- d ; check duration   (added 2021/2/5)


sDuration = ""
filename = ""
fileduration = 0
tbl_caspar_inout = {}
tbl_mpv_inout = {}
	tbl_mpv_inout["mark_in"] = 0
	tbl_mpv_inout["mark_out"] = 0
position_pb = 0

function PauseIndicator()
	tbl_mpv_inout["flag_pause"] = mp.get_property("pause")
end


function print_obj_list(obj)
	local key, value
	for key, value in pairs(obj) do
		print(key, value)
	end
end

function read_file_line(file)
	local hfile = io.open(file, "r")
	local tbl = {}
    local tbl_null = {}                 -- added 2021/4/23 (Ther is no file)
	local line1, line2

	if hfile~=nil then	-- there is file
		io.input(hfile)
		while(true)
		do
			line1 = io.read()
			if (line1) then
				line2 = io.read()
				tbl[line1] = line2
			else
				break
			end
		end
		io.close(hfile)
		return tbl
	else
		return tbl_null	-- There is no file
	end
end



function writeinoutfile(obj)			-- Write to file (object)
	local name_file = os.getenv("temp") .. "\\mpvinout.txt"
	local file = io.open(name_file , "w")
	local key, value
	io.output(file)
	for key, value in pairs(obj) do
		io.write(key .. "\n")
		io.write(value .. "\n")
	end
	io.close(file)
end

function fileLoaded()
	local name_file = os.getenv("temp") .. "\\caspar_inout.txt"
	
	tbl_mpv_inout["duration"] =  mp.get_property("duration")
	tbl_mpv_inout["mark_out"] =  mp.get_property("duration")
	tbl_mpv_inout["path"] =  mp.get_property("path")
	duration = tbl_mpv_inout["mark_out"]  - tbl_mpv_inout["mark_in"] 
	if (duration > 0) then
		sDuration = " / Duration " .. tostring(parseTime(duration))
	end
	
	tbl_caspar_inout = read_file_line(name_file)
	
	print_obj_list(tbl_caspar_inout)
	
	if (tbl_caspar_inout["load_me"] == "true") then				-- caspar info load flag is true
		tbl_mpv_inout["mark_in"]  = tbl_caspar_inout["mark_in"]						
		tbl_mpv_inout["mark_out"]  = tbl_caspar_inout["mark_out"]
		tbl_mpv_inout["position_pb"]  = tbl_caspar_inout["position_pb"]
		
		duration = tbl_mpv_inout["mark_out"]  - tbl_mpv_inout["mark_in"] 			-- calculate duration from caspar in out information
		if (duration > 0) then
			sDuration = " / Duration " .. tostring(parseTime(duration))
		end
		
		mp.command("seek " .. tbl_mpv_inout["position_pb"]  .. " absolute+exact")		-- seek to caspar pb position
		if (tbl_caspar_inout["paused_foreground"] == "0") then
			mp.set_property_bool("pause", false)									-- begin playback if caspar is pb state
		end
		mp.osd_message("SDI Playback information loaded", 3)
	end
	writeinoutfile(tbl_mpv_inout)
end


function parseTime(pos)
  local hours = math.floor(pos/3600)
  local minutes = math.floor((pos % 3600)/60)
  local seconds = math.floor((pos % 60))
  local milliseconds = math.floor(pos % 1 * 1000)
  return string.format("%02d:%02d:%02d.%03d",hours,minutes,seconds,milliseconds)
end

function mark_in()
	mp.set_property_bool("pause", true)
	tbl_mpv_inout["mark_in"] = mp.get_property_number("time-pos")
	duration = tbl_mpv_inout["mark_out"] - tbl_mpv_inout["mark_in"]
	if (duration > 0) then
		sDuration = " / Duration " .. tostring(parseTime(duration))
	else
		sDuration = ""
	end
	writeinoutfile(tbl_mpv_inout)
	mp.osd_message("Mark In " .. parseTime(tbl_mpv_inout["mark_in"]) .. sDuration, 5)

end

function goto_in()
	mp.set_property_bool("pause", true)
	mp.command("seek " .. tbl_mpv_inout["mark_in"] .. " absolute+exact")
	mp.osd_message("Goto In " .. parseTime(tbl_mpv_inout["mark_in"]) .. sDuration, 5)
end


function mark_out()
	tbl_mpv_inout["mark_out"] = mp.get_property_number("time-pos")
	duration = tbl_mpv_inout["mark_out"] - tbl_mpv_inout["mark_in"]
	if (duration > 0) then
		sDuration = " / Duration " .. tostring(parseTime(duration))
	else
		sDuration = ""
	end
	writeinoutfile(tbl_mpv_inout)
	mp.osd_message("Mark out " .. parseTime(tbl_mpv_inout["mark_out"]) .. sDuration, 5)

end

function goto_out()
	mp.set_property_bool("pause", true)
	mp.command("seek " .. tbl_mpv_inout["mark_out"] .. " absolute+exact")
	if (tbl_mpv_inout["mark_out"] == tbl_mpv_inout["duration"] ) then			 -- mpv cannot jump to last frame finish time
		mp.command("frame-step")
	end
	mp.osd_message("Goto Out " .. parseTime(tbl_mpv_inout["mark_out"]) .. sDuration, 5)

end


function chk_duration()
	time_current = mp.get_property_number("time-pos")
	duration = time_current - tbl_mpv_inout["mark_in"]
	if (duration > 0) then
		sDuration = " / Dur. Current " .. tostring(parseTime(duration))
	else
		sDuration = " / Currnet Position << IN"
	end
	mp.osd_message("Mark In " .. parseTime(tbl_mpv_inout["mark_in"]) .. sDuration, 10)

end


function get_playhead()
	tbl_mpv_inout["position_pb"] = mp.get_property_number("time-pos")
	writeinoutfile(tbl_mpv_inout)
	mp.osd_message("Send playback position " .. parseTime(tbl_mpv_inout["position_pb"]), 2)

end


mp.add_key_binding("i", "mark_in", mark_in)
mp.add_key_binding("o", "mark_out", mark_out)
mp.add_key_binding("d", "chk_duration", chk_duration)

mp.add_key_binding("ctrl+i", "goto_in", goto_in)
mp.add_key_binding("ctrl+o", "goto_out", goto_out)
mp.add_key_binding("g", "get_playhead", get_playhead)

mp.register_event("file-loaded", fileLoaded)

mp.observe_property('pause', 'bool', PauseIndicator)
