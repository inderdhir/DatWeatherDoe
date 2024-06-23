# [<img src="logo.png" width="20"/>](image.png) DatWeatherDoe

- Fetch weather using:
  - Location services
  - Zip Code
  - Latitude / Longitude
  - City
- Configurable polling interval
- Dark mode support
- Supports MacOS 13.0+

## Screenshots

![Screenshot 1](screenshot_1.png)\
![Screenshot 2](screenshot_2.png)
![Screenshot 3](screenshot_3.png)

## Installation

### Homebrew Cask

`brew install --cask datweatherdoe`

### Manual

<https://github.com/inderdhir/DatWeatherDoe/releases/latest>

## Using Location Services

If using location, please make sure that the app has permission to access location services on macOS.

`System Preferences > Security & Privacy > Privacy > Location Services`

![Location services screenshot 1](location_services_1.png)
![Location services screenshot 2](location_services_2.png)

## Developer Setup

- Get your personal API key for WeatherAPI [here](https://www.weatherapi.com)
- Add the following in "Config.xcconfig":

```env
WEATHER_API_KEY=YOUR_KEY
```

## Donate

Buy me a coffee to support the development of this project.

<a href="https://www.buymeacoffee.com/inderdhir"><img src="https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=inderdhir&button_colour=FFDD00&font_colour=000000&font_family=Poppins&outline_colour=000000&coffee_colour=ffffff"></a>

## Contribute

Please see CONTRIBUTING.md
