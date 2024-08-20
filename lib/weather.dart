import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_icons/weather_icons.dart';

import 'additional_items.dart';
import 'forcast_items.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future getCurrentWeather() async {
    try {
      final result = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=Islamabad,PK&APPID=$apiKey'),
      );
      if (result.statusCode != 200) {
        throw 'Failed to fetch data';
      }

      final data = jsonDecode(result.body);

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp =
              (currentWeatherData['main']['temp'].toDouble() - 273.15)
                  .toStringAsFixed(2);
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed =
              currentWeatherData['wind']['speed'].toDouble();
          final currentPressure = currentWeatherData['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp°C',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              BoxedIcon(
                                currentSky == 'Clouds'
                                    ? WeatherIcons.cloud
                                    : currentSky == 'Rain'
                                        ? WeatherIcons.rain
                                        : currentSky == 'Clear'
                                            ? WeatherIcons.day_sunny
                                            : WeatherIcons.day_cloudy,
                                size: 64,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Weather Forcast',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       for (int i = 0; i < 3; i++)
                //         ForcastItems(
                //           time: data['list'][i + 1]['dt'].toString(),
                //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                //                   'Clouds'
                //               ? WeatherIcons.cloud
                //               : data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Rain'
                //                   ? WeatherIcons.rain
                //                   : data['list'][i + 1]['weather'][0]['main'] ==
                //                           'Clear'
                //                       ? WeatherIcons.day_sunny
                //                       : WeatherIcons.day_cloudy,
                //           temperature:
                //               (data['list'][i + 1]['main']['temp'].toDouble() -
                //                           273.15)
                //                       .toStringAsFixed(2) +
                //                   '°C',
                //         ),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return ForcastItems(
                        time: DateFormat.j().format(
                            DateTime.parse(data['list'][index + 1]['dt_txt'])),
                        icon: data['list'][index + 1]['weather'][0]['main'] ==
                                'Clouds'
                            ? WeatherIcons.cloud
                            : data['list'][index + 1]['weather'][0]['main'] ==
                                    'Rain'
                                ? WeatherIcons.rain
                                : data['list'][index + 1]['weather'][0]
                                            ['main'] ==
                                        'Clear'
                                    ? WeatherIcons.day_sunny
                                    : WeatherIcons.day_cloudy,
                        temperature: (data['list'][index + 1]['main']['temp']
                                        .toDouble() -
                                    273.15)
                                .toStringAsFixed(2) +
                            '°C',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Additional Information',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                // const SizedBox(height: 5),
                Row(
                  children: [
                    AdditionalItems(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditionalItems(
                      icon: Icons.speed,
                      label: 'Wind Speed',
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalItems(
                      icon: Icons.thermostat,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
