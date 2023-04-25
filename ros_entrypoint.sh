#!/bin/bash
set -e

# setup ros environment
source "/opt/ros/melodic/setup.bash"
source "/catkin_ws/devel/setup.bash"
exec "$@"
