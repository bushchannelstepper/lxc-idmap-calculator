require './MapRow'

class LxcIdMap
  ##
  # A UID or GID map generator utility for unprivileged LXC containers
  
  def initialize(id_type, ids_input, offset=100000)
    @map = []
    @id_type = id_type.chars.first
    @offset = offset 
    @id_list = parse_input ids_input
    
    build_map
  end
  
  def render
    render_lxc
    render_subid
  end
  
  def render_lxc
    @map.each { |map_row|
      puts map_row.render
    }
  end
  
  def render_subid
    @id_list.each { |range|
      id_on_host, range_len = parse_range range
      puts "root:#{id_on_host}:#{range_len}"
    }
  end
  
  def get_map
    @map
  end
  
  def parse_input(ids_input)
    # take the given input and sort into uid/gid ranges
    ids_input.split(' ').sort! {
      |a, b| a.split('-').first.to_i <=> b.split('-').first.to_i
    }.each { |token| parse_range token }
  end

  def parse_range(token)
    range = token.split('-')
    id = range.first.to_i
    range_top = range.last.to_i

    if id > range_top then
      puts "Range #{range.join('-')} looks arse backward"
      exit 1
    end
  
    range_length = range_top - id + 1 

    [id, range_length]
  end
  
  def build_map
    # create a idmap table from given input
    
    @map = build_map_fill_defaults build_map_core
  end
  
  def build_map_core
    # generate transposed idmap table entries for our given data less default host mappings

    core_map = []

    @id_list.each { |id_range|
      id_in_container, range_length = parse_range id_range
      core_map << MapRow.new(@id_type,
                         id_in_container,
                         id_in_container, # only same uid# mapping for now
                         range_length)
    }
    
    core_map
  end
  
  def build_map_fill_defaults(core_map)
    # fill the gaps in the idmap table between our custom mappings with default ones
    # the row we build goes in front of the existing row, which we glean stuff from
    
    full_map = []
    
    core_map.each_with_index { |map_row, i|
      if map_row == core_map.first then # handle first row
        skip if map_row.get_id_in_container == 0   # no padding to do
        
        full_map << MapRow.new(@id_type,
                               0,
                               @offset,
                               map_row.get_id_in_container) # range goes to next id
                               
      end
      
      # add in the transpose row from our input
      full_map << map_row
      
      # middle row
      if map_row != core_map.last then
        full_map << MapRow.new(@id_type,
                               map_row.get_id_in_container + map_row.get_range_length,
                               map_row.get_id_in_container + map_row.get_range_length + @offset,
                               core_map[i+1].get_id_in_container - map_row.get_id_in_container - 1)
      end
    }
    
    # last row
    full_map << MapRow.new(@id_type,
                           full_map.last.get_id_in_container + full_map.last.get_range_length,
                           full_map.last.get_id_in_container + full_map.last.get_range_length + @offset,
                           65536 - sum_range(full_map))
    
    full_map
  end
  
  def sum_range(map)
    sum = 0
    map.each { |map_row|
      sum += map_row.get_range_length
    }
    
    sum
  end
end
