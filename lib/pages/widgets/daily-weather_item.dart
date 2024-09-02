import 'package:flutter/material.dart';
import 'package:weather_app_dri_test/shared/style.dart';
import 'package:weather_app_dri_test/shared/weather_helper.dart';

class DailyItem extends StatelessWidget {
  final String jam;
  final String iconUrl;
  final String temp;
  const DailyItem({
    super.key,
    required this.jam,
    required this.iconUrl,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            children: [
              // Jam
              Text(jam, style: blackTextStyle.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              // Icon cuaca
              parserIconWheather(iconUrl, 42, blueColor),
              const SizedBox(height: 12),
              // Temp
              Text(temp, style: blackTextStyle.copyWith(fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }
}
