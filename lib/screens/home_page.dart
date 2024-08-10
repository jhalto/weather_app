import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:weather_app_2/screens/forecast.dart';
import 'package:weather_app_2/screens/weather_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();

  Position? position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    getWeatherData();
  }

  getWeatherData([String? city]) async {
    if (city != null && city.isEmpty) {
      // Show an error or ignore the search request if the city is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid city name')),
      );
      return;
    }

    var weatherUrl;
    var forecastUrl;
    if (city == null) {
      weatherUrl =
      "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=d17d902923ebc9bb3573f9267534a774&units=metric";
      forecastUrl =
      "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=d17d902923ebc9bb3573f9267534a774&units=metric";
    } else {
      weatherUrl =
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=d17d902923ebc9bb3573f9267534a774&units=metric";
      forecastUrl =
      "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=d17d902923ebc9bb3573f9267534a774&units=metric";
    }

    try {
      var weather = await http.get(Uri.parse(weatherUrl));
      var forecast = await http.get(Uri.parse(forecastUrl));

      if (weather.statusCode == 200 && forecast.statusCode == 200) {
        setState(() {
          weatherMap = Map<String, dynamic>.from(jsonDecode(weather.body));
          forecastMap = Map<String, dynamic>.from(jsonDecode(forecast.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch weather data for the location.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching weather data.')),
      );
    }
  }

  @override
  void initState() {
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var temp = weatherMap?['main']?['temp'];
    if (temp != null) {
      temp = temp.toInt();
    }

    return SafeArea(
      child: weatherMap != null
          ? Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      colors: [
                        Color(0xff4A91FF),
                        Color(0xff47BFDF),
                      ])),
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.location_on),
                        onPressed: () {
                          determinePosition();
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for a city...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  getWeatherData(
                                      _searchController.text);
                                },
                              ),
                            ),
                            onSubmitted: (value) {
                              getWeatherData(value);
                            },
                          ),
                        ),
                      ),
                      Icon(Icons.menu),
                    ],
                  ),
                  Text(
                      "${Jiffy.parse('${DateTime.now()}').format(pattern: 'EEEE MMM yyyy')}"),
                  Text(
                      "${Jiffy.parse('${DateTime.now()}').format(pattern: 'h:mm a')}"),
                  Text(
                    '${weatherMap!['name']}',
                    style: TextStyle(fontSize: 30),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image.network(
                      "https://openweathermap.org/img/wn/${weatherMap!["weather"][0]['icon']}@2x.png",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        temp != null
                            ? Text(
                          "$temp°C ",
                          style: TextStyle(fontSize: 30),
                        )
                            : CircularProgressIndicator(),
                        Text(
                            "${weatherMap!['weather'][0]['main']}."),
                        SizedBox(height: 10),
                        weatherDetails(weatherMap: weatherMap!),
                        SizedBox(height: 50),
                        WeatherForecast(forecastMap: forecastMap!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}