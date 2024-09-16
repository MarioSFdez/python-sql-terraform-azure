# Despliegue de una Aplicación Python en Azure a través de Github Actions y Terraform
Despliegue de una aplicación web en Python que incluye un formulario en Azure App Service, conectada a un backend en Azure SQL Database. 
La infraestructura se gestiona con Terraform, mientras que GitHub Actions automatiza el despliegue. 
La conexión a la base de datos se maneja mediante variables de entorno para mayor seguridad, y las contraseñas se protegen usando la librería bcrypt.

## Tecnologías Usadas
* **Microsoft Azure:** Alojamiento de la infraestructura
  
*  **Python:** Se utiliza Flask para manejar las rutas y lógica de la aplicación, junto con **pyodbc** para conectarse a la base de datos **SQL Server**
  
* **Terraform:** Define y despliega de manera automatizada la infraestructura del proyecto como el App Service o el servidor SQL
  
* **GitHub Actions:** Automatiza el proceso de despliegue de la aplicación cada vez que se realizan cambios en el repositorio, asegurando que los nuevos cambios se reflejen inmediatamente en producción.

* **bcrypt:** Librería de Python utilizada para el hashing de contraseñas, lo que permite almacenar las credenciales de los usuarios de manera segura en la base de datos.

* **pyodbc:** Se utiliza en la aplicación para realizar consultas a la base de datos SQL, asegurando la integración entre la aplicación web y el backend.

## Configuración

### Configuración de Terraform
Modifica el archivo [variables.tf](terraform-infra/variables.tf) reemplazando el valor ```<resource-group-name>``` por el nombre que desees utilizar.

```
variable "resource_group_name" {
  description = "Nombre del Grupo de Recursos"
  default     = "***<resource-group-name>***"
}

variable "app_service_name" {
  description = "Nombre del plan de servicios"
  default     = "<app-service-plan-name>"
}
```

Dentro del fichero [variables.tf](terraform-infra/variables.tf) en la variable ```<client-ip-address>``` define ```0.0.0.0``` para permitir que los recursos y servicios de Azure se conecten al servidor SQL. Esta configuración actúa como una excepción para habilitar el acceso desde cualquier IP dentro de Azure.
```
variable "ip_cliente" {
  description = "IPv4 del cliente para el acceso al Servidor SQL"
  default     = "<client-ip-address>"
}
```
> [!WARNING]
> Para poder conectarte al Servidor SQL desde tu equipo, debes habilitar una excepción en Azure y definir tu dirección IP en ```<client-ip-address>```. Esto permitirá el acceso seguro desde tu equipo al servidor.

### Configuración del servidor SQL

Crea una tabla dentro de la base de datos ```bbdd_usuarios``` que almacenará los usuarios y sus contraseñas hasheadas. El hasheo de las contraseñas se realiza utilizando la librería bcrypt de Python
```
 CREATE TABLE usuarios (
      id INT IDENTITY(1,1) PRIMARY KEY,
      nombre_usuario VARCHAR(25) NOT NULL UNIQUE,
      contraseña VARCHAR(255) NOT NULL
 );
```
### Configuración del workflow de Github Actions
Para desplegar la aplicación en **Azure App Service** a través del CI/CD de GitHub Actions necesitaremos **descargarnos el perfil de publicación.** 
Esto nos permitirá automatizar el despliegue de la aplicación en el entorno de Azure.
Una vez descargado el archivo, copiaremos el **contenido** para agregarlo más adelante en un secreto de Github

![image](https://github.com/user-attachments/assets/edf68105-6470-4d5a-9a1c-5c1ee3cc07d8)

Dentro del apartado de configuración, crearemos un secreto de acción llamado **```'AZURE_WEBAPP_PUBLISH_PROFILE'```**, en el cual agregaremos todo el contenido del archivo descargado de Azure App Service.

![image](https://github.com/user-attachments/assets/8e52db3a-c045-408c-b02e-ad199b66ba93)

Tras la creación del secreto en Github para una acción, utilizaremos el siguiente workflow [main.yml](.github/workflows/main.yml), el cual nos permitirá compilar y desplegar automáticamente la aplicación Python en un entorno de producción en Azure Web App cada vez que se realice un push a la rama main

**Fragmento del workflow**
```
name: Build and deploy Python app to Azure Web App - python-app-mario

on:
  push:
    branches:
      - main
  workflow_dispatch:

```
Cada vez que realicemos un push en el repositorio, se ejecutará la acción configurada en GitHub Actions y se desplegará automáticamente la aplicación.

![image](https://github.com/user-attachments/assets/1fe44ee2-1320-4d77-999d-2cc49e778dbe)

## Aplicación desarrollada en Python

En la siguiente imagen, se puede observar la aplicación [app.py](app/app.py) donde registraremos un nuevo usuario en el apartado de **Registrarse** 

![image](https://github.com/user-attachments/assets/9b61d591-4cb0-474b-a80a-8b40759933cf)

Comprobaremos en la base de datos que el usuario ha sido registrado correctamente. La contraseña se almacenará en formato hash, ya que la aplicación utiliza un algoritmo de hash para asegurar la contraseña mediante la librería **bcrypt**

![image](https://github.com/user-attachments/assets/53d8a91a-e595-4f75-95a9-ff80d8f5487a)

Como el usuario se encuentra en la base de datos de Azure SQL nos aparecerá el mensaje de bienvenida

![image](https://github.com/user-attachments/assets/4df24ba9-26f9-4b98-8388-9759021903ad)

Por último, realizaremos una modificación en el código y haremos un push al repositorio para verificar cómo se aplican los cambios en el entorno de producción

![image](https://github.com/user-attachments/assets/e1dba27e-bf56-47a6-a629-8d428d8f818b)

Verificaremos el inicio del proceso a través de la pestaña de 'Actions' en GitHub, observando el mensaje correspondiente al push
![image](https://github.com/user-attachments/assets/72eb5dea-4385-44e5-9ead-bc29d540e6e8)

Accederemos a la aplicación web mediante la URL proporcionada para confirmar que los cambios se han aplicado correctamente
![image](https://github.com/user-attachments/assets/f9304c1d-caa3-4fd1-bba7-19302e70d32a)

## Conclusión del proyecto
El proyecto de despliegue de una aplicación web en Python en Azure App Service, con un backend en Azure SQL Database, demuestra ser una solución robusta y flexible para una variedad de aplicaciones. Al gestionar la infraestructura con Terraform y automatizar el despliegue mediante GitHub Actions, hemos logrado una integración continua eficiente y un proceso de despliegue automatizado.

Este enfoque es particularmente útil en contextos como el sector bancario, donde la aplicación podría servir como una "banca online", permitiendo a los usuarios acceder y gestionar sus cuentas de forma segura y eficiente. La protección de las contraseñas con la librería bcrypt y el uso de variables de entorno para manejar la conexión a la base de datos refuerzan la seguridad de la aplicación.

En nuestro caso, al realizar un push al repositorio, hemos observado cómo los cambios se han desplegado correctamente en producción, confirmando la efectividad de nuestra configuración de CI/CD. Este proyecto no solo proporciona una base sólida para aplicaciones web seguras y escalables, sino que también ofrece un modelo que puede ser adaptado para diversos sectores y necesidades empresariales.

## Autor
| [<img src="https://avatars.githubusercontent.com/u/140948023?s=400&u=f1aaaefb0cd2fe5f6be92fba05411a79d3a92878&v=4" width=115><br><sub>Mario Sierra Fernández</sub>](https://github.com/MarioSFdez) |
| :---: | 
