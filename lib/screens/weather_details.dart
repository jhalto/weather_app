import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class weatherDetails extends StatefulWidget {
  weatherDetails({super.key, required this.weatherMap});

  final Map weatherMap;

  @override
  State<weatherDetails> createState() => _weatherDetailsState();
}

class _weatherDetailsState extends State<weatherDetails> {
  @override
  Widget build(BuildContext context) {
    var feels = widget.weatherMap?['main']['feels_like'];

    feels = feels.toInt();
    var humidity = widget.weatherMap?['main']['humidity'];
    humidity = humidity.toString();
    var maxTemp = widget.weatherMap?['main']['temp_max'];
    maxTemp = maxTemp.toString();
    var wind = widget.weatherMap?['wind']['speed'];
    wind = wind.toString();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(15)
      ),
      width: double.infinity,
      height: 200,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Column(

                children: [
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Feel like"),
                          Text("${feels}"),
                        ],
                      )),
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Humidity"),
                          Text(humidity),
                        ],
                      )),
                ],
              )),
          Expanded(
              flex: 1,
              child: Column(

                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Max Temp"),
                        Text("${maxTemp}"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Wind"),
                        Text("${wind} km/h"),
                      ],
                    ),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }
}
