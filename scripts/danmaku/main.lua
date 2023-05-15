-- local utils = require 'mp.utils'
-- local directory = mp.find_config_file(".")
-- local direc = utils.split_path(directory)
local directory = mp.get_script_directory()
local py_path = directory .. "\\danmaku2ass.py"
local py_path2 = directory .. "\\niconvert.pyw"
local xmlfile = directory .. "\\bilitemp.danmaku.xml"
local assfile = directory .. "\\bilitemp.ass"
local xmlfiletemp = directory .. "\\bilitemp.danmaku.xml.part"
-- local cookie = directory .. "\\bilibili.com_cookies.txt"

function loadsub()
	local biliurl = mp.get_property("path")
	local download = { 'yt-dlp', biliurl, '--skip-download', '--write-subs', '--retries', '3', '--paths', directory, '--output', 'bilitemp.%(ext)s' }
	local convert = { 'python', py_path, '-o', assfile, xmlfile }
	local convert2 = { 'python', py_path2, '-o', assfile, '+f', 'sans-serif', '+s', '64', '+l', '0', '+a', 'async', xmlfile }
	if biliurl:lower():match("bilibili") ~= nil and biliurl:lower():match("http") ~= nil then
		local method1 = mp.command_native_async({
			name = 'subprocess',
			playback_only = false,
			capture_stdout = true,
			args = download
		},function(success, result, error)
			if result.status == 0 then
				mp.command_native_async({
					name = 'subprocess',
					playback_only = false,
					capture_stdout = true,
					args = convert
				},function(success, result, error)
					if result.status == 0 then
					mp.set_property_native("options/sub-file-paths", directory)
					mp.set_property("sub-auto", "all")
					mp.commandv("rescan_external_files", "reselect")
					else mp.command_native_async({
						name = 'subprocess',
						playback_only = false,
						capture_stdout = true,
						args = convert2
					},function(success, result, error)
						if result.status == 0 then
						mp.set_property_native("options/sub-file-paths", directory)
						mp.set_property("sub-auto", "all")
						else end
					end) end
				end)
			else loadsub2() end
		end)
	else end
end

function loadsub2 ()
	local biliurl = mp.get_property("path")
	local download2 = { 'bilidown', biliurl, '--danmakus-settings', 'only', '--dir', directory, '--out', 'bilitemp.ass' }
	mp.command_native_async({
		name = 'subprocess',
		playback_only = false,
		capture_stdout = true,
		args = download2
		},function(success, result, error)
			if result.status == 0 then
				mp.set_property_native("options/sub-file-paths", directory)
				mp.set_property("sub-auto", "all")
				mp.commandv("rescan_external_files", "reselect")
	else end
		end)
end

function unloadsub()
	mp.set_property_native("options/sub-file-paths", "")
	mp.set_property("sub-auto", "fuzzy")
end

function clean()
    if assfile then
		os.remove(xmlfile)
        os.remove(assfile)
		os.remove(xmlfiletemp)
    end
end

mp.register_event("start-file", loadsub)
mp.register_event("end-file", unloadsub)
mp.register_event("shutdown", clean)
-- mp.add_key_binding("D", loadsub2)
