## Entorno ROS 2 Jazzy

Esta práctica usa Ubuntu 24.04 Noble y ROS 2 Jazzy. Las capturas y videos originales son referencias históricas.
Instale primero las dependencias mediante los scripts de la rama `main`.

```bash
source /opt/ros/jazzy/setup.bash
git clone --branch Clase-Odometry --single-branch https://github.com/xXThanatosXx/MobileRobot-Jazzy.git
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

<h1 align="center">Clase Robot Odometría </h1>

El objetivo de la presente práctica es conocer los conceptos básico de ROS 2 Jazzy (paquete, nodo, topicos, info y rqt), para la simulación del comportamiento de un robot móvil en Gazebo.

### Compilación del proyecto 


<p align="center">
<a href="https://virtual.umariana.edu.co/campus/mod/url/view.php?id=324738" target="_blank">**Enlace a Video Instalación de Arduino**</a>
</p>

```bash
ros2 pkg create --build-type ament_cmake difrobot_firmware
Clonar repositorio
```
```bash
git clone --branch Clase-Odometry --single-branch https://github.com/xXThanatosXx/MobileRobot-Jazzy.git

```
Mover archivos a home

```bash
mv ~/MobileRobot-Jazzy/difrobot_ws ~/difrobot_ws
```
Limpiar Cache de CMake
```bash
rm -rf ~/difrobot_ws/build/difrobot_controller
```

Compilar
```bash
colcon build
```
Instalar paquete serial-dev
```bash
sudo apt-get install libserial-dev
```
Instalar el paquete `pyserial`:

```bash
   sudo apt install python3-serial
```
## En caso de tener inconvenientes
Limpiar cache
```bash
colcon build --cmake-clean-cache
```
Instalar dependencias
```bash
rosdep install --from-paths src --ignore-src -r -y
```
Aplicar cambios

```bash
source /opt/ros/jazzy/setup.bash
source install/setup.bash

```

## Nodo de Transmisión


### Simple Serial Transmitter Node

Este script en Python implementa un nodo de ROS2 que escucha mensajes en un tópico específico y los envía a un dispositivo conectado a través de un puerto serial (como un Arduino).

### Descripción General

El nodo llamado `simple_serial_transmitter` se suscribe a un tópico de ROS2 (`serial_transmitter`) y transmite los datos recibidos a un dispositivo serial (por ejemplo, Arduino) a través de un puerto serial utilizando los parámetros de puerto y baudrate configurados.

### Requisitos

- ROS2 (jazzy o compatible).
- Biblioteca `pyserial` para manejar la comunicación serial.
- Un dispositivo conectado al puerto serial que reciba y procese los datos (por ejemplo, Arduino).

### Configuración de los Parámetros

El programa permite configurar los siguientes parámetros:

1. **`port`**: El puerto serial al que está conectado el dispositivo (por defecto `/dev/ttyACM0`).
2. **`baudrate`**: La tasa de baudios para la comunicación serial (por defecto `115200`).

### Estructura del Código

#### 1. **Clase `SimpleSerialTransmitter`**

- **`__init__()`**: 
  - Inicializa el nodo ROS2 con el nombre `"simple_serial_transmitter"`.
  - Declara los parámetros `port` y `baudrate` para configurar el puerto serial y la tasa de baudios.
  - Abre el puerto serial con los valores configurados.
  - Crea una suscripción al tópico `serial_transmitter`, que recibe mensajes de tipo `std_msgs/String`.
  
- **`msgCallback(msg)`**:
  - Esta función se ejecuta cuando llega un nuevo mensaje en el tópico `serial_transmitter`.
  - Publica el contenido del mensaje en el puerto serial conectado al dispositivo.
  - Muestra en los logs del nodo el nombre del puerto serial y el mensaje recibido.

#### 2. **Función `main()`**

- Inicializa el sistema de ROS2.
- Crea una instancia de la clase `SimpleSerialTransmitter`.
- Hace girar el nodo para que permanezca en funcionamiento y escuche mensajes.
- Al finalizar, destruye el nodo y apaga el sistema de ROS2.

### Uso

Ejecutar nodo de transmision

![alt text](image-1.png)
```bash
ros2 run difrobot_firmware simple_serial_transmitter.py 
```
```bash
--ros-args -p port:=/dev/ttyACM0
```
Publicar estado de led
```bash
ros2 topic pub /serial_transmitter std_msgs/msg/String "data: '0'" 
```

***simple_serial_transmitter.py***
```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from std_msgs.msg import String
import serial


