-- parcours principal du labyrinthe

require('switch')

local Parcours = {}
Parcours.start = {} -- Starting position on the grid
Parcours.start.x = 0
Parcours.start.y = 0
Parcours.last = {} -- Ending position on the grid
Parcours.last.x = 0
Parcours.last.y = 0
Parcours.width = 10 -- number of columns and raws
Parcours.height = 10
Parcours.blocSize = 100 -- size of each bloc


-- fonction pour initialiser le parcours
Parcours.init = function(self, start, last, w, h, size)
    self.start = start 
    self.last = last
    self.width = w 
    self.height = h 
    self.blocSize = size
end


