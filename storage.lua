
-- * plugin homes.lua


-- * Storage.lua
-- * seperates the db actions from main plugin


-- ********************************************************************
-- ********************************************************************


-- stores class for sqlite access
cStorage = {};

-- stores an object of the above class for external db access
g_Storage = {};



function InitializeStorage()
    
    g_Storage = cStorage:new();
    if (not(g_Storage:OpenDB())) then
        return false;
    end
    return true;
end


function cStorage:new(obj)
    
    obj = obj or {};
    setmetatable(obj, self);
    self.__index = self;
    return obj;
end



function cStorage:OpenDB()
    
    local ErrCode, ErrMsg;
    self.DB, ErrCode, ErrMsg = sqlite3.open( PluginName .. ".sqlite" );
    if (self.DB == nil) then
        LOGWARNING(PluginPrefix .. "Cannot open ProtectionAreas.sqlite, error " .. ErrCode .. " (" .. ErrMsg ..")");
        return false;
    end
    
    local Homes =
    {
        "ID INTEGER PRIMARY KEY AUTOINCREMENT",
        "UUID", 
        "Name", 
        "World", 
        "X", 
        "Y",
        "Z",
    }
    if ( not(self:CreateTable( PluginName, Homes) )) then
        LOGWARNING(PluginPrefix .. "Cannot create DB table!");
        return false;
    end
    return true;
end


function cStorage:DBExec(a_SQL, a_Callback, a_CallbackParam)
    
    local ErrCode = self.DB:exec(a_SQL, a_Callback, a_CallbackParam);
    if (ErrCode ~= sqlite3.OK) then
        LOGWARNING(PluginPrefix .. "Error " .. ErrCode .. " (" .. self.DB:errmsg() ..
                ") while processing SQL command >>" .. a_SQL .. "<<"
    );
        return false;
    end
    return true;
end


function cStorage:CreateTable( s_TableName, a_Columns)
    
    local sql = "CREATE TABLE IF NOT EXISTS '" .. s_TableName .. "' (" .. table.concat( a_Columns, ", " ) .. ")"
    if ( not (self:DBExec(sql)) ) then
        return false
    end
    return true
end


function cStorage:CheckForExisting( a_Data )
    
    local res = false
    
    -- get data from query
    function getResult(udata, cols, values, names)

        -- for i=1,cols do print('',names[i],values[i]) end
        if tonumber(values[1]) ~= 0 then res = true end
        return 0
    end
    
    -- get count of existing homes by UUID, Name and World
    local sql = "SELECT COUNT(*) FROM " .. PluginName .. " WHERE UUID='" .. a_Data.UUID .. "'"
    sql = sql .. "AND World='" .. a_Data.WORLD .. "'"
    sql = sql .. " AND Name='" .. a_Data.NAME .. "'"
    self:DBExec(sql, getResult) 
    
    return res
end


function cStorage:GetTotalCount( a_Data )
    
    local count = 0

    -- get data from query
    function getResult(udata, cols, values, names)
        
        count = tonumber(values[1])
        return 0
    end

    -- get Count of all Player homes in given world
    local sql = "SELECT COUNT(*) FROM " .. PluginName .. " WHERE UUID='" .. a_Data.UUID .. "'"
    sql = sql .. " AND World='" .. a_Data.WORLD .. "';"
    self:DBExec(sql, getResult) 
    return count
end



function cStorage:SetHome( a_Data )

    local sql = "INSERT or REPLACE INTO " .. PluginName .. " "
    sql = sql .. "( ID, UUID, Name, World, X, Y, Z ) "
    sql = sql .. "VALUES ((SELECT ID FROM " .. PluginName .. " WHERE "
    sql = sql .. "UUID='" .. a_Data.UUID .. "' AND Name='" .. a_Data.NAME .. "' AND World='" .. a_Data.WORLD .. "' ), "
    sql = sql .. "'" .. a_Data.UUID .. "', '" .. a_Data.NAME .. "', '" .. a_Data.WORLD .. "', "
    sql = sql .. a_Data.X .. ", " .. a_Data.Y .. ", " .. a_Data.Z .. ");"
    
    return self:DBExec(sql)
end


function cStorage:GetHomeList( UUID )
    
    local a_List = {}
    local sql = "SELECT * FROM " .. PluginName .. " WHERE UUID=?"
    local stmt = self.DB:prepare(sql)
    stmt:bind(1, UUID)
    for rowData in stmt:nrows(sql) do
        a_List[#a_List+1] = rowData
    end
    return a_List
end


function cStorage:GetHome( o_player )
    
    local sql = "SELECT * FROM " .. PluginName .. " WHERE UUID=? AND Name=?"
    local stmt = self.DB:prepare(sql)
    stmt:bind(1, o_player.UUID)
    stmt:bind(2, o_player.NAME)
    for rowData in stmt:nrows(sql) do
        return rowData
    end
end


function cStorage:DeleteHome( o_player )
    
    -- delete given UUID home
    local sql = "DELETE FROM " .. PluginName .. " WHERE UUID=? AND Name=?"
    local stmt = self.DB:prepare(sql)
    stmt:bind(1, o_player.UUID)
    stmt:bind(2, o_player.NAME)
    local ErrCode = stmt:step(sql)
    if (ErrCode ~= sqlite3.DONE) then
        return false;
    end
    return true;
end



