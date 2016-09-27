

class PolyTreeNode

    attr_reader :parent, :children, :value

    def initialize(value)
      @parent = nil
      @children = []
      @value = value
    end

    def parent=(node)
      @parent._children.delete(self) unless @parent.nil?
      @parent = node

      unless @parent.nil?
        @parent._children << self unless node.children.include?(self)
      end
    end

    def add_child(node)
      node.parent = (self)
    end

    def remove_child(node)
      raise "Error no child" unless self.children.include?(node)
      node.parent = (nil) if self.children.include?(node)
    end

    def dfs(target)
      return self if @value == target

      self.children.each do |child|
          result = child.dfs(target)
          return result unless result.nil?
      end
      nil
    end

    def bfs(target)
      queue = [self]

      until queue.empty?
        current_node = queue.shift
        return current_node if current_node.value == target
        queue += current_node.children
      end
      nil
    end

    protected

    def _children
      @children
    end

end
