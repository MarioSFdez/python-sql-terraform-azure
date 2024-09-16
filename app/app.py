import os
import pyodbc
import bcrypt
from flask import Flask, render_template, request

app = Flask(__name__)

# Datos de conexion a la base de datos
database = os.getenv("database")
password = os.getenv("password")
server = os.getenv("server")
user = os.getenv("user")
driver= '{ODBC Driver 18 for SQL Server}'

# Conexión a la base de datos SQL server
conexion = pyodbc.connect(f"DRIVER={driver};SERVER={server};DATABASE={database};UID={user};PWD={password}")
# Inicializa el cursor para ejecutar consultas SQL
cursor = conexion.cursor()

# Función para hashear la contraseña
def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

# Función para verificar la contraseña
def verificar_password(password, hashed_password):
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password)

# Ruta principal
@app.route('/')
def index():
    return render_template('index.html')

# Ruta para el login
@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']

    # Verificamos si el usuario existe en la base de datos
    query = "SELECT nombre_usuario, contraseña FROM usuarios WHERE nombre_usuario = ?"
    cursor.execute(query, username)
    user = cursor.fetchone()

    # El usuario existe y la contraseña es correcta
    if user and verificar_password(password, user[1].encode('utf-8')):
        return render_template('welcome.html', username=username, message="¡Bienvenido de nuevo")
    else:
        # Si falla el login, muestra un error
        return render_template('index.html', login_error="Usuario o contraseña incorrectos", register_error=None)

# Ruta para el registro de usuarios
@app.route('/register', methods=['POST'])
def register():
    username = request.form['register-username']
    password = request.form['register-password']

    # Devuelve un error si no se ha completado todos los campos
    if not username or not password:
        return render_template('index.html', register_error="Completa todos los campos.", login_error=None)
    
    # Hashear la contraseña antes de almacenarla en la base de datos
    hashed_password = hash_password(password)

    try:
        # Inserta el nuevo usuario y la contraseña cifrada en la base de datos
        query = "INSERT INTO usuarios (nombre_usuario, contraseña) VALUES (?, ?)"
        cursor.execute(query, (username, hashed_password))
        conexion.commit()
        return render_template('welcome.html', username=username, message="El usuario se creó correctamente. ¡Bienvenido")
    except pyodbc.IntegrityError as e:
        # Si el usuario ya existe, muestra un error específico
        return render_template('index.html', register_error="El usuario ya existe. Intenta con otro nombre.", login_error=None)
    except Exception as e:
        # Captura cualquier otro error durante el registro
        return render_template('index.html', register_error="Error al registrar el usuario. Intenta nuevamente.", login_error=None)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
