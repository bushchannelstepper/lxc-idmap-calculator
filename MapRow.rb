class MapRow
  def initialize(id_type, id_in_container, id_on_host, range_length)
    @id_type = id_type.chars.first
    @id_in_container = id_in_container
    @id_on_host = id_on_host 
    @range_length = range_length
  end
  
  def render
    "lxc.idmap: #{@id_type} #{@id_in_container} #{@id_on_host} #{@range_length}"
  end
  
  def get
    [ @id_type, @id_in_container, @id_on_host, @range_length ]
  end
  
  def get_id_type
    @id_type
  end
  
  def get_id_in_container
    @id_in_container
  end
  
  def get_id_on_host
    @id_on_host
  end
  
  def get_range_length
    @range_length
  end
end