class SimpleSerialTransmitter(Node):
    def __init__(self):
        super().__init__("simple_serial_transmitter")

        self.declare_parameter("port", "/dev/ttyACM0")
        self.declare_parameter("baudrate", 115200)

        self.port_ = self.get_parameter("port").value
        self.baudrate_ = self.get_parameter("baudrate").value

        self.sub_ = self.create_subscription(String, "serial_transmitter", self.msgCallback, 10)
        self.sub_
        self.arduino_ = serial.Serial(port=self.port_, baudrate=self.baudrate_, timeout=0.1)

    def msgCallback(self, msg):
        self.get_logger().info("New message received, publishing on serial: %s" % self.arduino_.name)
        self.arduino_.write(msg.data.encode("utf-8"))


def main():
    rclpy.init()

    simple_serial_transmitter = SimpleSerialTransmitter()
    rclpy.spin(simple_serial_transmitter)
    
    simple_serial_transmitter.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()

```
***Programa simple_serial_receiver.ino***
```c++
#define LED_PIN 13

void setup() {
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW); 

  Serial.begin(115200);
  Serial.setTimeout(1);
}

void loop() {
  if (Serial.available())
  {
    int x = Serial.readString().toInt();
    if(x == 0)
    {
      // turn off the led
      digitalWrite(LED_PIN, LOW); 
    }
    else
    {
      // turn on the led
      digitalWrite(LED_PIN, HIGH); 
    }
  }
  delay(0.1);
}
```
## Nodo de Recepción

### Simple Serial Receiver Node

Este script en Python crea un nodo de ROS2 que se comunica con un dispositivo Arduino a través de un puerto serial y publica los datos leídos en un tópico de ROS2.

## Descripción General

El nodo llamado `simple_serial_receiver` se conecta a un puerto serial configurado con un baudrate específico, lee datos enviados desde el dispositivo (como un Arduino) y publica estos datos en el tópico de ROS2 llamado `serial_receiver`.

### Requisitos

- ROS2 (en este caso, jazzy o compatible).
- Biblioteca `pyserial` para interactuar con el puerto serial.
- Un dispositivo (como un Arduino) conectado al puerto serial que envíe datos.

### Configuración de los Parámetros

El programa admite dos parámetros configurables:

1. **`port`**: El puerto serial al que está conectado el dispositivo (por defecto `/dev/ttyACM0`).
2. **`baudrate`**: La tasa de baudios para la comunicación serial (por defecto `115200`).

Ambos parámetros se pueden modificar desde la línea de comandos o en un archivo de configuración para adaptarse a diferentes dispositivos.

### Estructura del Código

#### 1. **Clase `SimpleSerialReceiver`**

- **`__init__()`**: 
  - Inicializa el nodo ROS2 con el nombre `"simple_serial_receiver"`.
  - Declara los parámetros del puerto serial (`port`) y la tasa de baudios (`baudrate`).
  - Abre el puerto serial usando los parámetros configurados.
  - Crea un publicador para el tópico `serial_receiver` que envía mensajes de tipo `std_msgs/String`.
  - Define un temporizador (`timer_`) que se ejecuta con una frecuencia de 0.01 segundos (10ms) para leer los datos del puerto serial periódicamente.

- **`timerCallback()`**:
  - Esta función se ejecuta con la frecuencia configurada por el temporizador.
  - Verifica si el puerto serial está abierto.
  - Lee una línea de datos del puerto serial.
  - Intenta decodificar los datos leídos a UTF-8 para asegurarse de que el mensaje es legible.
  - Publica los datos leídos en el tópico `serial_receiver` en formato de string.

#### 2. **Función `main()`**

- Inicia el sistema de ROS2.
- Crea una instancia de la clase `SimpleSerialReceiver`.
- Hace girar el nodo para que permanezca en funcionamiento y escuche eventos.
- Al terminar, destruye el nodo y apaga el sistema de ROS2.

### Uso

Ejecutar nodo de recepción
![alt text](image.png)

```bash
ros2 run difrobot_firmware simple_serial_receiver.py --ros-args -p port:=/dev/ttyACM0
```
Listar topicos
```bash
ros2 topic list
```
Escuchar puerto
```bash
ros2 topic echo /serial_receiver
```

***simple_serial_receiver.py***

```python
#!/usr/bin/env python3
import serial
import rclpy
from rclpy.node import Node
from std_msgs.msg import String


