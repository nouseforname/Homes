
-- * plugin homes.lua


-- * provides functions to create, request and list and delete player homes with names and configurable limit

-- * permission "homes.home"

-- * Usage /home [goto|set|list|delete|help] [name]
-- * /home goto => port you to your default home
-- * /home goto myHome => port you to home 'myHome'
-- * /home set => set the actual position as default home
-- * /home set myHome => set the actual position as 'myHome'
-- * /home list => list all your home by name and world
-- * /home delete myHome => delete 'myHome"
-- * /home help => shows this help


-- * Configurable limit of homes for each rank. 0=infinite
-- * Homes.ini:
-- * [Limits]
-- * Default=3
-- * VIP=5
-- * Operator=10
-- * Admin=0


-- * created by nouseforname @ http://nouseforname.de
-- * november 2014


-- ********************************************************************
-- ********************************************************************



-- set plugin folder
homeDir = 'Plugins/Homes'

-- Plugin name and prefix for later usage
PluginName = "Homes"
PluginPrefix = PluginName .. ": "

-- initialize global tables
g_Config = {}
g_Storage = {}


-- init plugin
function Initialize(Plugin)
    
    PLUGIN = Plugin
    
    PLUGIN:SetName(PluginName)
    PLUGIN:SetVersion(2)
    
    -- PluginManager = cRoot:Get():GetPluginManager()
    -- PluginManager:BindCommand("/home", "homes.home", HandleHomeCommand, " - Handle commands like [list|set|delete|help] or teleport!")
    
	-- Use the InfoReg shared library to process the Info.lua file:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()
	RegisterPluginInfoConsoleCommands()
	
    InitializeConfig()
    
    if (not(InitializeStorage())) then
        LOGWARNING(PluginPrefix .. "failed to initialize Storage, plugin will be disabled");
        return false;
    end
    
    LOG("Initialized " .. PLUGIN:GetName() .. " v." .. PLUGIN:GetVersion())
    
    return true;
end


-- use a config.ini file
function InitializeConfig()
    
    local g_ini = cIniFile()
    iniFile = PluginName .. ".ini"
    key = "Limits"
    g_ini:ReadFile(iniFile);
    if not cFile:Exists(iniFile) then
        
        -- home limits for each ranking, 
        g_Config.LIMITUSER  = g_ini:GetValueSetI(key, "Default", 3);
        g_Config.LIMITVIP   = g_ini:GetValueSetI(key, "VIP", 5);
        g_Config.LIMITOP    = g_ini:GetValueSetI(key, "Operator", 10);
        g_Config.LIMITADMIN = g_ini:GetValueSetI(key, "Admin", 0);
    
        g_ini:WriteFile(iniFile);
    else
        local keyID = g_ini:FindKey(key)
        for i = 0, g_ini:GetNumValues(keyID) - 1 do
            g_Config[g_ini:GetValueName(keyID, i)] = g_ini:GetValue(keyID, i)
        end
    end
    
end


function HandleHomeCommand(args, player)

    -- get args
    if #args == 2 then
        -- move player to default home
        return moveToHome(player, "default")
	elseif #args == 3 then
        -- move player to given home if exist 
        return moveToHome(player, string.gsub(args[3], "%s", ""))
    end
    return false
end


function HandleHomeCommandSet(args, player)
	
	if #args >= 4 then
		player:SendMessage(cChatColor.Red .. 'To many arguments to set home... abort command!!!')
		return true
	elseif #args == 3 then
		-- set given home 
		return setHome(player, string.gsub(args[3], "%s", ""))
	else
		-- set default home
		return setHome(player, "default")
	end
end


function HandleHomeCommandList(args, player)
	
	if #args >= 3 then
		player:SendMessage(cChatColor.Red .. 'To many arguments for listing... abort command!!!')
		return true
	else 
		-- list all player homes
		return listHomes(player)
	end
end


function HandleHomeCommandHelp(args, player)

	if #args >= 3 then
		player:SendMessage(cChatColor.Red .. 'To many arguments for help... abort command!!!')
		return true
	else 
		-- display plugin help
		return showHelp(player)
	end
end


function HandleHomeCommandDelete(args, player)

	if #args >= 4 then
		player:SendMessage(cChatColor.Red .. 'To many arguments to delete home... abort command!!!')
		return true
	elseif #args == 3 then
		-- delete given home
		return deleteHome(player, string.gsub(args[3], "%s", ""))
	else
		-- this is not allowed
		player:SendMessage(cChatColor.Red .. 'Name missing... abort command!!!')
		return true
	end
