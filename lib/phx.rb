require 'pathname'
require_relative "actions"

class Phx < Thor::Group
  include Thor::Actions
  include Actions
  add_runtime_options!

  argument :path
  class_option :phx_version, default: "1.6.11"

  source_root Pathname.new(__dir__).parent.join("templates", "phx")

  def setup
    self.path = Pathname.new(self.path).expand_path
    self.destination_root = path.to_s
  end

  def announce
    # say "Generating phx app at #{path}"
    say_error "Or it would if it was implemented!", :red
    raise SystemExit
  end

  def make_project_folder
    empty_directory(path)
  end

  def create_ignore_files
    template("gitignore", ".gitignore")
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

    inside ".elixir-ls-release" do
      create_symlink "run-tool", "language_server.sh"
    end
  end
end
