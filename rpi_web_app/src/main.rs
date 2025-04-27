use axum::{response::Html, routing::get, Json, Router};
use reqwest;
use rusqlite::Connection;
use serde::Serialize;
use tokio::fs;

const DB_FILE: &str = "/var/lib/rpi_sensors_data/data.db";

#[derive(Serialize)]
struct SensorData {
    timestamp: String,
    bmp280_temp: f32,
    bmp280_pressure: f32,
    htu21d_temp: f32,
    htu21d_humidity: f32,
}

#[derive(Serialize)]
struct Weather {
    external_temp: f32,
    external_windspeed: f32,
    external_time: String,
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(index))
        .route("/data", get(get_data))
        .route("/external-weather", get(external_weather));

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn index() -> Html<String> {
    let html = fs::read_to_string("./templates/index.html").await.unwrap();
    Html(html)
}

async fn get_data() -> Json<Vec<SensorData>> {
    let conn = Connection::open(DB_FILE).unwrap();
    let mut stmt = conn
        .prepare(
            "SELECT timestamp, bmp280_temperature, bmp280_pressure, htu21d_temperature, htu21d_humidity FROM SensorData ORDER BY timestamp DESC",
        )
        .unwrap();

    let sensor_iter = stmt
        .query_map([], |row| {
            Ok(SensorData {
                timestamp: row.get(0)?,
                bmp280_temp: row.get(1)?,
                bmp280_pressure: row.get(2)?,
                htu21d_temp: row.get(3)?,
                htu21d_humidity: row.get(4)?,
            })
        })
        .unwrap();

    let mut sensors = Vec::new();
    for sensor in sensor_iter {
        sensors.push(sensor.unwrap());
    }

    Json(sensors)
}

async fn external_weather() -> Json<Weather> {
    let url =
        "https://api.open-meteo.com/v1/forecast?latitude=48.85&longitude=2.35&current_weather=true";
    let response = reqwest::get(url).await.unwrap();
    let json: serde_json::Value = response.json().await.unwrap();

    let weather = &json["current_weather"];

    let weather_data = Weather {
        external_temp: weather["temperature"].as_f64().unwrap() as f32,
        external_windspeed: weather["windspeed"].as_f64().unwrap() as f32,
        external_time: weather["time"].as_str().unwrap().to_string(),
    };

    Json(weather_data)
}
