require 'pathname'
require_relative "actions"

class Rails < Thor::Group
  include Thor::Actions
  include Actions
  add_runtime_options!

  argument :path
  class_option :rails_version, default: "7.0.4"
  class_option :js, default: "esbuild"
  class_option :css, default: "tailwind"
  attr_reader :name

  source_root Pathname.new(__dir__).parent.join("templates", "rails")

  def setup
    self.path = Pathname.new(self.path).expand_path
    self.destination_root = path.to_s
    @name = Pathname.new(destination_root).basename.to_s
  end

  def announce
    say "Generating rails app at #{path}"
  end

  def make_project_folder
    empty_directory(path)
  end

  def create_ignore_files
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

    inside ".bin" do
      %w[rubocop solargraph standardrb].each do |filename|
        create_symlink "run-tool", filename
      end
    end
  end

  def setup_rubocop
    template("rubocop/rubocop.yml", ".rubocop.yml")

    empty_directory ".rubocop"
    %w[
      rubocop_rails.yml
      rubocop_rspec.yml
      rubocop_strict.yml
      rubocop_todo.yml
    ].each do |filename|
      template("rubocop/#{filename}", ".rubocop/.#{filename}")
    end
  end

  def rails_new
    template("Gemfile", "Gemfile")
    template("rails_new.rb", "rails_new.rb")

    inside path do
      run "/opt/dev-env/bin/dev build --pull rails"
      run_rails "bundle install"
      run_rails "rails new . -j #{options[:js]} -c #{options[:css]} --force --template=rails_new.rb"
    end

    remove_file "rails_new.rb"

    append_to_file(".gitignore") do
      <<~GITIGNORE

        /log
        /.log

        # Ignore application configuration
        /config/application.yml

        # tmp
        /tmp

        docker-compose.override.yml

        /yarn-error.log
        yarn-debug.log*
        .yarn-integrity
        .env
      GITIGNORE
    end
  end

  private

  def run(command, config = {})
    Bundler.with_clean_env do
      super
    end
  end

  def run_rails(command, config = {})
    command = "/opt/dev-env/bin/dev run --rm rails " + command
    run(command, config)
  end
end
