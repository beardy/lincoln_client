class Color

  # convert hex (000000 - FFFFFF) to RGB (0-1, 0-1, 0-1)
  def self.hex_to_rgb(h)
	# calculate rgb
	r = h[0..1].hex / 255.0
	g = h[2..3].hex / 255.0
	b = h[4..5].hex / 255.0
	
	# return red, greed, blue
	[r, g, b]
  end
  
  # convert RGB (0-1, 0-1, 0-1) to hex (000000 - FFFFFF)
  def self.rgb_to_hex(rgb)
	# calculate hex
	h = sprintf("%02x%02x%02x", *rgb.map { |c| (c * 255).round })
	
	# return hex
	h
  end
  
  # convert RGB (0-1, 0-1, 0-1) to HSL (0-360, 0-1, 0-1)
  def self.rgb_to_hsl(rgb)
	max = rgb.max
	min = rgb.min
	
	# calculate hue
	h = case
	  when min == max: 0
	  when max == rgb[0]: (60 * (rgb[1] - rgb[2]) / (max - min) + 360) % 360
	  when max == rgb[1]: (60 * (rgb[2] - rgb[0]) / (max - min) + 120)
	  when max == rgb[2]: (60 * (rgb[0] - rgb[1]) / (max - min) + 240)
	end
	
	# calculate light
	l = 0.5 * (max + min)
	
	# calculate saturation
	s = case
	  when min == max: 0
	  when l <= (1.0/2.0):	(max - min) / (max + min)
	  when l > (1.0/2.0):	(max - min) / (2 - max - min)
	end
	
	# return hue, saturation, light
	[h, s, l]
  end
  
  # convert HSL (0-360, 0-1, 0-1) to RGB (0-1, 0-1, 0-1)
  def self.hsl_to_rgb(hsl)
	# calculate temp values
	q = case
	  when hsl[2] < (1.0/2.0):		hsl[2] * (1 + hsl[1])
	  when hsl[2] >= (1.0/2.0):	hsl[2] + hsl[1] - (hsl[2] * hsl[1])
	end
	
	p = 2 * hsl[2] - q
	
	# normalize h
	h_k = hsl[0] / 360.0
	
	# calculate r, g, b
	rgb = [h_k + (1.0/3.0), h_k, h_k - (1.0/3.0)]
	rgb.collect! { |c| c < 0 ? c + 1 : (c > 1 ? c - 1 : c) }
	rgb.collect! do |c| 
	  case 
		when c < (1.0/6.0):	p + (q - p) * 6 * c
		when c < (1.0/2.0):	q
		when c < (2.0/3.0):	p + (q - p) * 6 * (2.0/3.0 - c)
		else 						p
	  end
	end
	
	# return red, green, blue
	rgb
  end
  
end
