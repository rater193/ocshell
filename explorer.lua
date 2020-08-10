--[[
	Creator: rater193
	Creation date: 8-7-2020-0222
	Description:
		This is a simple file explorer for managing your projects!
		(you can also link this to repositories)
]]

local args = {...}
if(#args < 1) then
	print("Not enough arguments...")
	print("explorer </path/to/project>")
else
	--args
	local projectpath = args[1]

	--Importing libraries
	local component = require("component")
	local fs = require("filesystem")
	local gpu = component.gpu
	local term = require("term")
	local shell = require("shell")
	local keyboard = require("keyboard")
	local event = require("event")
	local debug = require("serialization")
	local text = require("text")

	-- Engine variables
	local scan_path = "/" .. projectpath
	local scan_data = {
		["files"] = {},
		["folders"] = {}
	}
	if(fs.isDirectory(scan_path)) then
		scan_path = scan_path .."/"
	end
	
	-- Getting screen resolution
	local w, h = gpu.getResolution()
	local selected_file = 0
	
	-- Config
	local config = {
		["useRelitiveDirectory"] = false,
		["colors"] = {
			["titlebar"] = {
				["background"] = 0x222222,
				["text"] = 0xffffff
			},
			["background-color"] = 0x111111,
			["accent"] = 0x444444
		}
	}

	--Scanning for files in the targeted path
	function scan_files()
		--Here we are resetting the scan data
		scan_data.files = {}
		scan_data.folders = {}

		--Here wea re scanning through the files and adding them to their respective folders
		local _scannedfiles = fs.canonical(scan_path)
		for file in fs.list(scan_path) do
			local concatfile = fs.concat(file)
			if(fs.isDirectory(scan_path .. concatfile)) then
				--Adding to the folder list
				table.insert(scan_data.folders,file)
			else
				--Adding to the file list
				table.insert(scan_data.files,file)
			end
		end
	end

	-- Function logic
	function refresh_screen()
		term.setCursor(0,0)
		gpu.setBackground(config.colors["background-color"])
		-- Clearing screen to the background color above
		term.clear()
		gpu.setBackground(config.colors.titlebar.background)
		gpu.setForeground(config.colors.titlebar.text)
		gpu.fill(0,1,w+1,3, " ")
		term.setCursor((w/2)-13,2)
		term.write("Ratnet File Explorer 0.1.0!")

		-- Here i am setting the lines
		gpu.setBackground(config.colors.accent)
		gpu.fill(0,4,w+1,1, " ")
		term.setCursor(3,4)
		term.write("Scanning \"" .. tostring(fs.canonical(scan_path)) .. "\"")
		gpu.fill(0,h-4,w+1,1, " ")

		-- Displaying shortcuts
		gpu.setBackground(config.colors.titlebar.background)
		gpu.setForeground(config.colors.titlebar.text)
		gpu.fill(0,h-3,w+1,h, " ")
		term.setCursor(2, h-2)
		term.write("Shortcuts")
		term.setCursor(2, h-1)
		term.write("<W/S> Nav Files | <A/D> Next/Prev. Folder | <E> Edit | <Enter> Open | <CTRL>+<D> Exit")
	end

	--This handles "highlighting" the file selected
	function handle_files_place(cursorX, cursorY)
		if(draw_file_place==selected_file) then
			--Selected
			gpu.setBackground(0x888888)
		else
			--Not selected
			gpu.setBackground(config.colors["background-color"])
		end
		gpu.fill(cursorX, cursorY, cursorX+40, 1, " ")
		draw_file_place = draw_file_place+1
	end

	-- Updating the files list
	function draw_files()

		gpu.setBackground(config.colors["background-color"])
		term.setCursor(3,6)
		
		draw_file_place = 0
		--Printing files
		gpu.setForeground(0x66ff66)
		for _i, dirname in pairs(scan_data.files) do
			local _cx, _cy = term.getCursor()
			handle_files_place(_cx, _cy)
			term.write(tostring(draw_file_place) .. ": " .. dirname)
			term.setCursor(_cx, _cy+1)
		end

		--Printing folders
		gpu.setForeground(0x6666ff)
		for _i, dirname in pairs(scan_data.folders) do
			local _cx, _cy = term.getCursor()
			handle_files_place(_cx, _cy)
			term.write(tostring(draw_file_place) .. ": " .. fs.canonical(dirname))
			term.setCursor(_cx, _cy+1)
		end
		gpu.setBackground(config.colors["background-color"])
	end

	--Drawing the screen
	function full_refresh()
		-- Setting up the screen
		scan_files()
		refresh_screen()
		-- Displaying the files
		draw_files()
	end

	full_refresh()

	--Looping logic
	local running = true
	while running==true do
		local _ = event.pull(0.25)

		if(keyboard.isControlDown()) then
			--Exiting
			if(keyboard.isKeyDown(keyboard.keys.d)) then
				running = false
			end
		else
			--Navigating the menus
			if(keyboard.isKeyDown(keyboard.keys.w)) then
				if(selected_file>0) then
					selected_file = selected_file-1
					draw_files()
				end
			end
			if(keyboard.isKeyDown(keyboard.keys.s)) then
				
				if(selected_file < (#scan_data.files) + (#scan_data.folders) - 1) then
					selected_file = selected_file + 1
					draw_files()
				end
			end

			--Opening file
			if(keyboard.isKeyDown(keyboard.keys.enter)) then
				--This selects files
				if(selected_file < #scan_data.files) then
					term.clear()
					term.setCursor(1,1)
					local filepath = fs.canonical(scan_path)
					filepath = filepath .. tostring(scan_data.files[selected_file+1])
					shell.execute(filepath)
					full_refresh()
				else
					--This selects folders
					term.clear()
					term.setCursor(1,1)
					local filepath = fs.canonical(scan_path)
					filepath = filepath .."/" .. tostring(scan_data.folders[(selected_file-(#scan_data.files))+1])
					scan_path = filepath
					selected_file = 0
					full_refresh()
				end
			end
			
			--Editing
			if(keyboard.isKeyDown(keyboard.keys.e)) then
				--This selects files
				if(selected_file < #scan_data.files) then
					term.clear()
					term.setCursor(1,1)
					local filepath = fs.canonical(scan_path)
					filepath = filepath .. tostring(scan_data.files[selected_file+1])
					shell.execute("edit \"" .. filepath .. "\"")
					full_refresh()
				end
			end
		end
	end
end
