require 'h3'
require 'json'

MAX_RESOLUTION = 3

def process(h3, res)
  (lat, lng) = H3.to_geo_coordinates(h3)
  p h3, res, lng, lat
end

def jump_into(h3)
  res = H3.resolution(h3)
  process(h3, res)
  H3.children(h3, res + 1).each {|c|
    jump_into(c)
  } if res < MAX_RESOLUTION
end

H3.base_cells.each {|h3|
  jump_into(h3)
}
