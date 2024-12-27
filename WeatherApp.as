package {

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.utils.JSON;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.display.SimpleButton;

	public class WeatherApp extends Sprite {

		private var zipCodeInput:TextField;
		private var getWeatherButton:SimpleButton;
		private var weatherDisplay:TextField;

		public function WeatherApp() {
			// constructor code
			if (stage) {
				init();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}

		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			setupUI();
			getWeatherButton.addEventListener(MouseEvent.CLICK, onGetWeatherClick);
		}

		private function setupUI():void {
			// Assuming these are already created on the stage
			zipCodeInput = this.getChildByName("zipCodeInput") as TextField;
			getWeatherButton = this.getChildByName("getWeatherButton") as SimpleButton;
			weatherDisplay = this.getChildByName("weatherDisplay") as TextField;
		}


		private function onGetWeatherClick(event:MouseEvent):void {
			var zipCode:String = zipCodeInput.text;
			if (zipCode.length != 5 || isNaN(Number(zipCode))) {
				weatherDisplay.text = "Please enter a valid 5-digit zip code.";
				return;
			}
			getWeather(zipCode);
		}

		private function getWeather(zipCode:String):void {
			var apiKey:String = "YOUR_API_KEY"; // Replace with your actual API key
			var url:String = "https://api.openweathermap.org/data/2.5/forecast?zip=" + zipCode + ",us&appid=" + apiKey + "&units=imperial";
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onWeatherDataLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onWeatherDataError);
			loader.load(request);
		}

		private function onWeatherDataLoaded(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			var jsonData:Object = JSON.parse(loader.data);
			displayWeather(jsonData);
		}

		private function onWeatherDataError(event:IOErrorEvent):void {
			weatherDisplay.text = "Error loading weather data.";
		}

		private function displayWeather(Object):void {
			if (!data || !data.list || data.list.length == 0) {
				weatherDisplay.text = "No weather data found for this zip code.";
				return;
			}

			var currentTemp:Number = data.list[0].main.temp;
			var forecastText:String = "Current Temperature: " + currentTemp + "°F\n\n7-Day Forecast:\n";

			for (var i:int = 0; i < data.list.length; i+=8) { // OpenWeatherMap provides data every 3 hours, so we skip to get daily data
				var forecastItem:Object = data.list[i];
				var date:Date = new Date(forecastItem.dt * 1000);
				var day:String = date.toLocaleDateString(undefined, { weekday: 'short' });
				var temp:Number = forecastItem.main.temp;
				forecastText += day + ": " + temp + "°F\n";
			}

			weatherDisplay.text = forecastText;
		}
	}
}
