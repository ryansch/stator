require_relative "create_symlink"

module Actions
  def create_symlink(existing, destination, **config)
    action CreateSymlink.new(self, destination, existing, **config)
  end
  alias_method :add_symlink, :create_symlink
end
