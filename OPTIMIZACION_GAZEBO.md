# Optimización de Gazebo Harmonic y corrección del parpadeo

Esta guía corresponde a Ubuntu 24.04, ROS 2 Jazzy y Gazebo Harmonic (Gazebo Sim 8).

## Ajustes del mundo incluidos en las ramas de simulación

En `difrobot_ws/src/difrobot_description/worlds/difrobot.sdf` se aplicaron:

```xml
<physics name="physics" type="ignored">
  <max_step_size>0.002</max_step_size>
  <real_time_factor>1</real_time_factor>
</physics>
```

La luz `sun` tiene ahora:

```xml
<cast_shadows>false</cast_shadows>
```

El paso pasó de 1 ms a 2 ms: se solicitan menos pasos físicos por segundo simulado. Las sombras desactivadas reducen trabajo gráfico. Estos ajustes no garantizan una mejora concreta en todos los equipos. El objetivo de tiempo real sigue siendo 1; no se garantiza que el equipo lo alcance.

Los cambios están en `Clase-robot-Gazebo`, `Clase-Control`, `Clase-Odometry`, `Odometry`, `SensorNoyse` y `Clase-Imu`. `main`, `Clase-TurtleSim` y `Clase-URDFRobot` no contienen este mundo. `Docker-Install` y `RealRobot` permanecen excluidas.

Si el robot empieza a vibrar, atravesar superficies o perder estabilidad, vuelva a `<max_step_size>0.001</max_step_size>` y reinicie la simulación. Un paso mayor puede reducir la precisión. La simplificación de colisiones STL requiere medir la geometría y es una mejora posterior; no se cambiaron las colisiones en esta optimización.

## Preparar y lanzar una rama

Si aún no tiene el repositorio:

```bash
git clone https://github.com/xXThanatosXx/MobileRobot-Jazzy.git
```

Desde su copia local, seleccione la rama deseada (ejemplo: IMU):

```bash
cd MobileRobot-Jazzy
git switch Clase-Imu
git pull --ff-only
cd difrobot_ws
source /opt/ros/jazzy/setup.bash
colcon build --symlink-install --packages-select difrobot_description
source install/setup.bash
ros2 launch difrobot_description gazebo.launch.py
```

El comando de compilación supone que las demás dependencias del workspace ya se compilaron. En un workspace nuevo, instale dependencias con rosdep y ejecute `colcon build --symlink-install` para compilar todos los paquetes. Use un workspace limpio al cambiar entre ramas del curso.

## Probar Ogre para corregir el parpadeo

Cierre la simulación con Ctrl+C antes de probar otra opción; evite dejar dos simulaciones activas.
Desde `difrobot_ws`, con el entorno ROS y el workspace cargados:

```bash
ros2 launch difrobot_description gazebo.launch.py \
  gz_args:="-r --render-engine ogre $(ros2 pkg prefix --share difrobot_description)/worlds/difrobot.sdf"
```

Ogre es una alternativa a Ogre2 ante incompatibilidades gráficas, especialmente en máquinas virtuales. Cambie una opción por vez y observe el resultado.

## Dejar Ogre como motor gráfico predeterminado para su usuario

Esto configura la ventana de Gazebo Harmonic, sin modificar cada proyecto ni los archivos instalados en `/opt/ros`.

1. Cierre Gazebo. Si nunca lo ha abierto, ejecute `gz sim` una vez y ciérrelo para que se cree la configuración de usuario.
2. Haga una copia de respaldo si aún no existe:

```bash
cp -n ~/.gz/sim/8/gui.config ~/.gz/sim/8/gui.config.bak
nano ~/.gz/sim/8/gui.config
```

3. Dentro del plugin `MinimalScene` (vista 3D), cambie:

```xml
<engine>ogre2</engine>
```

por:

```xml
<engine>ogre</engine>
```

4. Guarde con Ctrl+O, Enter y salga con Ctrl+X. Reinicie Gazebo normalmente:

```bash
ros2 launch difrobot_description gazebo.launch.py
```

No necesita recompilar ni reiniciar el PC para este cambio de configuración. Se aplica a la interfaz gráfica de los proyectos que usan la configuración predeterminada de su usuario. Un mundo con su propia configuración GUI, una opción `--gui-config` o un motor indicado explícitamente puede reemplazarla. No modifica el motor de los sensores gráficos del servidor. Para seleccionar el motor del servidor y de la ventana en una ejecución use `--render-engine ogre` como en el ejemplo anterior.

Para restaurar la configuración, cierre Gazebo y ejecute:

```bash
cp ~/.gz/sim/8/gui.config.bak ~/.gz/sim/8/gui.config
```

## Si el parpadeo continúa

Pruebe primero desactivar DRI3 solo para esa ejecución:

```bash
LIBGL_DRI3_DISABLE=1 ros2 launch difrobot_description gazebo.launch.py
```

Otra prueba es el renderizado por software:

```bash
LIBGL_ALWAYS_SOFTWARE=1 ros2 launch difrobot_description gazebo.launch.py
```

Si el problema desaparece con renderizado por software, apunta al controlador gráfico o a la aceleración de la máquina virtual. Este modo puede ser más lento: úselo como diagnóstico o solución temporal. Las variables anteriores solo afectan esa ejecución; no se agregan automáticamente a `.bashrc`.

Si usa Wayland y encuentra errores de Qt/OpenGL, pruebe:

```bash
QT_QPA_PLATFORM=xcb ros2 launch difrobot_description gazebo.launch.py
```

## Comprobar el resultado

- Pause la simulación: si sigue parpadeando, revise gráficos o superficies superpuestas; si tiembla únicamente con la física activa, revise contactos, colisiones e inercias.
- Compruebe que no haya dos robots en el mismo lugar ni dos superficies coplanares, por ejemplo dos pisos.
- Observe el factor de tiempo real y la fluidez de la ventana antes y después, con el mismo mundo y carga.
- Desde otra terminal con los mismos entornos cargados, compruebe que los controladores y tópicos siguen activos:

```bash
ros2 control list_controllers
ros2 topic hz /clock
```

En la rama IMU puede comprobar también `/imu`; con el controlador activo, `/joint_states` y `/difrobot_controller/odom` según el modo usado.

## Referencias

- [Solución de problemas de Gazebo Harmonic](https://gazebosim.org/docs/harmonic/troubleshooting/)
- [Parámetros físicos de SDF](https://sdformat.org/spec?ver=1.9&elem=physics)
