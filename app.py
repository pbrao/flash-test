from flask import Flask, render_template, request
import requests
import os
from datetime import datetime

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    weather_data = None
    if request.method == "POST":
        zip_code = request.form["zip_code"]
        if zip_code and len(zip_code) == 5 and zip_code.isdigit():
            weather_data = get_weather(zip_code)
        else:
            weather_data = "Please enter a valid 5-digit zip code."
    return render_template("index.html", weather_data=weather_data)

def get_weather(zip_code):
    api_key = os.environ.get("OPENWEATHERMAP_API_KEY") # Get API key from environment variable
    if not api_key:
        return "API key not set. Please set the OPENWEATHERMAP_API_KEY environment variable."
    base_url = "https://api.openweathermap.org/data/2.5/forecast"
    params = {
        "zip": f"{zip_code},us",
        "appid": api_key,
        "units": "imperial",
    }
    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
        data = response.json()
        return process_weather_data(data)
    except requests.exceptions.RequestException as e:
        return f"Error fetching weather  {e}"

def process_weather_data(data):
    if not data or not data.get("list"):
        return "No weather data found for this zip code."

    current_temp = data["list"][0]["main"]["temp"]
    forecast_text = f"Current Temperature: {current_temp}°F\n\n7-Day Forecast:\n"

    for i in range(0, len(data["list"]), 8):
        forecast_item = data["list"][i]
        date = datetime.fromtimestamp(forecast_item["dt"])
        day = date.strftime("%a")
        temp = forecast_item["main"]["temp"]
        forecast_text += f"{day}: {temp}°F\n"

    return forecast_text

if __name__ == "__main__":
    app.run(debug=True)
