import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class City {
  final String name;
  final String timeZone;
  final String flag;
  final String abbreviation;

  City({
    required this.name,
    required this.timeZone,
    required this.flag,
    required this.abbreviation,
  });

  DateTime get currentTime {
    tz.initializeTimeZones();
    final location = tz.getLocation(timeZone);
    return tz.TZDateTime.now(location);
  }

  String get formattedTime {
    final now = currentTime;
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final now = currentTime;
    return '${now.day}/${now.month}/${now.year}';
  }
} 