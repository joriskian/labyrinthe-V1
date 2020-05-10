-- essai metatable

Set = {}
    
function Set.new (t)
    local set = {}
    for _, l in ipairs(t) do set[l] = true end
    return set
end

function Set.union (a,b)
    local res = Set.new{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end

function Set.intersection (a,b)
    local res = Set.new{}
    for k in pairs(a) do
    res[k] = b[k]
    end
    return res
end
-- fonction pour imprimer les ensemble
function Set.tostring (set)
    local s = "{"
    local sep = ""
    for e in pairs(set) do
      s = s .. sep .. e
      sep = ", "
    end
    return s .. "}"
end
-- et le print
function Set.print (s)
print(Set.tostring(s))
end
-- maintenant nous voulons que l'operateur d'addition calcule l'union de 2 ensembles.
-- toutes les tables representant des ensembles doivent partager la même metatable qui definira comment elles reagissent à l'operateur d'addition.
Set.mt = {}    -- metatable pour les ensembles
