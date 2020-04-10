##############################################################################
# Copyright 2019 IBM Corp. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
##############################################################################
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
# This test runs the container locally and verifies that the output is what we expect.
#
describe command("docker run #{IMAGE_NAME}") do
  its('stdout') { should eq "Hello world!\n" }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end
