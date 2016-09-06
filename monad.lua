------------------------------------------------------------------------------------
-- The MIT License (MIT)
-- 
-- Copyright (c) 2016 Raphael Amorim
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
------------------------------------------------------------------------------------
 
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
