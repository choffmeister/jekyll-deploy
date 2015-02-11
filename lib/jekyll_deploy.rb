class DeployCommand < Jekyll::Command
  class << self
    def init_with_program(prog)
      prog.command(:deploy) do |c|
        c.syntax "deploy"
        c.description 'Deploys the Jekyll site.'

        c.action do |args, options|
          options["serving"] = false
          DeployCommand.process(options)
        end
      end
    end

    def process(options)
        clean_build(options)

        options = configuration_from_options(options)
        destination = options['destination']
        site = Jekyll::Site.new(options)
        settings = site.config['deployment']

        case settings['type']
          when 'git'
            deploy_git(destination, settings['repo'], settings['branch'])
          when 'rsync'
            deploy_rsync(destination, settings['host'], settings['user'], settings['directory'])
          else
            raise "Unknown deployment type #{settings['type']}"
        end
    end

    def clean_build(options)
      options = configuration_from_options(options)
      destination = options['destination']

      if File.directory? destination
        FileUtils.rm_rf(destination)
      end

      Jekyll::Commands::Build.process(options)
    end

    def deploy_git(site_destination, repo, branch)
      run_shell([
        "git init",
        "git add .",
        "git commit -m \"Build\"",
        "git remote add origin \"#{repo}\"",
        "git push origin master:#{branch} --force"
      ], site_destination)
    end

    def deploy_rsync(site_destination, host, user, directory)
      site_destination << '/' unless site_destination.end_with?('/')
      directory << '/' unless directory.end_with?('/')

      run_shell("rsync -avr --delete #{site_destination} #{user}@#{host}:#{directory}", Dir.pwd)
    end

    def run_shell(cmds, dir)
      success = true
      cmds = [cmds] unless cmds.is_a? Array
      pwd_old = Dir.pwd

      Dir.chdir(dir)
      cmds.each { |cmd|
        if success and not system(cmd)
          success = false
        end
      }
      Dir.chdir(pwd_old)

      success
    end
  end
end
