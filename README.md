## Entorno ROS 2 Jazzy

Esta práctica usa Ubuntu 24.04 Noble y ROS 2 Jazzy. Las capturas y videos originales son referencias históricas.
Instale primero las dependencias mediante los scripts de la rama `main`.

```bash
source /opt/ros/jazzy/setup.bash
git clone --branch Clase-Imu --single-branch https://github.com/xXThanatosXx/MobileRobot-Jazzy.git
cd MobileRobot-Jazzy/difrobot_ws
rosdep install --from-paths src --ignore-src --rosdistro jazzy -y
colcon build --symlink-install
source install/setup.bash
```

### Simulación en Jazzy

En terminales separadas, cargue `/opt/ros/jazzy/setup.bash` y el `install/setup.bash` de este workspace:

```bash
ros2 launch difrobot_description gazebo.launch.py
```

```bash
ros2 launch difrobot_controller controller.launch.py use_python:=true
```

```bash
ros2 topic pub --use-sim-time --rate 10 /difrobot_controller/cmd_vel geometry_msgs/msg/TwistStamped "{header: auto, twist: {linear: {x: 0.02}, angular: {z: 0.0}}}"
```

Para usar el controlador diferencial estándar: `use_simple_controller:=false`.
El puente publica `/clock` y, en la rama IMU, `/imu`. Los nodos de odometría usan tiempo simulado.
En un entorno sin pantalla puede iniciar el servidor con `gz_args:='-r -s <ruta-absoluta>/worlds/difrobot.sdf'`.


# Simulación Imu 

La IMU (Inertial Measurement Unit) es un sensor esencial en robótica, utilizado para medir la velocidad angular y la aceleración lineal de un robot en los tres ejes (X, Y, Z). Este sensor proporciona datos fundamentales para entender la orientación, inclinación y movimiento del robot, lo que es crucial en aplicaciones como la navegación autónoma y el control de estabilidad.

- Velocidad angular (giroscopio): La tasa de rotación alrededor de los ejes X, Y y Z. (rad/s).
- Aceleración lineal (acelerómetro): La aceleración a lo largo de los mismos ejes, lo cual puede incluir la gravedad. (m/s²).

Estos datos se utilizan para monitorear el estado dinámico del robot durante la simulación, permitiendo medir cómo el robot se mueve y se inclina mientras interactúa con su entorno en Gazebo.

## Ejecutar el Nodo
```bash
ros2 launch difrobot_description gazebo.launch.py
```
```bash
ros2 topic list
```
```bash
ros2 topic echo /imu/out
```

```bash
ros2 run plotjuggler plotjuggler
```

```bash
ros2 launch difrobot_controller controller.launch.py use_python:=true

```


```bash
ros2 topic pub --use-sim-time --rate 10 /difrobot_controller/cmd_vel geometry_msgs/msg/TwistStamped "{header: auto, twist: {linear: {x: 0.02}, angular: {z: 0.0}}}"
```




### Código Python


- difrobot_gazebo.xacro

```xml
  <!-- IMU -->
  <gazebo reference="imu_link">
    <sensor name="imu" type="imu">
        <always_on>true</always_on>
        <update_rate>100</update_rate>
        <imu>
          <angular_velocity>
            <x>
              <noise type="gaussian">
                <mean>0.0</mean>
                <stddev>2e-4</stddev>
              </noise>
            </x>
            <y>
              <noise type="gaussian">
                <mean>0.0</mean>
                <stddev>2e-4</stddev>
              </noise>
            </y>
            <z>
              <noise type="gaussian">
                <mean>0.0</mean>
                <stddev>2e-4</stddev>
              </noise>
            </z>
          </angular_velocity>
          <linear_acceleration>
            <x>
              <noise type="gaussian">
                <mean>0.0</mean>
                <stddev>1.7e-2</stddev>
              </noise>
            </x>
            <y>
              <noise type="gaussian">
                <mean>0.0</mean>
                <stddev>1.7e-2</stddev>
              </noise>
            </y>
            <z>
              <noise type="gaussian">
                <mean>0.0</mean>
                <stddev>1.7e-2</stddev>
              </noise>
            </z>
          </linear_acceleration>
        </imu>
        <topic>/imu</topic>
        <gz_frame_id>imu_link</gz_frame_id>
    </sensor>
  </gazebo>
```
- difrobot.urdfxacro
```xml
<!-- Sensor Imu -->
  <link name="imu_link">
    <inertial>
      <origin xyz="-0.00552433659106688 0.000168210391520346 0.000514000497342681" rpy="0 0 0" />
      <mass value="0.000528415362211671" />
      <inertia ixx="1.46176048428261E-08" ixy="1.40015117949421E-10" ixz="-1.99633872937403E-12"
               iyy="8.59662482954888E-09" iyz="7.52375112767959E-12"
               izz="2.30279421279312E-08" />
    </inertial>
    <visual>
      <origin xyz="0 0 0" rpy="0 0 0" />
      <geometry>
        <mesh filename="package://difrobot_description/meshes/imu_link.STL" />
      </geometry>
      <material name="">
        <color rgba="0.792156862745098 0.819607843137255 0.933333333333333 1" />
      </material>
    </visual>

    <collision>
      <origin xyz="0 0 0" rpy="0 0 0" />
      <geometry>
        <mesh filename="package://difrobot_description/meshes/imu_link.STL" />
      </geometry>
    </collision>
  </link>
  
  <joint name="imu_joint" type="fixed">
    <origin xyz="0 0 0.0698986241758014" rpy="0 0 0" />
    <parent link="base_link" />
    <child link="imu_link" />
    <axis xyz="0 0 0" />
  </joint>
```

### Archivo CMAKE

```c++
cmake_minimum_required(VERSION 3.8)
project(difrobot_description)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)


install(
  DIRECTORY meshes urdf models launch rviz
  DESTINATION share/${PROJECT_NAME}

)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  set(ament_cmake_copyright_FOUND TRUE)
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
```
- controller.launch.py

```xml
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>difrobot_description</name>
  <version>0.0.0</version>
  <description>TODO: Package description</description>
  <maintainer email="faustoandresescobar@gmail.com">ros</maintainer>
  <license>TODO: License declaration</license>

  <buildtool_depend>ament_cmake</buildtool_depend>

  <exec_depend>robot_state_publisher</exec_depend>
  <exec_depend>joint_state_publisher_gui</exec_depend>
  <exec_depend>rviz2</exec_depend>
  <exec_depend>ros2launch</exec_depend>


  <test_depend>ament_lint_auto</test_depend>
  <test_depend>ament_lint_common</test_depend>

  <export>
    <build_type>ament_cmake</build_type>
  </export>
</package>

```