end

function HandleConCommandReInit()
    
    return g_Storage:RecreateDB()
end


-- move player to given home
function moveToHome(player, sHome)

    local a_Data = g_Storage:GetHome({UUID=player:GetUUID(), NAME=sHome})
    
    if a_Data == nil then
        
        player:SendMessage(cChatColor.Red .. 'Home doesn\'t exist...')
        return true
    end
    
    player:SendMessage(cChatColor.Green .. 'Teleporting you to home "' .. a_Data.Name .. '"...')
    player:TeleportToCoords(a_Data.X, a_Data.Y, a_Data.Z)
    if player:GetWorld():GetName() ~= a_Data.World then
        player:MoveToWorld(a_Data.World)
    end
    return true
end


-- set given home
function setHome(player, sHome)

    local a_data = {}
    a_data.UUID   	= player:GetUUID()
    a_data.NAME     = sHome
    a_data.WORLD    = player:GetWorld():GetName()
    a_data.X        = player:GetPosX()
    a_data.Y        = player:GetPosY()
    a_data.Z        = player:GetPosZ()
    a_data.LIMIT 	= tonumber(g_Config[cRankManager:GetPlayerRankName(a_data.UUID)])


    -- check for permission and existing home
    local bExists = g_Storage:CheckForExisting(a_data)
    if not bExists then
        local count = g_Storage:GetTotalCount(a_data)
        if a_data.LIMIT ~= 0 and a_data.LIMIT <= count then
            player:SendMessage(cChatColor.Red .. 'No permission to add more home positions!!!')
            return true
        end
    end
    
    
    -- try to save into database
    if (not (g_Storage:SetHome( a_data ))) then
        player:SendMessage(cChatColor.Red .. 'Home NOT set!')
        return false
    end

    
    -- success and message
    local sMessage = ""
    if not bExists then
        sMessage = "New \"" .. a_data.NAME .. "\" home position set!"
    else
        sMessage = "Replaced position of \"" .. a_data.NAME .. "\" home!"
    end
    player:SendMessage(cChatColor.Green .. sMessage)
    return true
end


-- list all player homes
function listHomes(player)

    local a_List = g_Storage:GetHomeList(player:GetUUID())
    player:SendMessage(cChatColor.Green .. "You own " .. #a_List .. " homes!")
    for i=1, #a_List do
        local msg = cChatColor.Green .. i .. ". " .. a_List[i].Name .. " @ " .. a_List[i].World
        player:SendMessage(msg)
    end
    return true
end


-- delete given home
function deleteHome(player, sHome)
    
    local res = g_Storage:DeleteHome({UUID=player:GetUUID(), NAME=sHome})
    if res then
        player:SendMessage(cChatColor.Green .. "Home " .. sHome .. " successfully deleted!!!")
    end
    return res
end


-- display plugin help
function showHelp(player)
    
    player:SendMessage(cChatColor.Yellow .. "[INFO] " ..  cChatColor.White .. "Usage /~ < Goto | Set | List | Delete | Help > [name] ")
    player:SendMessage(cChatColor.Yellow .. "[INFO] " ..  cChatColor.Green .. "/~ g => port you to your default home")
    player:SendMessage(cChatColor.Yellow .. "[INFO] " ..  cChatColor.Green .. "/~ g myHome => port you to home 'myHome'")
    player:SendMessage(cChatColor.Yellow .. "[INFO] " ..  cChatColor.Green .. "/~ s => set the actual position as default home")
    player:SendMessage(cChatColor.Yellow .. "[INFO] " ..  cChatColor.Green .. "/~ s myHome => set the actual position as 'myHome'")
    player:SendMessage(cChatColor.Yellow .. "[INFO] " ..  cChatColor.Green .. "/~ l => list all your home by name and world")
    player:SendMessage(cChatColor.Yellow .. "[INFO] " ..  cChatColor.Green .. "/~ d myHome => deletes 'myHome'")
    player:SendMessage(cChatColor.Yellow .. "[INFO] " ..  cChatColor.Green .. "/~ h => shows this help")
    
    return true
end


-- print tables
function DebugTable( table )
    
    LOG("\n***************** DEBUG START ******************")
    for key, value in pairs( table ) do
        LOG("\tKey: " .. key .. "\tValue: " .. value)
    end
    LOG("\n***************** DEBUG END ******************")
end
