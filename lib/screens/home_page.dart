import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:weather_app_2/widgets/common_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition();
    getWeatherData();
    print("latitude = ${position!.latitude} and longitude = ${position!
        .longitude}");
  }

  Position ?position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  getWeatherData() async {
    var weather = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position!
            .latitude}&lon=${position!
            .longitude}&appid=d17d902923ebc9bb3573f9267534a774"));
    print("${weather.body}");
    var forecast = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${position!
            .latitude}&lon=${position!
            .longitude}&appid=d17d902923ebc9bb3573f9267534a774"));
    print("${forecast.body}");
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weather.body));
      forecastMap = Map<String, dynamic>.from(jsonDecode(forecast.body));
    });
  }

  @override
  void initState() {
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: weatherMap != null? Scaffold(
       
        body: Stack(
          children: [
            Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,

                colors: [


                  Color(0xff4A91FF),

                  Color(0xff47BFDF),
      
                ]
              )
            ),
            width: double.infinity,
            child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${weatherMap!['name']}'),
                      Icon(Icons.menu),
                    ],
                  ),

                  Text("${Jiffy.parse('${DateTime.now()}').format(pattern: 'EEEE MMM yyyy')}"),
                  Text("${Jiffy.parse('${DateTime.now()}').format(pattern: 'h:mm a')}"),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Container(

                      height: mqHeight(context) * .20,
                      width: mqWidth(context) * .30,

                      child: Image.asset("lib/assets/images/weather1.png"),

                    ),
                  ),
      
                ]),
          ),
          ],
        ),
      
      
      ):Center(child: CircularProgressIndicator(),),
    );
  }
}
