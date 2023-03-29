class CreateSymlink < Thor::Actions::EmptyDirectory
  attr_reader :existing

  def initialize(base, destination, existing, verbose: true)
    @existing = existing
    config = {
      verbose: verbose
    }
    super(base, destination, config)
  end

  def invoke!
    invoke_with_conflict_check do
      require "fileutils"
      ::FileUtils.ln_sf(existing, destination)
    end
    given_destination
  end

  def exists?
    Pathname.new(destination).symlink?
  end

  def identical?
    exists? && Pathname.new(destination).readlink == Pathname.new(existing)
  end

  protected

  # Now on conflict we check if the link is identical or not.
  #
  def on_conflict_behavior(&block)
    if identical?
      say_status :identical, :blue
    else
      options = base.options.merge(config)
      force_or_skip_or_conflict(options[:force], options[:skip], &block)
    end
  end

  # If force is true, run the action, otherwise check if it's not being
  # skipped. If both are false, show the file_collision menu, if the menu
  # returns true, force it, otherwise skip.
  #
  def force_or_skip_or_conflict(force, skip, &block)
    if force
      say_status :force, :yellow
      yield unless pretend?
    elsif skip
      say_status :skip, :yellow
    else
      say_status :conflict, :red
      force_or_skip_or_conflict(force_on_collision?, true, &block)
    end
  end

  # Shows the file collision menu to the user and gets the result.
  #
  def force_on_collision?
    base.shell.file_collision(destination)
  end
end
