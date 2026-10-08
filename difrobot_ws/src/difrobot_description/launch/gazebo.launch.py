import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, SetEnvironmentVariable
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import Command, LaunchConfiguration
from launch_ros.actions import Node
from launch_ros.parameter_descriptions import ParameterValue


def generate_launch_description():
    share = get_package_share_directory('difrobot_description')
    gz_share = get_package_share_directory('ros_gz_sim')
    resources = os.pathsep.join(filter(None, [os.path.dirname(share),
        os.path.join(share, 'models'), os.environ.get('GZ_SIM_RESOURCE_PATH', '')]))
    description = ParameterValue(Command(['xacro ', LaunchConfiguration('model')]), value_type=str)
    return LaunchDescription([
        DeclareLaunchArgument('model', default_value=os.path.join(share, 'urdf', 'difrobot.urdf.xacro')),
        DeclareLaunchArgument('gz_args', default_value=['-r ', os.path.join(share, 'worlds', 'difrobot.sdf')]),
        SetEnvironmentVariable('GZ_SIM_RESOURCE_PATH', resources),
        IncludeLaunchDescription(PythonLaunchDescriptionSource(os.path.join(gz_share, 'launch', 'gz_sim.launch.py')),
            launch_arguments={'gz_args': LaunchConfiguration('gz_args')}.items()),
        Node(package='robot_state_publisher', executable='robot_state_publisher',
            parameters=[{'robot_description': description, 'use_sim_time': True}]),
        Node(package='ros_gz_sim', executable='create',
            arguments=['-name', 'difrobot', '-topic', 'robot_description', '-z', '0.05'], output='screen'),
        Node(package='ros_gz_bridge', executable='parameter_bridge',
            arguments=['/clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock',
                       '/imu@sensor_msgs/msg/Imu[gz.msgs.IMU'],
            parameters=[{'use_sim_time': True}], output='screen'),
    ])
