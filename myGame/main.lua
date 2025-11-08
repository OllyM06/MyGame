function love.load()
    love.window.setTitle('MyGame')
    wf = require 'Libraries/windfield'
    world = wf.newWorld(0, 0, true)

    camera = require 'Libraries/camera'
    cam = camera()

    anim8 = require 'Libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'Libraries/sti'
    MaingameMap = sti('Maps/Main Map/LoveTiles.lua')

    fullscreen = false

    player = {}
    player.health = 100
    player.damage = false
    player.collider = world:newBSGRectangleCollider(400, 250, 60, 100, 10)
    player.collider:setFixedRotation(true)
    player.x = 100
    player.y = 200
    player.width = 1000
    player.height = 1000
    player.speed = 300
    player.spritesheet = love.graphics.newImage('Sprites/SpriteSheet.png')
    player.grid = anim8.newGrid(12, 18, player.spritesheet:getWidth(), player.spritesheet:getHeight())
    player.heathBar = love.graphics.newImage('Sprites/Health Bar/health-bar-100.png')
    player.heart = love.graphics.newImage('Sprites/Heart.png')

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.left

    walls = {}
    if MaingameMap.layers["Walls"] then
        for i, obj in pairs(MaingameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end

    end

    Damage = {}
    obsti = {}
    if MaingameMap.layers["Damage"] then
        for i, obsti in pairs(MaingameMap.layers["Damage"].objects) do
            obsti = world:newRectangleCollider(obsti.x, obsti.y, obsti.width, obsti.height)
            obsti:setType('static')
            table.insert(Damage, obsti)
        end

    end

end

function love.update(dt)
    local isMoving = false
    local vx = 0
    local vy = 0

 if checkCollision(player, obsti) then
        player.damage = true
        love.timer.sleep(1)
    end
    
    if love.keyboard.isDown("d") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("a") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true

    end

    if love.keyboard.isDown("s") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true

    end

    if love.keyboard.isDown("w") then
        vy = player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    end

    if player.damage == true then

        player.heath = player.health - 10

        player.heathBar = love.graphics.newImage('Sprites/Health Bar/health-bar-90.png')

    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    player.anim:update(dt)

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w / 2 then
        cam.x = w / 2
    end

    if cam.y < h / 2 then
        cam.y = h / 2
    end

    local mapW = MaingameMap.width * MaingameMap.tilewidth
    local mapH = MaingameMap.height * MaingameMap.tileheight

    if cam.x > (mapW - w / 2) then
        cam.x = (mapW - w / 2)
    end

    if cam.y > (mapH - h / 2) then
        cam.y = (mapH - h / 2)
    end

end

function love.draw()
    cam:attach()
    MaingameMap:drawLayer(MaingameMap.layers["Ground"])
    MaingameMap:drawLayer(MaingameMap.layers["Trees"])
    player.anim:draw(player.spritesheet, player.x, player.y, nil, 6, nil, 6, 9)
    MaingameMap:drawLayer(MaingameMap.layers["Trees Front"])
    -- world:draw()
    cam:detach()
    love.graphics.print(player.health, 100, 100)
    love.graphics.draw(player.heathBar, 300, 10)
    love.graphics.draw(player.heart, 285, 7.5)

end

function checkCollision(a, b)
    return a.x < b.x + b.width 
    and b.x < a.x + a.width
    and a.y < b.y + b.height 
    and b.y < a.y + a.height
end

function love.keypressed(key, scancode, isrepeat)
    if key == "f11" then
        love.window.setFullscreen(not fullscreen)
        fullscreen = not fullscreen
    end
end
