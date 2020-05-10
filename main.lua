-- labyrinthe
require('switch')
local timer = love.timer.getTime()
local labyrinthe_width = 32 -- nbre de colonnes
local labyrinthe_height = 32 -- nbre de lignes
local pos_depart = {1, 5}
local pos_arrive = {labyrinthe_width + 1,3} -- x et y de la position d'arrivé
local principal = {} -- stockage pour le parcours principal : la solution 
local t = {} -- table pour stocker mes blocs (parcours)
local t1 = {}  -- table pour voir le tableau des directions possibles
local Bloc = {} --mon objet Bloc
local b = Bloc

local reach = false -- arrivé atteinte
math.randomseed( os.time() ) -- initialise le random 
Bloc.new = function(self,o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
  end
Bloc.init = function(self, x, y, d_in, d_out, dirs)
    self.size = 32 -- taille en pixels du bloc
    self.x = x  or 0  -- position en x
    self.y = y  or 0  -- position en y
    self.d_in = d_in or '' -- direction entrante
    self.d_out = d_out or '' -- direction sortante
    self.dirs = dirs or {} -- autres directions de sorties possible
    self.image = love.graphics.newImage("images/1.jpg")
end
Bloc.draw = function(self) -- dessine le bloc avec tous ses parametre
    love.graphics.push(all)
    love.graphics.translate( self.x * self.size - self.size, self.y * self.size - self.size) -- pose le bloc au bon endroit
    love.graphics.setLineStyle('rough')
    love.graphics.setLineJoin('miter')
    love.graphics.setLineWidth(self.size /20)
    -- dessine les coutours du bloc
    love.graphics.setColor(HSL(135,255,125)) --blue color
    love.graphics.rectangle('fill', self.x, self.y, self.size, self.size, self.size/10, self.size/10)
    -- dessine les fleche pour indiquer les directions d'entrée/sortie du bloc (comme un cadrant de montre)
    self:draw_dir_in()
    self:draw_dir_out()
    -- dessine les directions restantes possible
    self:draw_dirs_allowed()
    -- todo : afficher l'index dans la table sur le bloc
    love.graphics.pop()
end
Bloc.setImage = function(self, nomImage)
    a = switch {
    ["1"]  = function(x) self.image = love.graphics.newImage( "images/1.jpg" ) end ,
    ["2"]  = function(x) self.image = love.graphics.newImage( "images/2.jpg" ) end ,
    ["3"]  = function(x) self.image = love.graphics.newImage( "images/3.jpg" ) end ,
    ["4"]  = function(x) self.image = love.graphics.newImage( "images/4.jpg" ) end ,
    ["5"]  = function(x) self.image = love.graphics.newImage( "images/5.jpg" ) end ,
    ["6"]  = function(x) self.image = love.graphics.newImage( "images/6.jpg" ) end ,
    ["7"]  = function(x) self.image = love.graphics.newImage( "images/7.jpg" ) end ,
    ["8"]  = function(x) self.image = love.graphics.newImage( "images/8.jpg" ) end ,
    ["9"]  = function(x) self.image = love.graphics.newImage( "images/9.jpg" ) end ,
    ["10"] = function(x) self.image = love.graphics.newImage( "images/10.jpg") end ,
    ["a"]  = function(x) self.image = love.graphics.newImage( "images/A.png" ) end ,
    ["d"]  = function(x) self.image = love.graphics.newImage( "images/D.png" ) end ,
    ["en"] = function(x) self.image = love.graphics.newImage( "images/EN.jpg") end ,
    ["eo"] = function(x) self.image = love.graphics.newImage( "images/EO.jpg") end ,
    ["es"] = function(x) self.image = love.graphics.newImage( "images/ES.jpg") end ,
    ["ne"] = function(x) self.image = love.graphics.newImage( "images/NE.jpg") end ,
    ["no"] = function(x) self.image = love.graphics.newImage( "images/NO.jpg") end ,
    ["ns"] = function(x) self.image = love.graphics.newImage( "images/NS.jpg") end ,
    ["oe"] = function(x) self.image = love.graphics.newImage( "images/OE.jpg") end ,
    ["on"] = function(x) self.image = love.graphics.newImage( "images/ON.jpg") end ,
    ["os"] = function(x) self.image = love.graphics.newImage( "images/OS.jpg") end ,
    ["se"] = function(x) self.image = love.graphics.newImage( "images/SE.jpg") end ,
    ["sn"] = function(x) self.image = love.graphics.newImage( "images/SN.jpg") end ,
    ["so"] = function(x) self.image = love.graphics.newImage( "images/SO.jpg") end ,

    default = function(x) print("bad switch") end
    }
    return  a:case(tostring(nomImage))
end

Bloc.draw2 = function(self)
  love.graphics.push(all)
  love.graphics.translate(self.x * self.size - self.size, self.y * self.size - self.size) -- pose le bloc au bon endroit
  love.graphics.draw(self.image,0,0) -- löve
  love.graphics.pop()
end

Bloc.draw_dir_in = function(self) -- dessine une fleche representant la direction d'entrée
    -- dessine la fleche entrante en fonction de la direction entrante "d_in"
    local rot = 0
    local directionsPossibles = {'o','n','e','s'}
        for i, v in pairs(directionsPossibles) do 
            if v == self.d_in then 
                rot = i * math.pi/2 -- rotate by direction (rad)
            end
        end
        love.graphics.push(all)
        love.graphics.setColor(HSL(40,255,125)) -- yellow color
        love.graphics.translate(self.x + self.size/2, self.y + self.size/2) -- translate au milieu du bloc
        love.graphics.rotate(rot)
        love.graphics.arc('line', 0 , 0 + self.size/2 - self.size/25 , self.size/10,- math.pi, 0, 20) -- dessine un arc collé au cadre
        love.graphics.line(0,0,0,0 + self.size/2 - self.size/10) -- dessine l'aiguille
        love.graphics.pop()
end

Bloc.draw_dir_out = function(self) -- dessine une fleche representant la direction de sortie
    -- dessine la fleche sortante en fonction de la direction sortante "d_out"
    local rot = 0
    local directionsPossibles = {'o','n','e','s'}
        for i, v in pairs(directionsPossibles) do 
            if v == self.d_out then 
                rot = i * math.pi/2 -- rotate by direction (rad)
            end
        end
        -- print(rot)
        love.graphics.push(all)
        love.graphics.setColor(HSL(100,255,125)) -- green color
        love.graphics.translate(self.x + self.size/2, self.y + self.size/2) -- translate au milieu du bloc
        love.graphics.rotate(rot)
        -- dessine un triangle collé au cadre
        love.graphics.line(0, self.size/2 , - self.size/10 , self.size/2- self.size/10 )
        love.graphics.line(0 ,self.size/2 , self.size/10 , self.size/2- self.size/10 )
        love.graphics.line(- self.size/10 , self.size/2- self.size/10 , self.size/10 , self.size/2- self.size/10)
        -- dessine l'aiguille
        love.graphics.line(0,0,0,self.size/2 - self.size/10) 
        love.graphics.pop()
end

Bloc.draw_dirs_allowed = function(self) -- dessine un cercle vert indiquant les directions encore possible
    local function draw_circle(rot)
        love.graphics.push(all)
        love.graphics.setColor(HSL(100,255,125)) -- green color
        love.graphics.translate(self.x + self.size/2, self.y + self.size/2)
        love.graphics.rotate(rot * math.pi/2) -- rotation en fonction de la direction
        love.graphics.circle('fill', 0 , 0 + self.size/2 - self.size/20, self.size/20,12) -- dessine un cercle en bas milieu du bloc
        love.graphics.pop()
    end

    local rot = 0
    local directionsPossibles = {'o','n','e','s'}
    for i, v in pairs(self.dirs) do 
        for k, value in pairs(directionsPossibles) do
            if v==value then
                draw_circle(k) -- dessine un cercle et le tourne suivant la directions
            end
        end
    end
end

Bloc.construct_by_previous = function(self,prev) -- construit un bloc en se servant du precedent
    self.x = prev.x -- copie les coordonnées
    self.y = prev.y 
    if prev.d_out == 'n' then -- si out = nord
        self.y = self.y - 1 -- on monte d'une case (y va vers le bas, donc on enleve pour monter)
        self.d_in = 's' -- on renseigne la direction entrante ( si je sort au nord alors je viens du sud)
    elseif prev.d_out == 's' then -- si out = sud 
        self.y = self.y + 1 -- on descend d'une case
        self.d_in ='n' -- etc...
    elseif prev.d_out == 'e' then
        self.x = self.x + 1
        self.d_in = 'o'
    elseif prev.d_out =='o' then
        self.x = self.x - 1
        self.d_in = 'e'
    else print("pas de d_out !!!--> donc pas de coordonnées ni de d_in......")
    end
    -- renseigne les direction possible ( suivant la position du bloc et la taille du labyrinthe)
    self:allowed_directions(labyrinthe_width,labyrinthe_height)
    self.d_out = 'x'
end

Bloc.allowed_directions = function(self,labyrinthe_width,labyrinthe_height) -- calcul les directions possibles suivant la position du bloc sur l'echiquier
    -- gere les directions possible
    if self.x == 1 and self.y == 1 then                            --coin haut-gauche
        self.dirs = {"x","x","e","s"}                                        -- ne peut pas aller vers le nord ni retourner à l'ouest
    elseif self.x == labyrinthe_width and self.y == 1 then           -- coin haut-droit
        self.dirs = {"x","x","x","s"}                                        -- ne peut aller ni vers le nord, ni vers l'est, ni vers l'ouest
    elseif self.x == 1 and self.y == labyrinthe_height then             -- coin bas-gauche
        self.dirs = {"x","n","e","x"}                                        -- ne peut aller ni vers le sud, ni vers l'ouest
    elseif self.x == labyrinthe_width and self.y == labyrinthe_height then -- coin bas-droit
        self.dirs = {"x","n","x","x"}                                        -- ne peut aller ni vers le sud, ni vers l'est, ni vers l'ouest
    elseif self.x == 1 then                                        --colonne de gauche
        self.dirs = {"x","n","e","s"}                                    -- ne peut aller vers l'ouest
    elseif self.y == 1 then                                        -- ligne du haut
        self.dirs = {"x","x","e","s"}                                    -- ne peut pas aller vers le nord ni en arriere
    elseif self.y == labyrinthe_height then                        -- ligne du bas
        self.dirs = {"x","n","e","x"}                                     --ne peut pas aller vers le sud , ni en arriere    
    elseif self.x == labyrinthe_width and self.y < pos_arrive[2] then  --colonne de droite (au dessus de la position d'arrivée)
        self.dirs = {"x","x","x","s"}                                     -- ne peut aller que vers le bloc d'arrivé
    elseif self.x == labyrinthe_width and self.y > pos_arrive[2] then -- colonne de droite (en dessous de la position d'arrivée)
      self.dirs = {"x","n","x","x"} -- pareil du coup il remonte
    elseif self.x == labyrinthe_width and self.y == pos_arrive[2] then
      self.dirs = {"x","x","e","x"}
    else self.dirs = {"o","n","e","s"} --autorise toutes les directions
    end
    if self.d_in then -- s'il y'a une direction entrant
        for i, v in pairs(self.dirs) do
            if v == self.d_in then
                self.dirs[i] = "x" -- on l'enleve des choix possible ( pas de retour arrière )
            end
        end
    end 
end

Bloc.random_out = function(self) -- choisit aleatoirement la direction de sortie parmie les directions possibles
    -- choisit aleatoirement une directions
    -- math.randomseed( os.time() ) -- initialise le random
    -- on reconstruit la table des possibilité :
    local n = 0
    local pos = {}
    for i, v in pairs(self.dirs) do
        if v ~= "x" then 
            table.insert(pos, v)
            n = n + 1
        end
    end

    r = math.random(n) -- choix aleatoire
    self.d_out = pos[r]
    -- enleve la d_out des dirs
    for i, v in pairs(self.dirs) do
        if self.d_out == v then
            table[i] = "x" -- on l'enleve des choix possible ( pas de retour arrière )
        end
    end
end

Bloc.remove_direction = function(self,dir) -- enleve la direction du choix des directions possible
  for i, v in pairs(self.dirs) do
    if v == dir then
      self.dirs[i] = 'x' -- on enleve la directions
    end
  end
end

Bloc.get_number_of_directions = function(self) -- retourne le nombre de directions possible
    local count = 0
    for i,_ in pairs(self.directions) do
        count = count + 1
    end
    return count
end
------------------------------------------------------------------
function love.load() -- ce charge une fois au lancement du programme
    
    -- initialise le bloc de depart
    local b = Bloc -- cré un nouveau bloc puis l'initialise
    b:init(pos_depart[1], pos_depart[2],'o','e',{'x','n','x','s'}) -- on choisit la position et les directions
    love.window.setMode((labyrinthe_width + 2 )   * b.size   ,(labyrinthe_height + 2) * b.size) -- on cré la fenetre en fonction du la taille choisie
    
    table.insert(t,b)
    
    for i = 1, labyrinthe_width do -- remplit tout l'echiquier de cases bleues
        for j = 1, labyrinthe_height do 
            b = Bloc:new()
            b.x = i 
            b.y = j
            b:allowed_directions(labyrinthe_width,labyrinthe_height)
            b.draw = function(self) -- on remplace la function draw par celle ci pour le decor
              love.graphics.push(all)
              love.graphics.translate( self.x * self.size - self.size, self.y * self.size - self.size) -- pose le bloc au bon endroit
              love.graphics.setLineStyle('rough')
              love.graphics.setLineJoin('miter')
              love.graphics.setLineWidth(self.size /20)
              -- dessine les coutours du bloc
              love.graphics.setColor(HSL(135,255,125)) --blue color
              love.graphics.rectangle('fill', self.x, self.y, self.size, self.size, self.size/10, self.size/10)
              love.graphics.pop()
            end
            
            table.insert(t1,b)
        end 
    end
end

function love.update(dt) 
    
    if love.keyboard.isDown("escape") then
        love.window.close()
    end
    -- if timer + 0.2 > love.timer.getTime() then
        -- do nothing
    -- else
    --    timer = timer + 0.2
        local b = Bloc:new() -- creation d'un nouveau bloc
        if not reach then
          -- do something
          b:construct_by_previous(t[#t]) -- on renseigne sa position
          if pos_is_occupied(t,b) then -- si la position est dans la table ( donc le bloc est déja là )
            -- il faut changer le d_out du bloc precedent
            b = table.remove(t) -- recuperation du dernier bloc qu'on enleve de la table
            -- tant qu'il n'y a pas de possibilité de sortie
            while no_more_choice(b) do 
                b = table.remove(t) -- on recupère le dernier bloc
            end
            b:random_out()
            b:remove_direction(b.d_out)
            table.insert(t,b)
          else -- si la position est libre
            b:random_out() -- on choisit la d_out
            b:remove_direction(b.d_out)
            table.insert(t,b) -- et on ajoute le bloc dans la table 
          end
          if b.x == pos_arrive[1] and b.y == pos_arrive[2] then
            reach = true
          end
        else
          print("here we go !!!")
          parcours = copy(t)
        --   for _ ,v in pairs(parcours) do
        --     print(v.x, v.y)
        --   end
        --   love.window.close()
        end
    --end
end

function love.draw() -- dessine les éléments à chaques frames
     for i , v in pairs(t1) do -- pour chaque objet de la table (pour le decor)
        v:draw() -- lancer la fonction draw de l'objet ( celui ci est chargé plus haut )
    end
    for i , v in pairs(t) do -- pour chaque objet de la table (pour le parcours)
        -- v:draw() -- lancer la fonction draw de l'objet
         v:setImage(v.d_in..v.d_out) -- choisit l'image en fonction des 2 directions du bloc
         v:draw() -- dessine en procedurale
         -- v:draw2() -- dessine en images
    end
    -- dessine un rectangle rouge pour le dernier bloc
    love.graphics.push(all)
    love.graphics.setColor(1,0,0)
    love.graphics.translate( t[#t].x * t[#t].size - t[#t].size, t[#t].y * t[#t].size - t[#t].size) -- pose le bloc au bon endroit
    love.graphics.rectangle('fill',t[#t].x, t[#t].y , t[#t].size, t[#t].size, t[#t].size/10, t[#t].size/10)
    love.graphics.pop()

    -- dessine un rectangle vert pour le premier bloc
    love.graphics.push(all)
    love.graphics.setColor(0,1,0)
    love.graphics.translate( t[1].x * t[1].size - t[1].size, t[1].y * t[1].size - t[1].size) -- pose le bloc au bon endroit
    love.graphics.rectangle('fill',t[1].x, t[1].y , t[1].size, t[1].size, t[1].size/10, t[1].size/10)
    love.graphics.pop()

end

------------------------------------------------------------------
function HSL(h, s, l, a) -- Converts HSL to RGB. (input and output range: 0 - 255 --> 0 - 1)
	if s<=0 then return l,l,l,a end
	h, s, l = h/256*6, s/255, l/255
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m),(g+m),(b+m),a
end

function pos_is_occupied(table, bloc) -- return true if bloc is still on table
    is = false
    for i, v in pairs(table) do
        if v.x == bloc.x then
            if v.y == bloc.y then
                is = true 
            end
        end
    end
    return is
end

function count(table) -- compte les éléments d'une table
    local count = 0
    if table == nil  then
        count = -1
    end

    assert(type(table)== 'table', print("c'est pas une table"))
    for i, v in pairs(table) do
        count = count + 1
    end
    return count
end

function no_more_choice(bloc) -- return true if no more directions to choose
    local is = true
    for i, v in pairs(bloc.dirs) do
        if v ~='x' then
            is = false
        end
    end
    return is
end

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end




