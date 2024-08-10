import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:weather_app_2/widgets/common_widgets.dart';

class WeatherForecast extends StatefulWidget {
  WeatherForecast({super.key,required this.forecastMap});
  final Map forecastMap;

  @override
  State<WeatherForecast> createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: widget.forecastMap.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Container(

            child: Column(
              children: [
               Text(Jiffy.parse("${widget.forecastMap['list'][index]['dt_txt']}").format(pattern: 'EEEE h: mm')),
                Image.network("https://openweathermap.org/img/wn/${widget.forecastMap!["list"][index]['weather'][0]['icon']}@2x.png",width: 100,height: 100,),
                Text("${widget.forecastMap['list'][index]['main']['temp']}°C")
              ],
            ),
                    ),
          ),
      ),
    );
  }
}
