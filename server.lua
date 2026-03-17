ESX = exports['es_extended']:getSharedObject()

exports("Execute", function(command)
    print("[API] Commande reçue :", command)
    ExecuteCommand(command)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    Wait(500)

    print([[
^2
  _    _             _____  
 | |  | |           |  __ \ 
 | |  | |___  ___ _ __| |  | |
 | |  | / __|/ _ \ '__| |  | |
 | |__| \__ \  __/ |  | |__| |
  \____/|___/\___|_|  |_____/ 
                               
^7]])

    print("^2[INFO]^7 Bot API chargé avec succès.")
    print("^2[AUTEUR]^7 Développé par ^5USERD^7 pour ^3Pulse^7 !")
    print("^2[VERSION]^7 1.0.0 stable")
    print("^5--------------------------------------------------^7")
end)