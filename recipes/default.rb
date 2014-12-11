installs = node['tainer']['install']

if installs['chef']
  chef_gem "tainers" do
    action :install
  end
end

if installs['system']
  gem_package "tainers" do
    action :install
  end
end

