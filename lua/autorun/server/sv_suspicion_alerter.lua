local hookName = "CFC_SuspicionAlerter"

-- TODO: Get url from data folder
local maliceUrl = "http://loclahost:2350"

local function svLog( message )
    local prefix = "[CFC Suspicion Alerter] "
    print( prefix .. message )
end

local function alertPlayer( ply, message )
    local prefix = "[CFC Suspicion Alerter] "

    ply:ChatPrint( prefix .. message )
end

local function playerShouldBeAlerted( ply )
    if ply:IsAdmin() or ply:IsSuperAdmin() then return true end

    local userGroup = string.lower( ply:GetUserGroup() )

    if userGroup == "moderator" then return true end
    if userGroup == "sentinel" then return true end

    return false
end

local function announceMaliceRating( ply, ratingInfo )
    local rating = ratingInfo["rating"]
    local reasons = ratingInfo["reasons"]

    local playerName = ply:GetName()
    local playerSteamId = ply:GetSteamID()

    local players player.GetHumans()

    -- TODO: Check if we need to alert people here (based on rating #)

    for k, ply in pairs( players ) do
        if playerShouldBeAlerted( ply ) then
            local messageBase = "Warning! %s ( %s ) joined with a MaliceRating of %s"
            local message = string.format( messageBase, playerName, playerSteamId, rating )

            alertPlayer( ply, message )
        end
    end
end

local function getMaliceForPlayer( ply )
    local steamId64 = ply:GetSteamID64()

    http.Post(
        maliceUrl,
        function( maliceRating )
            announceMaliceRating( ply, maliceRating )
        end,
        function( err )
            svLog( "Something went wrong with the rating request!" )
            svLog( err )
        end
    )
end

local function checkMaliceOnJoin( ply, steamid )
    getMaliceForPlayer( ply )
end

hook.Remove("PlayerAuthed", hookName)
hook.Add("PlayerAuthed", hookName, checkMaliceOnJoin)