class SimpleSerialReceiver(Node):
    def __init__(self):
        super().__init__("simple_serial_receiver")

        self.declare_parameter("port", "/dev/ttyACM0")
        self.declare_parameter("baudrate", 115200)

        self.port_ = self.get_parameter("port").value
        self.baudrate_ = self.get_parameter("baudrate").value

        self.pub_ = self.create_publisher(String, "serial_receiver", 10)
        self.arduino_ = serial.Serial(port=self.port_, baudrate=self.baudrate_, timeout=0.1)

        self.frequency_ = 0.01
        self.timer_ = self.create_timer(self.frequency_, self.timerCallback)

    def timerCallback(self):
        if rclpy.ok() and self.arduino_.is_open:
            data = self.arduino_.readline()

            try:
                data.decode("utf-8")
            except:
                return

            msg = String()
            msg.data = str(data)
            self.pub_.publish(msg)


def main():
    rclpy.init()

    simple_serial_receiver = SimpleSerialReceiver()
    rclpy.spin(simple_serial_receiver)
    
    simple_serial_receiver.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
```
***Programa simple_serial_transmitter.ino***
```c++
int x = 0;

void setup() {
  Serial.begin(115200);
  Serial.setTimeout(1);
}

void loop() {
  Serial.println(x);
  x++;
  delay(0.1);
}
```
## Configuración de motor

***Programa simple_motor_control.ino***
```c++
// L298N H-Bridge Connection PINs
#define L298N_enA 6  // PWM 9
#define L298N_in2 7 // Dir Motor A 13
#define L298N_in1 8  // Dir Motor A 12

float cmd = 0;

void setup() {
  // Set pin modes
  pinMode(L298N_enA, OUTPUT);
  pinMode(L298N_in1, OUTPUT);
  pinMode(L298N_in2, OUTPUT);
  
  // Set Motor Rotation Direction
  digitalWrite(L298N_in1, HIGH);
  digitalWrite(L298N_in2, LOW);

  Serial.begin(115200);
}

