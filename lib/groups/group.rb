class Group
  attr_accessor :children, :data

  def initialize(data = nil)
    @data = data
    @children = {}
  end

  def insert(group_data)
    if group_data["ancestry"].nil? || group_data["ancestry"].empty?
      group = @children[group_data["guid"]]
      if group
        group.data = group_data
      else
        group = Group.new(group_data)
      end
      @children[group_data["guid"]] = group
    elsif group_data["ancestry"] && group_data["ancestry"].any?
      ancestor_guid = group_data["ancestry"].last["guid"]
      ancestor = @children[ancestor_guid]
      ancestor ||= Group.new

      ancestor.insert(pop_ancestor(group_data))
      @children[ancestor_guid] = ancestor
    else
      raise "unhandled group, #{group_data}"
    end
  end

  def guids_including_descedants
    return [@data["guid"]] if children.empty?
    (children.values.map{ |child| child.guids_including_descedants } + [guid]).flatten.compact
  end

  def guid
    return nil if @data.nil?
    @data["guid"]
  end

  def get(group_guid)
    return self if self.data && self.data["guid"] == group_guid
    return nil if children.empty?
    children.values.collect { |children| children.get(group_guid) }.flatten.compact.first
  end
  
  private

  def pop_ancestor(group_data)
    group_data["ancestry"].pop
    group_data
  end
end
