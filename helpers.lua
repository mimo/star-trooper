
topositive = function (number)
  if number > 1 then return number else return 1 end
end

constrain = function (number, min, max)
  if number < min then return min
  elseif number > max then return max
  else return number
  end
end