void loop() {
  if (Serial.available())
  {
    cmd = Serial.readString().toFloat();
  }
  analogWrite(L298N_enA, cmd*100);
}
```
## Configuración de Encoder

### Componentes

- Arduino
- Módulo Puente H L298N
- Motor DC
- Encoder de rueda
- Fuente de alimentación adecuada para el motor

- `right_wheel_meas_vel`: Almacena la velocidad medida de la rueda en rad/s.

1. Función rightEncoderCallback():
Esta función se ejecuta cada vez que se detecta un flanco ascendente en el pin right_encoder_phaseA (pulsos del encoder). Lee el estado del pin right_encoder_phaseB para determinar la dirección de rotación del motor:

- Si right_encoder_phaseB está en ALTO, la rotación es positiva (sentido horario).
- Si right_encoder_phaseB está en BAJO, la rotación es negativa (sentido antihorario).


2. Calcula la velocidad de la rueda derecha usando la siguiente fórmula:
La ecuación para calcular la velocidad de la rueda derecha es:

La ecuación para calcular la velocidad de la rueda es:

\[
\text{right\_wheel\_meas\_vel} = \left( 10 \times \text{right\_encoder\_counter} \times \left( \frac{60.0}{385.0} \right) \right) \times 0.10472
\]
- right_encoder_counter: Número de pulsos del encoder.
- 60.0 / 385.0: Convierte pulsos en revoluciones por minuto (RPM).

- (385) numero de Ticks en una vuelta: resolución del encoder

- 0.10472: Conversión de RPM a radianes por segundo (rad/s).
La constante de conversión de RPM a radianes por segundo es:

\[
1 \, \text{RPM} = \frac{2 \pi}{60} \, \text{rad/s} \approx 0.10472 \, \text{rad/s}
\]


- 10: Ajuste para convertir los pulsos medidos cada 100 ms a una velocidad por segundo.

***Programa Simple_encoder_reader.ino***
```c++
// L298N H-Bridge Connection PINs
#define L298N_enA 6  // PWM 9
#define L298N_in2 7  // Dir Motor A 13
#define L298N_in1 8  // Dir Motor A 12

#define right_encoder_phaseA 2  // Interrupt 3
#define right_encoder_phaseB 3  // 5

unsigned int right_encoder_counter = 0;
String right_encoder_sign = "p";
double right_wheel_meas_vel = 0.0;    // rad/s

void setup() {
  // Set pin modes
  pinMode(L298N_enA, OUTPUT);
  pinMode(L298N_in1, OUTPUT);
  pinMode(L298N_in2, OUTPUT);
  
  // Set Motor Rotation Direction
  digitalWrite(L298N_in1, HIGH);
  digitalWrite(L298N_in2, LOW);

  Serial.begin(115200);

  pinMode(right_encoder_phaseB, INPUT);
  attachInterrupt(digitalPinToInterrupt(right_encoder_phaseA), rightEncoderCallback, RISING);
}

void loop() {
  right_wheel_meas_vel = (10 * right_encoder_counter * (60.0/385.0)) * 0.10472;
  String encoder_read = "r" + right_encoder_sign + String(right_wheel_meas_vel);
  Serial.println(encoder_read);
  right_encoder_counter = 0;
  analogWrite(L298N_enA, 100);
  delay(100);
}

void rightEncoderCallback()
{
  if(digitalRead(right_encoder_phaseB) == HIGH)
  {
    right_encoder_sign = "p";
  }
  else
  {
    right_encoder_sign = "n";
  }
  right_encoder_counter++;
}

```
***Archivo CMakeList.txt***
```c++
cmake_minimum_required(VERSION 3.8)
project(difrobot_firmware)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()


# Encuentra los paquetes necesarios de Python
find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)
find_package(rclpy REQUIRED)
find_package(std_msgs REQUIRED)

# Instalar el paquete de Python
ament_python_install_package(${PROJECT_NAME})

# Instalar scripts Python
install(PROGRAMS
  ${PROJECT_NAME}/simple_serial_transmitter.py
  ${PROJECT_NAME}/simple_serial_receiver.py
  DESTINATION lib/${PROJECT_NAME}
)


# Exportar dependencias necesarias
ament_export_dependencies(
  rclpy
  std_msgs
)

ament_package()
```
***Archivo package.xml***

```xml

<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>difrobot_firmware</name>
  <version>0.0.0</version>
  <description>TODO: Package description</description>
  <maintainer email="ros@todo.todo">ros</maintainer>
  <license>TODO: License declaration</license>

  <buildtool_depend>ament_cmake</buildtool_depend>
  <buildtool_depend>ament_cmake_python</buildtool_depend>

  <depend>rclpy</depend>
  <depend>std_msgs</depend>

  <exec_depend>python3-serial</exec_depend>

  <test_depend>ament_lint_auto</test_depend>
  <test_depend>ament_lint_common</test_depend>

  <export>
    <build_type>ament_cmake</build_type>
  </export>
</package>
```