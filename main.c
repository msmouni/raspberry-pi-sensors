#include <stdio.h>
#include <time.h>
#include <signal.h>
#include <unistd.h> // For sleep()
#include "htu21d.h"
#include "bmp280.h"
#include "db.h"

#define I2C_BUS "/dev/i2c-1"
#define DB_FILE "data.db"
#define DB_DATA_SIZE 10

volatile sig_atomic_t keep_running = 1; // Flag for shutdown

void handle_signal(int signal)
{
    printf("\nCaught signal %d. Shutting down...\n", signal);
    keep_running = 0; // Change flag to exit the loop
}

int main()
{
    // Set up signal handlers for SIGINT and SIGTERM
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    struct I2cBus *i2c_bus = i2c_init(I2C_BUS);

    if (!i2c_bus)
    {
        perror("Failed to initialize I2C bus");
        return -1;
    }

    // Initialize sensors
    struct bmp280 *bmp280_sens = bmp280_init(i2c_bus);
    float bmp280_temp, bmp280_pressure;

    struct htu21d *htu21d_sens = htu21d_init(i2c_bus);
    struct htu21d_measurement temperature, humidity;

    // Initialize SQLite database
    struct sensors_db *sens_db = sensors_db_init(DB_FILE, DB_DATA_SIZE);

    // Main measurement loop
    while (keep_running)
    {
        if (bmp280_get_measurement(bmp280_sens, &bmp280_temp, &bmp280_pressure) == 0)
        {
            printf("BMP280 temperature: %.2f °C\n", bmp280_temp);
            printf("BMP280 pressure: %.2f hPa\n", bmp280_pressure);

            temperature = htu21d_read_temperature(htu21d_sens);
            humidity = htu21d_read_humidity(htu21d_sens);

            if (temperature.is_valid && humidity.is_valid)
            {
                printf("HTU21D temperature: %.2f °C\n", temperature.value);
                printf("HTU21D humidity: %.2f %%RH\n", humidity.value);

                if (sensors_db_store_data(sens_db, bmp280_temp, bmp280_pressure, temperature.value, humidity.value) == 0)
                {
                    printf("Sensors data stored successfully\n");
                }
            }
            else
            {
                printf("Invalid measurement: temperature valid: %d, humidity valid: %d\n",
                       temperature.is_valid, humidity.is_valid);
            }
        }
        sleep(5); // Wait 5 seconds between measurements
    }

    // Cleanup before exiting
    printf("Cleaning up resources...\n");
    i2c_close(i2c_bus);
    bmp280_close(bmp280_sens);
    htu21d_close(htu21d_sens);
    sensors_db_close(sens_db);

    printf("Program terminated.\n");
    return 0;
}
