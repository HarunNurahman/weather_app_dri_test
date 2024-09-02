import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_dri_test/pages/widgets/daily-weather_item.dart';
import 'package:weather_app_dri_test/pages/widgets/hourly-weather_item.dart';
import 'package:weather_app_dri_test/shared/style.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_dri_test/shared/weather_helper.dart';
import 'package:xml2json/xml2json.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var url =
      'https://data.bmkg.go.id/DataMKG/MEWS/DigitalForecast/DigitalForecast-DKIJakarta.xml';

  List<dynamic> daerah = [];
  String? selectedDaerah;

  List<Map<String, String>> hourlyWeatherData = [];
  List<Map<String, String>> dailyWeatherData = [];

  Map<String, dynamic>? selectedWeatherData;

  Future<List<dynamic>> getArea() async {
    try {
      final result = await http.get(Uri.parse(url));
      final Xml2Json xml2Json = Xml2Json();
      xml2Json.parse(result.body);
      var json = xml2Json.toGData();

      Map<String, dynamic> map = jsonDecode(json);
      return map['data']['forecast']['area'];
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  void getWeatherData() {
    if (selectedWeatherData != null) {
      setState(() {
        hourlyWeatherData = [];
        dailyWeatherData = [];

        var hourlyData = selectedWeatherData!['parameter'][5]['timerange'];
        for (var data in hourlyData) {
          String datetime = data['datetime'];
          String temp = data['value'][0]['\$t'];

          hourlyWeatherData.add({
            'time': formatTime(datetime),
            'temp': temp,
          });
        }

        var dailyData = selectedWeatherData!['parameter'][2]['timerange'];
        for (var data in dailyData) {
          String datetime = data['datetime'];
          String temp = data['value'][0]['\$t'];

          dailyWeatherData.add({
            'time': formatTime(datetime),
            'temp': temp,
          });
        }
      });
    }
  }

  void getWeatherDataForSelectedArea(String areaDescription) {
    final area = daerah.firstWhere(
      (area) => area['description'] == areaDescription,
      orElse: () => null,
    );

    if (area != null) {
      setState(() {
        selectedWeatherData = area;
        getWeatherData();
      });
    }
  }

  String formatTime(String datetime) {
    try {
      if (datetime.length == 12) {
        String datePart = datetime.substring(0, 8);
        String timePart = datetime.substring(8, 12);

        DateTime parsedDatetime = DateTime.parse('${datePart}T$timePart');
        return DateFormat('HH:mm').format(parsedDatetime);
      } else {
        print('Unexpected datetime length: ${datetime.length}');
        return "Invalid Time";
      }
    } catch (e) {
      print('Error parsing datetime: $e');
      return "Invalid Time";
    }
  }

  @override
  void initState() {
    super.initState();
    getArea().then((value) {
      setState(() {
        daerah = value;
      });
    }).catchError((error) {
      print('Failed to fetch area data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              daerah.isEmpty
                  ? Center(child: CircularProgressIndicator(color: blueColor))
                  : content(),
              tabBar(),
              tabBarView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget content() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            blueColor,
            blueColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dropdown daerah
          DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(Icons.arrow_drop_down, color: whiteColor),
              style: blackTextStyle,
              hint: Text(
                selectedDaerah ?? 'Pilih Daerah',
                style: whiteTextStyle,
              ),
              onChanged: (value) {
                setState(() {
                  selectedDaerah = value!;
                  getWeatherDataForSelectedArea(selectedDaerah!);
                });
              },
              items: daerah.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem(
                    value: item['description'].toString(),
                    child: Text(
                      item['description'].toString(),
                    ));
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Daerah
          Text(
            selectedDaerah ?? 'Pilih Daerah',
            style: whiteTextStyle.copyWith(fontSize: 24),
          ),
          // Terakhir update dan deskripsi cuaca
          Text(
            DateFormat('EEEE, dd MMMM yyyy, HH:mm').format(DateTime.now()),
            style: whiteTextStyle,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Temperature
              Text(
                selectedWeatherData != null
                    ? '${selectedWeatherData?['parameter'][2]['timerange'][0]['value'][0]['\$t']}°'
                    : '',
                style: whiteTextStyle.copyWith(fontSize: 48),
              ),
              Column(
                children: [
                  // Icon cuaca
                  selectedWeatherData != null
                      ? parserIconWheather(
                            '${selectedWeatherData?['parameter'][6]['timerange'][0]['value']['\$t']}',
                            48,
                            whiteColor,
                          ) ??
                          Container()
                      : Container(),
                  const SizedBox(height: 8),
                  // Deskripsi cuaca
                  Text(
                    weatherParser(
                        '${selectedWeatherData?['parameter'][6]['timerange'][0]['value']['\$t']}'),
                    style: whiteTextStyle.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tabBar() {
    return TabBar(
      indicatorColor: blueColor,
      labelColor: blueColor,
      unselectedLabelColor: Colors.grey,
      tabs: const [
        Tab(text: 'Hari Ini'),
        Tab(text: 'Besok'),
      ],
    );
  }

  Widget tabBarView() {
    return Expanded(
      child: TabBarView(
        children: [
          // View cuaca hari ini
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyWeatherData.length,
            itemBuilder: (BuildContext context, int index) {
              final weather = hourlyWeatherData[index];
              return HourlyItem(
                jam: weather['time']!,
                iconUrl:
                    '${selectedWeatherData?['parameter'][6]['timerange'][index]['value']['\$t']}',
                temp: '${weather['temp']}°',
              );
            },
          ),
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dailyWeatherData.length,
            itemBuilder: (BuildContext context, int index) {
              final weather = dailyWeatherData[index];

              return DailyItem(
                jam: weather['time']!,
                iconUrl:
                    '${selectedWeatherData?['parameter'][6]['timerange'][index]['value']['\$t']}',
                temp: '${weather['temp']}°',
              );
            },
          ),
        ],
      ),
    );
  }
}
