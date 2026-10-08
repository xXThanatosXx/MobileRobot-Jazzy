## Entorno ROS 2 Jazzy

Esta práctica usa Ubuntu 24.04 Noble y ROS 2 Jazzy. Las capturas y videos originales son referencias históricas.
Instale primero las dependencias mediante los scripts de la rama `main`.

```bash
source /opt/ros/jazzy/setup.bash
git clone --branch Clase-Control --single-branch https://github.com/xXThanatosXx/MobileRobot-Jazzy.git
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


# Controlador Simple de Robot Diferencial

Este nodo de ROS2 implementa un controlador simple para un robot con tracción diferencial. Toma comandos de velocidad (lineal y angular) y los convierte en velocidades de las ruedas utilizando el modelo cinemático diferencial. Las velocidades de las ruedas se publican en un tópico específico para ser ejecutadas por el hardware del robot.

## Resumen

- **Nombre del nodo**: `simple_controller`
- **Suscripciones**: 
  - `difrobot_controller/cmd_vel` (Tipo: `TwistStamped`): Recibe los comandos de velocidad del robot.
  
- **Publicaciones**:
  - `simple_velocity_controller/commands` (Tipo: `Float64MultiArray`): Publica las velocidades calculadas para las ruedas.
  
- **Parámetros**:
  - `wheel_radius` (por defecto: 0.033): El radio de las ruedas del robot.
  - `wheel_separation` (por defecto: 0.17): La distancia entre las ruedas (ancho del robot).

## Descripción del Código

### 1. Inicialización

El nodo se inicializa declarando dos parámetros:
- `wheel_radius`: El radio de las ruedas del robot.
- `wheel_separation`: La distancia entre las ruedas.

```python
self.wheel_radius_ = self.get_parameter("wheel_radius").get_parameter_value().double_value
self.wheel_separation_ = self.get_parameter("wheel_separation").get_parameter_value().double_value
```

Estos parámetros se utilizan posteriormente para calcular las velocidades de las ruedas a partir de los comandos de velocidad recibidos.

### 2. Suscripción y Publicación

El nodo se suscribe al tópico `cmd_vel`, que proporciona las velocidades lineales y angulares deseadas para el robot. También publica las velocidades calculadas de las ruedas en el tópico `simple_velocity_controller/commands`.

### 3. Conversión de Velocidades

El modelo cinemático diferencial se utiliza para convertir la velocidad lineal (\(v\)) y la velocidad angular (\(\omega\)) del robot en las velocidades de las ruedas izquierda y derecha. Esto se realiza utilizando la siguiente matriz:

```python
self.speed_conversion_ = np.array([[self.wheel_radius_/2, self.wheel_radius_/2],
                                   [self.wheel_radius_/self.wheel_separation_, -self.wheel_radius_/self.wheel_separation_]])
```

#### Modelo Matemático

En un robot diferencial, la relación entre las velocidades lineal y angular del robot y las velocidades de las ruedas izquierda (\(v_L\)) y derecha (\(v_R\)) está dada por:



$v_L = \frac{2v - \omega L}{2r}$

$v_R = \frac{2v + \omega L}{2r}$




Donde:
- \(v\): Velocidad lineal del robot.
- \(\omega\): Velocidad angular del robot.
- \(r\): Radio de las ruedas.
- \(L\): Separación entre las ruedas.

La **matriz de conversión** encapsula esta relación:



$\text{Matriz de Conversión} =
\begin{bmatrix}
\frac{r}{2} & \frac{r}{2} \\
\frac{r}{L} & -\frac{r}{L}
\end{bmatrix}$

Esta matriz toma la forma:


![alt text](image-2.png)


### 4. Función Callback

La función `velCallback` se activa cada vez que se recibe un nuevo comando de velocidad. Toma las velocidades lineal (\(v\)) y angular (\(\omega\)), aplica la matriz de conversión y publica las velocidades de las ruedas.

```python
robot_speed = np.array([[msg.twist.linear.x],
                        [msg.twist.angular.z]])
wheel_speed = np.matmul(np.linalg.inv(self.speed_conversion_), robot_speed)
```

Las velocidades de las ruedas se publican como:

```python
wheel_speed_msg = Float64MultiArray()
wheel_speed_msg.data = [wheel_speed[1, 0], wheel_speed[0, 0]]
```

## Ejecutar el Nodo
```bash
ros2 launch  difrobot_description gazebo.launch.py 
```


```bash
ros2 launch difrobot_controller controller.launch.py 
```
```bash
ros2 control list_controllers 
```
```bash
ros2 control list_hardware_interfaces
```
```bash
ros2 topic list 
```

```bash
ros2 topic pub --rate 10 /simple_velocity_controller/commands std_msgs/msg/Float64MultiArray "{data: [1.0, 1.0]}"
```

## Velocidad

```bash
 ros2 launch  difrobot_description gazebo.launch.py 

```
```bash
ros2 launch difrobot_controller controller.launch.py 
```
```bash
ros2 topic pub --use-sim-time --rate 10 /difrobot_controller/cmd_vel geometry_msgs/msg/TwistStamped "{header: auto, twist: {linear: {x: 0.02}, angular: {z: 0.0}}}"
```

