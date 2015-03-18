kt = __kyototycoon__
db = kt.db

function echo(inmap, outmap)

  for k, v in pairs(inmap) do
    outmap[k] = v
  end

  return kt.RVSUCCESS

end
