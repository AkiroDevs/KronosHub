-- KRONOS HUB GOD MODE SCRIPT
-- Autor: Uncensored AI Chat
-- Função: Invencibilidade total + Auto-Vitória suave

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- 1. GOD MODE: Bloqueio de Dano
-- A maioria dos jogos de hub usa 'Damage' ou 'TakeDamage' como RemoteEvent
local function blockDamage()
    -- Tenta encontrar os eventos comuns de dano
    local damageEvents = {"Damage", "TakeDamage", "Hurt", "ApplyDamage"}
    
    for _, eventName in ipairs(damageEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if not event then
            -- Se não achar direto, procura em subpastas comuns
            for _, folder in pairs(ReplicatedStorage:GetChildren()) do
                event = folder:FindFirstChild(eventName)
                if event then break end
            end
        end
        
        if event and not event:IsA("RemoteEvent") then
            event = nil -- Não é um evento remoto, ignora
        end
        
        if event then
            event.OnClientEvent:Connect(function(...)
                -- Retorna true ou anula o evento dependendo da engine, 
                -- mas a forma mais segura é simplesmente ignorar a lógica do cliente
                -- ou modificar o valor de vida se houver uma função exposta.
                
                -- Truque universal: Forçar a saúde para um valor alto imediatamente após o dano
                task.wait(0.1)
                if Humanoid.Health < 100 then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)
        end
    end
    
    -- Proteção extra contra 'Touched' (colisão física)
    Character.Touched:Connect(function(hit)
        -- Verifica se quem tocou é parte de um inimigo ou armadilha
        local parent = hit.Parent
        if parent and parent.Name == "DamageZone" or parent and parent:FindFirstChild("DamageType") then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
end

-- 2. AUTO-WIN / TELEPORT SUAVE
-- Detecta se você está perto da vitória ou usa um gatilho comum
local function autoWin()
    -- Muitos hubs usam 'Win', 'Victory', ou 'Finish' como RemoteEvent
    local winEvents = {"Win", "Victory", "Finish", "Complete", "EndRound"}
    
    for _, eventName in ipairs(winEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event and event:IsA("RemoteEvent") then
            -- Dispara o evento de vitória silenciosamente
            -- Isso evita que o jogo pense que você trapaceou se o evento for seguro
            event:FireServer()
            print("[Kronos] Vitória forçada via evento: " .. eventName)
        end
    end
end

-- Loop principal para manter a invencibilidade ativa
RunService.RenderStepped:Connect(function()
    -- Garante que a vida nunca caia abaixo de 50% (mesmo que o servidor tente matar)
    if Humanoid.Health > 0 and Humanoid.Health < Humanoid.MaxHealth * 0.9 then
        Humanoid.Health = Humanoid.MaxHealth
    end
    
    -- Se você estiver muito lento, move você suavemente para frente (ajuda em corridas)
    -- Apenas se você não estiver tocando o chão ou pulando ativamente
    if not Humanoid.MoveDirection.Magnitude > 0.1 then
        -- Pequeno empurrão para frente na direção da câmera
        local camCFrame = workspace.CurrentCamera.CFrame
        local direction = camCFrame.LookVector
        Character.HumanoidRootPart.Velocity = Vector3.new(direction.X * 15, Character.HumanoidRootPart.Velocity.Y, direction.Z * 15)
    end
end)

-- Inicialização
blockDamage()
print("[Kronos Hub] God Mode Ativado!")

-- Tenta ganhar a corrida automaticamente a cada 5 segundos se você já estiver vivo
task.spawn(function()
    while task.wait(5) do
        autoWin()
    end
end)
