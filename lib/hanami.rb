require 'pathname'
require_relative "actions"

class Hanami < Thor::Group
  include Thor::Actions
  include Actions
  add_runtime_options!

  argument :path
  class_option :hanami_version, default: "2.0.3"
  attr_reader :name

  source_root Pathname.new(__dir__).parent.join("templates", "hanami")

  def setup
    self.path = Pathname.new(self.path).expand_path
    self.destination_root = path.to_s
    @name = Pathname.new(destination_root).basename.to_s
  end

  def announce
    say "Generating hanami app at #{path}"
  end

  def make_project_folder
    empty_directory(path)
  end

  def create_ignore_files
    # template("gitignore", ".gitignore")
    template("dockerignore", ".dockerignore")
    template("ignore", ".ignore")
  end

  def create_docker_files
    %w[
      Dockerfile
      compose.yml
      development.yml
      Deskfile
    ].each do |filename|
      template(filename, filename)
    end

    inside "docker" do
      %w[
        chown-dirs.sh
        entrypoint.sh
        irbrc
        tools-entrypoint.sh
      ].each do |filename|
        template(filename, filename)
        if filename.end_with?(".sh")
          chmod filename, 0755
        end
      end
    end
  end

  def setup_tools
    empty_directory ".bin"
    template("run-tool", ".bin/run-tool")
    chmod ".bin/run-tool", 0755
  end

  def tool_symlinks
    inside ".bin" do
      %w[solargraph standardrb].each do |filename|
        create_symlink "run-tool", filename
      end
    end
  end

  def hanami_new
    template("Gemfile", "Gemfile")

    inside path do
      run "/opt/dev-env/bin/dev build --pull hanami"
      run_hanami "bundle install"
      run_hanami "hanami new #{name}"
    end

    inside path + name do
      run "mv * .."
    end

    inside path do
      remove_dir name
    end
  end

  private

  def run(command, config = {})
    Bundler.with_clean_env do
      super
    end
  end

  def run_hanami(command, config = {})
    command = "/opt/dev-env/bin/dev run --rm hanami " + command
    run(command, config)
  end
end
