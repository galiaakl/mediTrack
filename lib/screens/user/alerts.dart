import 'package:flutter/material.dart';

class TrafficAlertsPage extends StatelessWidget {
  const TrafficAlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF33D4C8),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Traffic Alerts & Updates",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF33D4C8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Divider
            const Divider(color: Colors.teal, thickness: 1.0, height: 1.0),

            // Alerts List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: const [
                  AlertHeavyTraffic(),
                  Divider(height: 1),
                  AlertRoadblock(),
                  Divider(height: 1),
                  AlertAccident(),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF33D4C8),
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Maps'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'News',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/schedule');
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/maps');
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed('/news');
              break;
            case 4:
              Navigator.of(context).pushReplacementNamed('/account');
              break;
          }
        },
      ),
    );
  }
}

//Heavy Traffic
class AlertHeavyTraffic extends StatelessWidget {
  const AlertHeavyTraffic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertItem(
      title: "Heavy Traffic",
      time: "10 mins ago",
      location: "Beirut Ring Road, Eastbound",
      description: "Heavy traffic due to an accident.\nUse alternate routes.",
      child: Center(
        child: Image.network(
          'https://i.ibb.co/C3pk7WCj/erasebg-transformed-1.png', // Heavy traffic logo
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

//Roadblock
class AlertRoadblock extends StatelessWidget {
  const AlertRoadblock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertItem(
      title: "Roadblock",
      time: "5 mins ago",
      location: "Cola Roundabout",
      description:
      "Construction work causing delays.\nExpected clearance in 2 hours.",
      child: Center(
        child: Image.network(
          'https://i.ibb.co/3mQ4NQP0/erasebg-transformed.png', // Roadblock logo
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

//Accident
class AlertAccident extends StatelessWidget {
  const AlertAccident({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertItem(
      title: "Accident",
      time: "today, 09:15",
      location: "Hamra Street",
      description:
      "Accident reported has been cleared.\nTraffic flowing normally.",
      child: Center(
        child: Image.network(
          'https://i.ibb.co/3mQ4NQP0/erasebg-transformed.png', // Accident logo
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

//Alert item
class AlertItem extends StatelessWidget {
  final Widget child;
  final String title;
  final String time;
  final String location;
  final String description;

  const AlertItem({
    Key? key,
    required this.child,
    required this.title,
    required this.time,
    required this.location,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: child,
          ),
          const SizedBox(width: 12),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Time
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF33D4C8),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                // Location
                Text(
                  location,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
