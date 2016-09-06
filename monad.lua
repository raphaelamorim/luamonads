function IDENTITY()
    return function(value)
           local monad = {}
           monad.bind = function(func)
                            return func(value)
                        end
            return monad 
           end  
end

function AJAX()
    local prototype = {}
    local unit = setmetatable({[0] = 1},{ __call = function(self, value, ...)
                     local monad = { bind = function(self, func, ...) return func(value, ...) end}
                     return setmetatable(monad, {__index = prototype, __call = prototype})
                 end
    })
		
    function unit:lift(name, func)
        prototype[name] = function(self, ...)                     
                              return unit(self:bind(func, ...))
                          end
        return self
    end
    
    return unit
end

function MAYBE(modifier)
    local prototype = {}
    local unit = setmetatable({[0] = 1},{ __call = function(self, value, ...)
                     local monad = { bind = function(self, func, ...) return func(value, ...) end}
                     setmetatable(monad, {__index = prototype, __call = prototype})
                     if type(modifier) == 'function' then modifier(monad, value) end  
                     return monad
                 end 
    }) 
    return unit
end

-- testing IDENTITY monad

local Identity = IDENTITY()
local monad = Identity("Indentity String")
monad.bind(print)

-- testing AJAX monad

local Ajax = AJAX():lift("print", print):lift("test", print )
monad = Ajax("This is the Ajax monad in action") 
monad:print()
monad:test()

-- testing MAYBE monad

local Maybe = MAYBE(function(monad, value)
    if value == nil then
        monad.is_null = true
        monad.bind = function()
            return monad
        end
    end    
end)

local monad = Maybe(nil)
monad.bind(print)
	
monad = Maybe(true)
monad:bind(print)
	
monad = Maybe(false)
monad:bind(print)
