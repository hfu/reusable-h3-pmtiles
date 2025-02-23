require 'h3'
require 'json'

MAX_RESOLUTION = 9
DELTA0 = 10.0 # margin at H3 resolution 0
LAT1 = 60.0
LAYER = 'h3'

def dump(min, max, f)
  f[:tippecanoe][:minzoom] = min[f[:properties][:res]]
  f[:tippecanoe][:maxzoom] = max[f[:properties][:res]]
  print "#{JSON.dump(f)}\n"
end

def zone1(f)
  dump({
    2 => 0, 3 => 1, 4 => 2, 5 => 4, 
    6 => 5, 7 => 7, 8 => 8, 9 => 10
  }, {
    2 => 0, 3 => 1, 4 => 3, 5 => 4,
    6 => 6, 7 => 7, 8 => 9, 9 => 11
  }, f)
end

def zone0(f)
  dump({
    1 => 0, 2 => 1, 3 => 2, 4 => 4, 5 => 5,
    6 => 7, 7 => 8, 8 => 10, 9 => 11
  }, {
    1 => 0, 2 => 1, 3 => 3, 4 => 4, 5 => 6,
    6 => 7, 7 => 9, 8 => 10, 9 => 11
  }, f)
end

def process(h3, res)
  (lat, lng) = H3.to_geo_coordinates(h3)
  coords = H3.to_boundary(h3)
  coords.size.times {|i| coords[i] = coords[i].reverse}
  coords.push(coords[0])
  f = {
    :type => 'Feature',
    :geometry => {
      :type => 'Polygon',
      :coordinates => [coords]
    },
    :properties => {
      :h3 => h3,
      :res => res
    },
    :tippecanoe => {
      :layer => LAYER,
    }
  }
  zone1(f) if lat.abs > LAT1 - DELTA0 / 2 ** res and res >= 2
  zone0(f) if lat.abs < LAT1 + DELTA0 / 2 ** res and res >= 1
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
