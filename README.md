# MobileRobot — ROS 2 Jazzy

Curso de robótica móvil adaptado a **Ubuntu 24.04 Noble**, **ROS 2 Jazzy** y **Gazebo Harmonic**.
El historial y los recursos del [proyecto original](https://github.com/xXThanatosXx/MobileRobot) se conservan.

## Instalación

Instale Ubuntu 24.04 desde https://releases.ubuntu.com/noble/ y ejecute:

```bash
git clone https://github.com/xXThanatosXx/MobileRobot-Jazzy.git
cd MobileRobot-Jazzy
bash Scripts/ros2_install.sh
bash Scripts/install_ros_packages.sh
source /opt/ros/jazzy/setup.bash
printenv ROS_DISTRO
ros2 doctor --report
```

Los scripts comprueban Ubuntu Noble, instalan los paquetes oficiales y configuran rosdep.
Las bibliotecas Python se instalan con APT para respetar el entorno administrado de Ubuntu 24.04.

## Ramas del curso

| Rama | Contenido |
| --- | --- |
| main | Instalación y dependencias Jazzy |
| Clase-TurtleSim | Nodos, tópicos, servicios y simulación TurtleSim |
| Clase-URDFRobot | Modelo URDF, Xacro y RViz |
| Clase-robot-Gazebo | Gazebo Harmonic, ros_gz y gz_ros2_control |
| Clase-Control | Control diferencial en Python y C++ |
| Clase-Odometry / Odometry | Odometría y comunicación serial |
| SensorNoyse | Ruido en encoders y odometría |
| Clase-Imu | IMU simulada y puente Gazebo–ROS |
| Docker-Install | Copia original, excluida de la migración |
| RealRobot | Copia original, excluida de la migración |

Cambie de rama con `git switch NOMBRE_RAMA`. Cada rama conserva su práctica y ofrece comandos para Jazzy.
Construya cada rama en un espacio limpio: no reutilice `build/`, `install/` ni `log/` de Humble o de otra rama.
Las capturas y videos originales son referencias históricas; los comandos escritos y archivos fuente actualizados son la guía para Jazzy.

## Referencias

- [Instalación oficial Jazzy](https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html)
- [Gazebo Harmonic con ros2_control](https://control.ros.org/jazzy/doc/gz_ros2_control/doc/index.html)
- [Guía de migración](JAZZY_MIGRATION.md)
