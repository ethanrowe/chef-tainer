# Tainer cookbook

Chef cookbook for manipulation of docker containers via tainers gem

# Usage

## Docker

This cookbook does *nothing* about installing docker.  There are a variety of options for this and it's not for
this cookbook to decide how you'll handle it.

So the expectation is that, when using this cookbook, you're ensuring the presence of docker yourself.  No
communication happens with the docker API until converge time, when tainers resources run, so you can safely install/configure
docker within a chef run and expect the "tainer" resource to be perfectly happy so long as it comes later in the
resource collection.

## Tainer gem installation

The default recipe will, by default, install the "tainers" gem (at its latest version) as a chef_gem.

If you want to use tainers on your system, arguably the simplest way to get started is to put it in the run list.

However, for a longer-term configuration, you probably should harden your chef ruby configuration and use bundler
of whatever to manage the installation of the "tainers" gem.

## "tainer" resource

Check out the "tainers" gem, and the "docker-api" gem.

The "tainer" resource lets you provide a specification for a docker container; the `Tainers::Specification::ImagePuller`
class from the "tainers" gem provides the actual meat of creating that resource as necessary, pulling the image if needed.

The specification is expressed in terms that "tainers" understands, which is a mild extension of "docker-api", which
in turn works with the JSON data structures expected by docker itself.

### Creating a docker container

This will create a docker container using the "fluffy/bunnies:1.0" image, having some local bind points and with
a name prefix of "watership".  The rest of the container name is deterministically derived from the container
specification itself (which is the whole point of the "tainers" gem).

It will put that container name into a file for reference elsewhere.

    # tainer resource creates container as needed.
    container = tainer 'watership-container' do
                  specification 'prefix' => 'watership',
                                'Image' => 'fluffy/bunnies:1.0',
                                'HostConfig' => {
                                  'Binds' => [
                                    '/var/run/bunnies-state:/var/run',
                                    '/etc/bunnies/conf:/etc/bunnies'
                                  ]
                                }
                end
    
    # Now put the calculated name into a file for external reference
    file '/var/run/bunnie-container' do
      mode '0644'
      # The tainer resource's #tainer gives you access to the underlying Tainers::Specification::ImagePuller.
      content container.tainer.name
    end

The name of the container will only change if the specification changes, so `/var/run/bunnie-container` will change
at the same rate as the container definition itself.

If the container already exists, then the tainer resource does nothing, just like you would expect.

### Specification format

The specification given is converted to JSON and back to ruby structures, meaning that:
- hash-like things go to hashes
- array-like things go to arrays
- strings and numbers are fine
- symbols go to strings

This is a quick way of ensuring the specification data types are appropriate for use with the tainers functionality.

It also means that you can put a chef mash right in there and it ought to do the right thing.

# License

The MIT License (MIT)

Copyright (c) 2014 Ethan Rowe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

