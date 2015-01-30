action :create do
  if ! create_with_retry
    Chef::Log.info "#{ new_resource } already exists (container '#{ new_resource.tainer.name }')."
    new_resource.updated_by_last_action false
  else
    Chef::Log.info "Create #{ new_resource } (container '#{ new_resource.tainer.name }')."
    new_resource.updated_by_last_action true
  end
end

def create_with_retry
  tries = 3
  begin
   # Tainers::Specification#create will return true if it creates a container, false otherwise.
   # It won't try to create if it sees that it already exists.
   container = new_resource.tainer.create
  rescue Docker::Error::NotFoundError => e
    tries -= 1
    Chef::Log.info "Exception thrown: #{e.message}, #{tries} tries left"
    sleep 1
    retry unless tries < 1
  end
  container
end

def load_current_resource
  # Tainers::Specification manages the state of the container over the docker API.
  # Thus, there's no distinction between the current and new resource; they come from
  # the same specification settings.
  # However, in the event that there are side effects on either of these guys outside my control,
  # I'll make a redundant one here.
  @current_resource = Chef::Resource::Tainer.new(new_resource.name)
  @current_resource.specification new_resource.specification
end

