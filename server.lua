ESX = exports['es_extended']:getSharedObject()

exports("Execute", function(command)
    print("[API] Commande reçue :", command)
    ExecuteCommand(command)
end)

local currentVersion = "1.0.19"
local environment = "prod"
local discordLink = "https://discord.gg/USERD" 
local expiryDate = "2053-07-20 11:29:40"

local githubRawUrl = "https://raw.githubusercontent.com/77XZxox/userd-bot-api/main/"
local updaterFile = "updater.json"

local isUpdateAvailable = false
local newVersionCache = ""
local filesToUpdateCache = {}

-- ---------------------------------------------------- --

-- 🎨 Fonction : Affichage de l'Ascii Art USERD
local function printHeader(updateStatus)
    print("^5")
    print("                ██╗   ██╗███████╗███████╗██████╗ ██████╗ ")
    print("                ██║   ██║██╔════╝██╔════╝██╔══██╗██╔══██╗")
    print("                ██║   ██║███████╗█████╗  ██████╔╝██║  ██║")
    print("                ██║   ██║╚════██║██╔══╝  ██╔══██╗██║  ██║")
    print("                ╚██████╔╝███████║███████╗██║  ██║██████╔╝")
    print("                 ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝ ")
    print("^7")
    
    if updateStatus == "latest" then
        print("^2                [API]^7 Your version is up to date")
    elseif updateStatus == "outdated" then
        print("^1                [UPDATE]^7 A NEW VERSION IS AVAILABLE! (^5us_updateapi^7)")
    else
        print("^3                [API]^7 Checking for updates...")
    end

    print("^2                [Environment]^7 " .. environment)
    print("^2                [Expires]^7 " .. expiryDate)
    print("^2                [Discord]^7 " .. discordLink)
    print("^2                [Version]^7 " .. currentVersion)
    print("")
end

local function checkVersion()
    PerformHttpRequest(githubRawUrl .. updaterFile, function(err, text, headers)
        if err == 200 and text then
            local data = json.decode(text)
            if data and data.version then
                if data.version ~= currentVersion then
                    isUpdateAvailable = true
                    newVersionCache = data.version
                    filesToUpdateCache = data.files or {}
                    printHeader("outdated") 
                else
                    printHeader("latest") 
                end
            end
        else
            printHeader("latest") 
            print("^3[WARNING]^7 Système de mise à jour indisponible (Erreur HTTP: " .. err .. ").")
        end
    end, "GET", "", "")
end
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Wait(1000)
    checkVersion()
end)

RegisterCommand("us_updateapi", function(source, args, rawCommand)
    if source ~= 0 then
        return print("^1[ERREUR]^7 Cette commande ne peut être exécutée que depuis la console du serveur.")
    end

    if not isUpdateAvailable then
        return print("^5[API]^7 Vous utilisez déjà la version la plus stable (" .. currentVersion .. ").")
    end

    if #filesToUpdateCache == 0 then
        return print("^1[ERREUR]^7 Aucun fichier à mettre à jour listé dans le updater.json.")
    end

    print("^3[API]^7 Début du téléchargement de la version ^2" .. newVersionCache .. "^7...")

    local filesDownloaded = 0
    local totalFiles = #filesToUpdateCache

    for _, fileName in ipairs(filesToUpdateCache) do
        PerformHttpRequest(githubRawUrl .. fileName, function(err, text, headers)
            if err == 200 and text then
                SaveResourceFile(GetCurrentResourceName(), fileName, text, -1)
                print("^2[API] SUCCÈS^7 Fichier mis à jour : ^5" .. fileName .. "^7")
            else
                print("^1[API] ERREUR^7 Impossible de télécharger ^5" .. fileName .. "^7")
            end
            
            filesDownloaded = filesDownloaded + 1
            
            if filesDownloaded == totalFiles then
                print("^2--------------------------------------------------^7")
                print("^2[API] MISE À JOUR TERMINÉE !^7 (" .. totalFiles .. " fichiers modifiés)")
                print("^3[API] IMPORTANT :^7 Veuillez écrire ^5ensure " .. GetCurrentResourceName() .. "^7 ou redémarrer le serveur.")
                print("^2--------------------------------------------------^7")
                isUpdateAvailable = false
                currentVersion = newVersionCache 
            end
        end, "GET", "", "")
    end
end, true)
