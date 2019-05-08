#
#
#
REPOSITORY="us.icr.io/docker_cobol/hello_world"
TAG="v1"
IMAGE_NAME="us.icr.io/docker_cobol/hello_world:v1"

#
# This test makes sure you DON'T have 12.04 Ubuntu in your local registry, it's out
# of date and you shouldn't be using it.
#
describe docker.images.where { repository == 'ubuntu' && tag == '12.04' } do
  it { should_not exist }
end

#
# This test makes sure you have the demo build in your local registry.
#
describe docker.images.where { repository == "#{REPOSITORY}" && tag == "#{TAG}" } do
  it { should exist }
end

#
# This test makes sure you have the demo build does what we expect.
#
describe docker_container(name: "#{IMAGE_NAME}") do
  its('command') { should eq nil }
  its('id') { should_not eq '' }
end

#
# This test runs the container locally and verifies that the output is what we expect.
#
describe command("docker run #{IMAGE_NAME}") do
  its('stdout') { should eq "Hello world!\n" }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end
