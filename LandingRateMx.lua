---@diagnostic disable: undefined-global, lowercase-global, deprecated, assign-type-mismatch, param-type-mismatch

-- These define the positioning of the window from 0% (0.0) to 100% (1.0)
-- lrl_XPCT: 0.0 = left edge, 1.0 = right edge
-- lrl_YPCT: 0.0 = bottom edge, 1.0 = top edge
lrl_XPCT = 0.5
lrl_YPCT = 0.8
-- This defines the font size. Available sizes = 10, 12 or 18.
lrl_FONTSIZE = 18
-- The number of seconds to display the on-screen popup, or -1 for no popup.
lrl_SECONDS_TO_DISPLAY = 20
-- Set lrl_SHOW_TIMER to "true" (show) or "false" (don't show) the float timer
lrl_SHOW_TIMER = true
-- Set lrl_POSTRATE to "true" (write the rate to a file) or "false" (don't write)
lrl_POSTRATE = true

lrl_READAFTERLANDING = 60

----------- THAR BE DRAGONS BEYOND THIS POINT -----------
require("graphics")

dataref("lrl_vertfpm", "sim/flightmodel/position/vh_ind_fpm", "readonly")
dataref("lrl_gforce", "sim/flightmodel2/misc/gforce_normal", "readonly")
dataref("lrl_boolOnGroundAny", "sim/flightmodel/failures/onground_any", "readonly")
dataref("lrl_boolOnGroundAll", "sim/flightmodel/failures/onground_all", "readonly")
dataref("lrl_agl", "sim/flightmodel/position/y_agl", "readonly")
dataref("lrl_Q", "sim/flightmodel/position/Q", "readonly")
dataref("lrl_Qrad", "sim/flightmodel/position/Qrad", "readonly")
dataref("lrl_localtime", "sim/time/local_time_sec", "readonly")
dataref("lrl_boolSimPaused", "sim/time/paused", "readonly")
dataref("lrl_boolInReplay", "sim/time/is_in_replay", "readonly")
dataref("lrl_boolBeaconOn", "sim/cockpit2/switches/beacon_on", "readonly")

-- Thanks to EdmundStoner for working on accurate G's and a force indicator
dataref("lrl_YN", "sim/flightmodel/forces/fnrml_gear", "readonly") --the landing gear Y forces in Newtons 
dataref("lrl_ZN", "sim/flightmodel/forces/faxil_gear", "readonly") --the landing gear Z forces in Newtons
dataref("lrl_Weight", "sim/flightmodel/weight/m_total", "readonly") --the Total weight of the craft

-- Thanks to [erhardma] for adding VR support!
dataref("lrl_vr_enabled", "sim/graphics/VR/enabled", "readonly")

if not SUPPORTS_FLOATING_WINDOWS then
	-- to make sure the script doesn't stop old FlyWithLua versions
	logMsg("Floating windows requires an updated FlyWithLua NG")
	logMsg("See https://forums.x-plane.org/index.php?/files/file/82888-flywithlua-ng-next-generation-plus-edition-for-x-plane-12-win-lin-mac/")
	return
end
-- erhardma

lrl_ARMED = 0
lrl_LANDED = 1
lrl_STEERINGDN = 2
lrl_STANDBY = 3

function write2log(fn,s)
	io.output(io.open(fn, "a"))
	io.write(s)
	io.close()
end

-- Table Classes 
-- Variables = values_axis_tABLEnAME,ts_axis_tABLEnAME
-- functions = init_tABLEnAME(), calcAvg_tABLEnAME(), calc_Max_tABLEnAME(), 
--             calcDeviation_tABLEnAME(),calcTime_tABLEnAME(), pushValue_tABLEnAME(value, ts)
function new_table(tn, samples)
    -- Add a class of a table
	-- make samples an optional argument
	samples = samples or 10

	-- make sure that tn is a string
	tn = tostring(tn)

	-- create the code
	code = "values_axis_" .. tn .. " = {}\n"
	code = code .. "ts_axis_" .. tn .. " = {}\n"
	code = code .. "function init_" .. tn .. "()\n"
	code = code .. "    values_axis_" .. tn .. " = {}\n"
	code = code .. "    ts_axis_" .. tn .. " = {}\n"
	code = code .. "end\n"
	code = code .. "init_" .. tn .. "()\n"
	code = code .. "function calcAvg_" .. tn .. "()\n"
	code = code .. "    local avg = 0\n"
	code = code .. "    if #values_axis_" .. tn .. " > 0 then\n"
	code = code .. "        for i = " .. samples .. ", 1, -1 do\n"
	code = code .. "            avg = avg + (values_axis_" .. tn .. "[i] or 0)\n"
	code = code .. "        end\n"
	code = code .. "        avg = avg / #values_axis_" .. tn .. "\n"
	code = code .. "    end\n"
	code = code .. "    return avg\n"
	code = code .. "end\n"
	-- EdmundS
	code = code .. "function calcMax_" .. tn .. "()\n"
	code = code .. "    local max = 0.0001\n"
	code = code .. "    if #values_axis_" .. tn .. " > 0 then\n"
	code = code .. "        for i = " .. samples .. ", 1, -1 do\n"
	code = code .. "            if values_axis_" .. tn .. "[i] then\n"
	code = code .. "                max = math.max(max,values_axis_" .. tn .. "[i])\n"
	code = code .. "             end\n"
	code = code .. "        end\n"
	code = code .. "    end\n"
	code = code .. "    return max\n"
	code = code .. "end\n"
	code = code .. "function csvStringOf_" .. tn .. "()\n"
	code = code .. "    local str = ''\n"
	code = code .. "    if #values_axis_" .. tn .. " > 0 then\n"
	code = code .. "        for i = " .. samples .. ", 1, -1 do\n"
	code = code .. "            str = string.format('{%.2f,%2f}', values_axis_" .. tn .. "[i], ts_axis_" .. tn .. "[i]) .. str\n"
	code = code .. "            if i ~= 1 then\n"
	code = code .. "            	str = ',' .. str\n"	
	code = code .. "            end\n"
	code = code .. "        end\n"
	code = code .. "    end\n"
	code = code .. "    return str\n"
	code = code .. "end\n"
	--
	code = code .. "function calcDeviation_" .. tn .. "()\n"
	code = code .. "    local prev\n"
	code = code .. "    local d = 0\n"
	code = code .. "    if #values_axis_" .. tn .. " > 0 then\n"
	code = code .. "        for i = " .. samples .. ", 1, -1 do\n"
	code = code .. "            if values_axis_" .. tn .. "[i] then\n"
	code = code .. "                if prev then\n"
	code = code .. "                    local diff = values_axis_" .. tn .. "[i] - prev\n"
	code = code .. "                    d = d + diff\n"
	code = code .. "                end\n"
	code = code .. "                prev = values_axis_" .. tn .. "[i]\n"
	code = code .. "            end\n"
	code = code .. "        end\n"
	code = code .. "        d = d / (#values_axis_" .. tn .. " - 1)\n"
	code = code .. "    end\n"
	code = code .. "    return d\n"
	code = code .. "end\n"
	code = code .. "function calcTime_" .. tn .. "()\n"
	code = code .. "    local d = 0\n"
	code = code .. "    if #ts_axis_" .. tn .. " > 1 then\n"
	code = code .. "        d = ts_axis_" .. tn .. "[1] - ts_axis_" .. tn .. "[#ts_axis_" .. tn .. "]\n"
	code = code .. "    end\n"
	code = code .. "    return d\n"
	code = code .. "end\n"
	code = code .. "function pushValue_" .. tn .. "(value, ts)\n"
	code = code .. "    ts = ts or os.clock()\n"
	code = code .. "    for i = " .. samples .. ", 2, -1 do\n"
	code = code .. "        values_axis_" .. tn .. "[i] = values_axis_" .. tn .. "[i-1]\n"
	code = code .. "        ts_axis_" .. tn .. "[i] = ts_axis_" .. tn .. "[i-1]\n"
	code = code .. "    end\n"
	code = code .. "    values_axis_" .. tn .. "[1] = value\n"
	code = code .. "    ts_axis_" .. tn .. "[1] = ts\n"
	code = code .. "end\n"

	--write2log("ClassObj.lua",code)
	-- execute the code
	assert(loadstring(code))()
end

new_table("lrl_agl", 20)
new_table("lrl_landingG", 10)
new_table("lrl_gearForce", 60)

lrl_logAnyWheel = lrl_boolOnGroundAny == 1 and true or false
lrl_logAllWheels = lrl_boolOnGroundAll == 1 and true or false

lrl_popupText = { "Landing Rate Max G for Lua" .. (lrl_vr_enabled == 1 and " + VR v16" or ""), "Mod of Dan Berry's code", 
	"ES VERSION 0.6", "EXPERIMENTAL" }
lrl_showUntil = os.clock() + 5
lrl_logDisplayOn = true
lrl_popupState = lrl_STEERINGDN
lrl_landingRate = 1.0
lrl_landingG = 1.0
lrl_gearLbF = lrl_Weight
lrl_floatTimer = 0
lrl_floatFinal = 0
lrl_noseRate = nil

function lrl_postLandingRateMx()
	-- CSV format:
	-- Timestamp, PLANE_ICAO, Landing Rate, Landing G-Force, Landing Nose Rotate Rate, Floating Time, Flare Rating,Force on Gear
	local d = os.date("%Y-%m-%d %H:%M:%S")
	local s
	-- VR folks like the popup text being logged
	-- Non-VR folks are used to having spreadsheet values then can import via CSV
	if lrl_vr_enabled == 0 then
		s = string.format('%.2f,%.2f,%.2f,%.2f,"%s",%s', lrl_landingRate, lrl_landingG, lrl_noseRate, lrl_floatFinal,
			lrl_popupText[2], lrl_popupText[5])
	else
		s = string.format('"%s","%s","%s","%s","%s"', lrl_popupText[1], lrl_popupText[2], lrl_popupText[3], lrl_popupText[4],
			lrl_popupText[5])
	end
	logMsg(string.format("%s Landing Rate: %s", d, s))

	io.output(io.open("LandingRate.log", "a"))
	io.write(d, ",", PLANE_ICAO, ",", s, "\n")
	io.close()
end

function lrl_populatePopupStats()
	lrl_popupText[1] = string.format("Vertical Speed %.2f FPM  %.2fG  Gear Force %.2f", 
	        lrl_landingRate, lrl_landingG, lrl_gearLbF)

	if lrl_qAdj == nil then
		-- Grade the flare
            --	HOW FLAREdmundS ARE GRADED
            --				<-2    <-1      0     +1>    +2>
            --			------|------|------|------|------|------
            --	Qrad:	 Aggressive, |  (relaxed)  | Aggressive,
            --	Q:       Poor&| Good&|  Very Good  | Good&| Poor&
            --	Q:       Late | Late |             | Early| Early
		local flare = "Very good"
		lrl_qAdj = lrl_Q
		local Qrad = math.abs(lrl_Qrad)
		local qRate = math.abs(lrl_qAdj)
		if qRate > 1 then
			local earlate = "early"
			if qRate > 2 then
				flare = "Poor and "
			else
				flare = "Good, but "
			end
			if lrl_qAdj < 0 then
				earlate = "late"
			end
			flare = flare .. earlate
			if Qrad > 1 then
				flare = "Aggressive, " .. flare
			end
		end
		lrl_popupText[2] = flare .. " flare"
		lrl_popupText[5] = string.format("%.2f,%.2f,%.2f", lrl_qAdj, Qrad, lrl_gforce) -- EdmundS
	end
end

function lrl_populatePopupStats2()
	if lrl_noseRate == nil then 
		lrl_noseRate = lrl_Q 
	end
	lrl_popupText[3] = string.format("Nose: %.2f deg/sec", lrl_noseRate)
	if lrl_SHOW_TIMER then
		lrl_popupText[3] = lrl_popupText[3] .. string.format(" | Float: %.2f secs", lrl_floatFinal)
	end
	if lrl_boolInReplay == 0 and lrl_boolSimPaused == 0 and lrl_POSTRATE then 
		lrl_postLandingRateMx() 
	end
end

function lrl_updateLandingResult()
	local osts = os.clock()
	-- Calculate the instantaneous average gVS (ground vertical speed)
	-- from the avg ground level over average time
	local aglAvg = calcAvg_lrl_agl()
	local aglTimeslice = calcTime_lrl_agl()
	local aglMidpoint = lrl_agl - aglAvg
	local gVS = (aglMidpoint / (aglTimeslice / 2)) * 196.85
	-- Show debugging information
	if lrl_DEBUG then
		if gVS > 0 then
			graphics.set_color(0.0, 1.0, 0.0, 1.0)
		else
			graphics.set_color(1.0, 0.0, 0.0, 1.0)
		end
		draw_string_Helvetica_18(100, 140,
			string.format("lrl_landingRate: %s | lrl_noseRate: %s | lrl_floatFinal: %s", 
			    tostring(lrl_landingRate), tostring(lrl_noseRate), tostring(lrl_floatFinal) ))
		-- EdmundS			    
		draw_string_Helvetica_18(100, 120,
			string.format("Total Weight %.1f| Force on Gear: %.1f lbf | G's Gear: %.2f | Max Gear force: %.1f", 
			    lrl_Weight, lrl_YN / 4.4482216153, ((lrl_YN + lrl_ZN) / 10) (lrl_Weight), (calcMax_lrl_gearForce() or .01) ))
		--			    
    		draw_string_Helvetica_18(100, 100,
			string.format("agl: %.2f  VSI: %d | DisplayOn: %s   lrl_popupState: %d", lrl_agl, lrl_vertfpm,
				tostring(lrl_logDisplayOn), lrl_popupState))
		if #values_axis_lrl_agl > 0 then
			draw_string_Helvetica_18(100, 80,
				string.format("aglAvg: %.2f (%+.3fm in %.2fs = %+.2f FPM)", aglAvg, aglMidpoint, aglTimeslice, gVS))
		else
			draw_string_Helvetica_18(100, 80, "Recorder drained")
		end
		draw_string_Helvetica_18(100, 60, string.format("Q: %.2f | Qrad: %.2f", lrl_Q, lrl_Qrad))
		if lrl_floatTimer ~= 0 then
			draw_string_Helvetica_18(100, 40, string.format("CAT IIIB timer: %.2f secs", osts - lrl_floatTimer))
		end
	end

	-- ABOVE 15M
	-- If we're in the STANDBY state and we go >15m agl (but not in replay), then
	--   clear all our agl+lrl_gforce stats (and others), enable the display (but keep it off)
	if lrl_popupState ~= lrl_ARMED and lrl_agl > 15 and lrl_boolInReplay == 0 then --- Reset
		if #values_axis_lrl_agl ~= 0 then -- Reset recorders
			init_lrl_agl()
			init_lrl_landingG()
			init_lrl_gearForce()
		end
		lrl_landingRate = nil
		lrl_landingG = nil
		lrl_noseRate = nil
		lrl_gearLbF = nil
		lrl_qAdj = nil
		lrl_floatTimer = 0
		lrl_floatFinal = 0
		lrl_logDisplayOn = false
		lrl_popupState = lrl_ARMED
		lrl_popupText = {}
		lrl_ReadMore = 0
	end

	-- NOT PAUSED
	-- If the sim is running in the ARMED state, collect our agl and g-force values
	--if lrl_popupState == lrl_ARMED and lrl_boolSimPaused == 0 then
	if lrl_boolSimPaused == 0 then -- and (lrl_agl < 5 or lrl_popupState == lrl_LANDED) then
		pushValue_lrl_agl(lrl_agl, lrl_localtime)
		pushValue_lrl_landingG(lrl_gforce, lrl_localtime)
		pushValue_lrl_gearForce((lrl_ZN + lrl_YN) / 10, lrl_localtime)
		-- write2log("mxdev.log", string.format("NotPaused, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f\n", 
		--	lrl_localtime, lrl_agl, lrl_gforce,lrl_ZN, lrl_YN, lrl_Weight, (( lrl_ZN + lrl_YN) / 10)/lrl_Weight))
	end

	-- BELOW 15M
	-- If we're below CAT-IIIB height, mark the time and reset float counter to 0
	if lrl_popupState == lrl_ARMED and lrl_agl <= 15 and lrl_floatTimer == 0 then
		lrl_floatTimer = osts
		lrl_floatFinal = 0
	end

	-- 	LANDED ANY WHEEL DOWN AND STILL FLYING
	-- If we're in an ARMED state, and we're transitioning from no wheels down to having wheels down,
	-- then grab the ground speed from gVS, find the max lrl_gforce ang lrl_gearLbF
	--   and populate our status and change to the LANDED state
	--   so we can calculate the nose rate
	if lrl_popupState == lrl_ARMED and (not lrl_logAnyWheel and lrl_boolOnGroundAny == 1) then
		-- wing (center) wheels touched down
		if lrl_landingRate == nil then
			lrl_landingRate = gVS
			lrl_gearLbF = calcMax_lrl_gearForce()   -- EdmundS
			lrl_landingG = lrl_gearLbF / lrl_Weight      -- EdmundS
		end
		lrl_populatePopupStats()
		lrl_popupState = lrl_LANDED
		lrl_showUntil = osts + lrl_SECONDS_TO_DISPLAY
		lrl_logDisplayOn = true
	end

	-- EdmundS
	-- After landing readings
	if lrl_popupState == lrl_LANDED and lrl_ReadMore < lrl_READAFTERLANDING then 
		-- pushValue_lrl_gearForce(((lrl_ZN + lrl_YN) / 10), lrl_localtime)
		lrl_landingG = calcMax_lrl_gearForce() / lrl_Weight
		lrl_ReadMore = lrl_ReadMore + 1
		-- write2log("gearforcedata.txt", string.format("%.3f - %s\n",calcMax_lrl_gearForce(), csvStringOf_lrl_gearForce()))
		lrl_populatePopupStats()
		-- lrl_populatePopupStats2()
	end

	--LANDED BUT NOT ALL WHEELS DOWN
	-- If we have wing wheels down but not the nose wheel, give the pilot some feedback.
	-- Otherwise, give the final nose rate and move onto the final STEERINGDN state.
	if lrl_popupState == lrl_LANDED and lrl_logAnyWheel then
		if not lrl_logAllWheels then
			-- Wing wheels down, inform the pilot
			lrl_popupText[3] = "Slowly lower the steering"
		else  -- EdmundS
			lrl_popupState = lrl_STEERINGDN
		    lrl_populatePopupStats()
			lrl_populatePopupStats2()
		end
		lrl_showUntil = osts + lrl_SECONDS_TO_DISPLAY
		lrl_logDisplayOn = true
	end

	-- FULLY LANDED
	-- If we're in a LANDED state (or later) and we have a float time marker,
	-- and the final rate isn't determined yet, then find it.
	if lrl_popupState >= lrl_LANDED and lrl_floatTimer > 0 and lrl_floatFinal == 0 then
		lrl_floatFinal = osts - lrl_floatTimer
	end

	-- Grab the latest wheel states
	lrl_logAnyWheel = lrl_boolOnGroundAny == 1 and true or false
	lrl_logAllWheels = lrl_boolOnGroundAll == 1 and true or false
end

function lrl_evalRating()
	local r, g, b, a = 1.0, 1.0, 1.0, 1.0
	lrl_vr_hexColor = 0xFFFFFFFF -- erhardma

	if (lrl_landingRate ~= nil) then
		if (lrl_landingRate >= -125) and (lrl_landingRate <= 0) then
			r, g, b, a = 1.0, 1.0, 0.0, 1.0
			lrl_vr_hexColor = 0xFF00FFFF -- erhardma
			lrl_popupText[4] = "BUTTER!"
		elseif (lrl_landingRate >= -250) and (lrl_landingRate < -125) then
			r, g, b, a = 0.25, 1.0, 0.25, 1.0
			lrl_vr_hexColor = 0xFF40FF40 -- erhardma
			lrl_popupText[4] = "GREAT LANDING!"
		elseif (lrl_landingRate >= -350) and (lrl_landingRate < -250) then
			r, g, b, a = 0.0, 1.0, 0.0, 1.0
			lrl_vr_hexColor = 0xFF00FF00 -- erhardma
			lrl_popupText[4] = "ACCEPTABLE"
		elseif (lrl_landingRate >= -600) and (lrl_landingRate < -350) then
			r, g, b, a = 1.0, 0.5, 0.0, 1.0
			lrl_vr_hexColor = 0xFF0080FF -- erhardma
			lrl_popupText[4] = "HARD LANDING!"
		elseif (lrl_landingRate < -600) then
			r, g, b, a = 1.0, 0.0, 0.0, 1.0
			lrl_vr_hexColor = 0xFF0000FF -- erhardma
			lrl_popupText[4] = "* WASTED! *"
		end
	end
	return r, g, b, a
end

-- erhardma VR functions
-- Create a VR window object and function to get called every frame when necessary
lrl_vr_wndObj = nil
lrl_vr_showWindow = 0
lrl_vr_enabledDelay = 0
lrl_vr_disabledDelay = 0

function LandingRateMxVR_window(lrl_vr_wndObj, x, y)
	local win_width = imgui.GetWindowWidth()
	local win_height = imgui.GetWindowHeight()
	if lrl_vr_showWindow == 1 then
		if lrl_popupText[1] ~= nil and lrl_popupText[1] ~= "" then imgui.TextUnformatted(lrl_popupText[1]) end
		if lrl_popupText[2] ~= nil and lrl_popupText[2] ~= "" then imgui.TextUnformatted(lrl_popupText[2]) end
		if lrl_popupText[3] ~= nil and lrl_popupText[3] ~= "" then imgui.TextUnformatted(lrl_popupText[3]) end
		if lrl_popupText[4] ~= nil and lrl_popupText[4] ~= "" then
			imgui.Separator()
			if lrl_vr_hexColor ~= nil then imgui.PushStyleColor(imgui.constant.Col.Text, lrl_vr_hexColor) end
			local text = lrl_popupText[4]
			local text_width, text_height = imgui.CalcTextSize(text)
			imgui.SetCursorPos((win_width - text_width) / 2, imgui.GetCursorPosY())
			imgui.TextUnformatted(text)
			imgui.PopStyleColor() --restore original layout
		end
	end
	return
end
-- erhardma

function lrl_loopCallback()
	lrl_updateLandingResult()
	XPLMSetGraphicsState(0, 0, 0, 1, 1, 0, 0)

	-- NOTE: You can't trust the values in replay b/c they don't update frequently enough
	if (os.clock() < lrl_showUntil and lrl_logDisplayOn) then
		if (lrl_boolInReplay == 0) then -- only show lrl_popupTexts live, not in replay
			if lrl_vr_enabled ~= 0 then lrl_vr_showWindow = 1 end -- erhardma
			local boxWidth = lrl_FONTSIZE * 35      -- EdmundS
			local boxHeight = lrl_FONTSIZE * 6.3
			local yspacing = lrl_FONTSIZE * 1.23
			local yoffset = yspacing * 4
			local ypos = (SCREEN_HIGHT - boxHeight) * lrl_YPCT
			local xpos = (SCREEN_WIDTH - boxWidth) * lrl_XPCT

			graphics.set_color(0.0, 0.0, 0.0, 0.3)
			graphics.draw_rectangle(xpos, ypos, xpos + boxWidth, ypos + boxHeight)

			graphics.set_color(1.0, 1.0, 1.0, 1.0)
			for x = 0, 2 do
				if lrl_popupText[x + 1] then
					local xoffset = (boxWidth - measure_string(lrl_popupText[x + 1], "Helvetica_" .. lrl_FONTSIZE)) * 0.5
					local code = string.format("draw_string_Helvetica_%d(%f, %f, '%s');\n", lrl_FONTSIZE, xpos + xoffset,
						ypos + yoffset - (x * yspacing), lrl_popupText[x + 1])
					assert(loadstring(code))()
				end
			end

			graphics.set_color(lrl_evalRating())
			if os.clock() % 0.5 >= 0.25 then --blink the bottom row of text
				if lrl_popupText[4] then
					local xoffset = (boxWidth - measure_string(lrl_popupText[4], "Helvetica_" .. lrl_FONTSIZE)) * 0.5
					local code = string.format("draw_string_Helvetica_%d(%f, %f, '%s');\n", lrl_FONTSIZE, xpos + xoffset, ypos + 10,
						lrl_popupText[4])
					code = code ..
						string.format("draw_string_Helvetica_%d(%f, %f, '%s');\n", lrl_FONTSIZE, xpos + xoffset + 1, ypos + 10,
							lrl_popupText[4])
					assert(loadstring(code))()
				end
			end
		end
	end

	-- Turn the display off and disable it until rearmed @ agl > 15 meters
	if lrl_popupState ~= lrl_ARMED and os.clock() > lrl_showUntil then
		lrl_logDisplayOn = false
		if lrl_landingRate == 1 then lrl_landingRate = nil end
		if lrl_popupState == lrl_STEERINGDN then lrl_popupState = lrl_STANDBY end
		lrl_vr_showWindow = 0 -- erhardma
	end

	-- Show the last lrl_popupTexts while we have the sim paused
	if (lrl_boolSimPaused == 1 and lrl_boolBeaconOn == 0) then
		-- The clock stops when we pause, so this shows it until .1 second after we _unpause_.
		lrl_showUntil = os.clock() + 0.1
		lrl_logDisplayOn = true

		if (lrl_landingRate == nil) then
			lrl_popupText = { "", "No previous statistics have", "been recorded yet", "", "" }
		elseif (lrl_landingRate <= 0) then
			lrl_populatePopupStats()
			lrl_populatePopupStats2()
			lrl_evalRating()
		end
	end
end

function lrl_checkForVR()
	-- After we go into VR we need to wait a bit of time before creating the lrl_vr_wndObj.
	-- If we go out of VR then we wait a bit of time and destroy the lrl_vr_wndObj.
	-- This will prevent it from being displayed in 2d like it did before.
	-- This is my first pass so might nat be a clean as it should be.
	if lrl_vr_enabled == 1 and lrl_vr_enabledDelay == 1 then
		if lrl_vr_wndObj then
			float_wnd_destroy(lrl_vr_wndObj)
		end

		lrl_vr_wndObj = float_wnd_create(lrl_FONTSIZE * 17, lrl_FONTSIZE * 5.3, 0, true)
		float_wnd_set_title(lrl_vr_wndObj, "LandingRateMxVR")
		--                                                0x Alpha Red Green Blue
		imgui.PushStyleColor(imgui.constant.Col.WindowBg, 0xCC101112) -- Black like Background
		float_wnd_set_imgui_builder(lrl_vr_wndObj, "LandingRateVR_window")
		lrl_vr_disabledDelay = 0
	end
	if lrl_vr_enabled == 1 and lrl_vr_enabledDelay < 2 then
		lrl_vr_enabledDelay = lrl_vr_enabledDelay + 1
	end

	if lrl_vr_enabled == 0 and lrl_vr_disabledDelay == 1 then
		if lrl_vr_wndObj then
			float_wnd_destroy(lrl_vr_wndObj)
		end
		lrl_vr_enabledDelay = 0
	end
	if lrl_vr_enabled == 0 and lrl_vr_disabledDelay < 2 then
		lrl_vr_disabledDelay = lrl_vr_disabledDelay + 1
	end
end

do_every_draw('lrl_loopCallback()')

do_often("lrl_checkForVR()")

add_macro("Landing RateMx: Show Debug Info", "lrl_DEBUG = true", "lrl_DEBUG = false", "activate")
