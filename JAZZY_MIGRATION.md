# Migración a Jazzy

Destino: Ubuntu 24.04 Noble, ROS 2 Jazzy y Gazebo Harmonic.
Se conservaron los nombres de las ramas y el material docente original.
Docker-Install y RealRobot permanecen exactamente en sus commits originales.

- Instalación y dependencias APT para Jazzy; Python del sistema mediante APT.
- Gazebo Classic reemplazado por ros_gz_sim, ros_gz_bridge y gz_ros2_control.
- Mundo local con sistemas de física, creación de entidades, escenas e IMU.
- Puente de reloj e IMU hacia ROS; tiempo simulado en estado y odometría.
- Parámetros de ruedas tipados como float; orden de articulaciones por nombre en odometría Python.
- Configuración de ambos controladores: velocidad conjunta y diferencial (TwistStamped).
- Se retiraron build/install/log heredados; reconstruir desde src.
- Videos y capturas originales pueden mostrar Humble; seguir los comandos actualizados.

Referencias: https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
 y https://control.ros.org/jazzy/doc/gz_ros2_control/doc/index.html
