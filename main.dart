import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1E2630),
        brightness: Brightness.dark,
      ),
      home: const WorldClockPage(),
    );
  }
}

class WorldClockPage extends StatefulWidget {
  const WorldClockPage({super.key});

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage> {
  late Timer _timer;
  int _selectedIndex = 0;
  Set<String> _favorites = {};
  
  final List<Map<String, dynamic>> _cities = [
    {'name': 'New York', 'offset': -5, 'flag': '🇺🇸'},
    {'name': 'Los Angeles', 'offset': -8, 'flag': '🇺🇸'},
    {'name': 'Mexico City', 'offset': -6, 'flag': '🇲🇽'},
    {'name': 'São Paulo', 'offset': -3, 'flag': '🇧🇷'},
    {'name': 'Buenos Aires', 'offset': -3, 'flag': '🇦🇷'},
    {'name': 'London', 'offset': 0, 'flag': '🇬🇧'},
    {'name': 'Paris', 'offset': 1, 'flag': '🇫🇷'},
    {'name': 'Berlin', 'offset': 1, 'flag': '🇩🇪'},
    {'name': 'Rome', 'offset': 1, 'flag': '🇮🇹'},
    {'name': 'Cairo', 'offset': 2, 'flag': '🇪🇬'},
    {'name': 'Istanbul', 'offset': 3, 'flag': '🇹🇷'},
    {'name': 'Amman', 'offset': 3, 'flag': '🇯🇴'},
    {'name': 'Moscow', 'offset': 3, 'flag': '🇷🇺'},
    {'name': 'Dubai', 'offset': 4, 'flag': '🇦🇪'},
    {'name': 'Mumbai', 'offset': 5.5, 'flag': '🇮🇳'},
    {'name': 'Bangkok', 'offset': 7, 'flag': '🇹🇭'},
    {'name': 'Jakarta', 'offset': 7, 'flag': '🇮🇩'},
    {'name': 'Hong Kong', 'offset': 8, 'flag': '🇭🇰'},
    {'name': 'Singapore', 'offset': 8, 'flag': '🇸🇬'},
    {'name': 'Seoul', 'offset': 9, 'flag': '🇰🇷'},
    {'name': 'Tokyo', 'offset': 9, 'flag': '🇯🇵'},
    {'name': 'Sydney', 'offset': 11, 'flag': '🇦🇺'},
    {'name': 'Auckland', 'offset': 13, 'flag': '🇳🇿'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites') ?? '[]';
    setState(() {
      _favorites = Set.from(json.decode(favoritesJson));
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', json.encode(_favorites.toList()));
  }

  void _toggleFavorite(String cityName) {
    setState(() {
      if (_favorites.contains(cityName)) {
        _favorites.remove(cityName);
      } else {
        _favorites.add(cityName);
      }
      _saveFavorites();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  DateTime _getTime(double offset) {
    final now = DateTime.now().toUtc();
    final hours = offset.floor();
    final minutes = ((offset - hours) * 60).round();
    return DateTime.utc(
      now.year,
      now.month,
      now.day,
      (now.hour + hours) % 24,
      now.minute + minutes,
    );
  }

  Widget _buildCityList(List<Map<String, dynamic>> cities) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final time = _getTime(city['offset'].toDouble());
        final isFavorite = _favorites.contains(city['name']);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3441),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2630),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    city['flag'],
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5EEAD4).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'UTC${city['offset'] >= 0 ? '+' : ''}${city['offset']}',
                          style: const TextStyle(
                            color: Color(0xFF5EEAD4),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTime(time),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? const Color(0xFF5EEAD4) : Colors.grey,
                  ),
                  onPressed: () => _toggleFavorite(city['name']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> displayedCities = _selectedIndex == 1
        ? _cities.where((city) => _favorites.contains(city['name'])).toList()
        : _cities;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2630),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E2630),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/3176/3176388.png',
              height: 24,
              color: const Color(0xFF5EEAD4),
            ),
            const SizedBox(width: 8),
            const Text(
              'World Clock',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildCityList(displayedCities),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2A3441),
        selectedItemColor: const Color(0xFF5EEAD4),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
