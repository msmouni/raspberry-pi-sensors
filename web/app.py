from flask import Flask, render_template, jsonify
import sqlite3

app = Flask(__name__)

DB_FILE = "data.db"

# Function to get the last 10 sensor records from the database
def get_sensor_data():
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("SELECT timestamp, bmp280_temperature, bmp280_pressure, htu21d_temperature, htu21d_humidity FROM SensorData ORDER BY timestamp DESC LIMIT 10")
    data = cursor.fetchall()
    conn.close()
    
    
    return [
        {"timestamp": row[0], "bmp280_temp": row[1], "bmp280_pressure": row[2], "htu21d_temp": row[3], "htu21d_humidity": row[4]}
        for row in data
    ]

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/data")
def data():
    sensor_data = get_sensor_data()
    return jsonify(sensor_data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
