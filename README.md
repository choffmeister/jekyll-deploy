# jekyll_deploy

Adds a deploy command to your Jekyll project.

## Usage

~~~ ruby
# Gemfile
group :jekyll_plugins do
  gem 'jekyll_deploy', :git => 'https://github.com/choffmeister/jekyll_deploy.git', :branch => 'master'
end
~~~

~~~ yaml
# _config.yml

# example for github pages
deployment:
  type: git
  repo: git@github.com:choffmeister/jekyll_deploy.git
  branch: gh-pages

# example for rsync
deployment:
  type: rsync
  host: myhost.com
  user: username
  directory: /var/www
~~~

Now you can run `jekyll deploy` to clean and rebuild your Jekyll site and force push it to your GitHub pages for example.
