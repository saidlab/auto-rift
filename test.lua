print('Loaded script')

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

task.wait(30)

if not _G.Webhook then
	local Get = readfile("webhook.txt")
	if Get:find("https") then
		_G.Webhook = Get
	else
		warn('Coloque um link de webhook !!!')
		return
	end
end

local Get,a = pcall(readfile,"webhook.txt")
if _G.Webhook and Get ~= _G.Webhook then
	writefile("webhook.txt", _G.Webhook)
end


local HttpService = game:GetService("HttpService")
local riftFolder = game:GetService("Workspace"):WaitForChild("Rendered"):WaitForChild("Rifts")
local message = ""

local function Short(num)
	if num >= 1000 then
		return string.format("%.1fk", num/1000)
	else
		return tostring(num)
	end
end

local Emojis,content = {
	['royal-chest'] = "<:Royal_Key:1361204061575315617>",
	['golden-chest'] = "<:Golden_Key:1361204071729594449>",
	['cyber-egg'] = "<:Mining_Egg:1369738274670645278>",
	['mining-egg'] = "<:Mining_Egg:1369738274670645278>",
	['bubble-rift'] = "<:Bubbles:1362512396991725688>",
	['silly-egg'] = "<:Silly_Egg:1369738286393856090>",
	['dice-chest'] = "<:Dice_Key:1369744114849153184>",
	['dice-rift'] = "<:Dice_Key:1369744114849153184>",
},""

for _, rift in ipairs(riftFolder:GetChildren()) do
	local display = rift:FindFirstChild("Display")
	local surfaceGui = display and display:FindFirstChild("SurfaceGui")
	local icon = surfaceGui and surfaceGui:FindFirstChild("Icon")
	local luckLabel = icon and icon:FindFirstChild("Luck")
	local despawnAt = rift:GetAttribute("DespawnAt") or 0
	local timestamp = math.floor(despawnAt)
	local yPos = display and math.round(display.Position.Y) or 0
	local luckText = (luckLabel and luckLabel.Text ~= "" and luckLabel.Text) or "?"
	local itemName = string.upper(rift.Name)
	local EMOJI = Emojis[rift.Name] or "<:EggBlack256:1369740204922896384>"

	if rift.Name == 'silly-egg' then
		content = "@everyone Alerta de Silly, Todos atrás do Stalcks!"
	end

	if luckText == "?" then
		message = message .. string.format("> %s [**%s**] ⌛ <t:%d:R> | 📍 %s\n", EMOJI, itemName, timestamp, Short(yPos))
	else
		message = message .. string.format("> %s [**%s**] ⌛ <t:%d:R> | 📍 %s | 🍀 **[%s](https://luck.li)**\n", EMOJI, itemName, timestamp, Short(yPos), luckText)
	end
end

local payload = {
	content = content,
	embeds = {
		{
			title       = "📢 NOTIFICAÇÃO RIFT SERVER "..#game.Players:GetPlayers().."/12" ,
			description = message .. "\nColoque o link no Navegador para entrar no Servidor```roblox://experiences/start?placeId=85896571713843&gameInstanceId="..game.JobId.."```",
			color       = 0xFFFF00,
			timestamp   = DateTime.now():ToIsoDate()
		}
	}
}

local requestFunction = syn and syn.request or http and http.request or http_request or request or error("Nenhuma função de HTTP disponível")

local success, response = pcall(function()
	return requestFunction({
		Url = _G.Webhook,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(payload)
	})
end)

if not success then
	warn("[Webhook] Falha ao enviar:", response)
else
	print("[Webhook] Mensagem enviada com sucesso! Código de status:", response.StatusCode or response.statusCode)
end

queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/saidlab/auto-rift/refs/heads/main/test.lua'))()")

task.wait(30)

print('Telepote Function')

local cursor,found = "",false
while not found do
	local fullUrl = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
	if cursor ~= "" then
		fullUrl = fullUrl.."&cursor="..cursor
	end
	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(fullUrl))
	end)
	if success and result and result.data then
		for _, server in ipairs(result.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				found = true
				TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
				return
			end
		end
		if result.nextPageCursor then
			cursor = result.nextPageCursor
		else
			print("Parou :(")
			break
		end
	else
		warn("Erro ao buscar servidores públicos.")
		break
	end
end
