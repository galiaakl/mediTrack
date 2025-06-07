import 'package:flutter/material.dart';
import 'maps.dart';
import 'home_page.dart';
import 'profile.dart';
import 'alerts.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _selectedTabIndex = 0;

  // For reschedule dialog
  int _selectedDateIndex = 2; // Default selected date (26 March)
  int _selectedTimeIndex = 3; // Default selected time (16:00)

  // Sample dates for reschedule
  final List<Map<String, dynamic>> _availableDates = [
    {'day': '23', 'month': 'March', 'enabled': true},
    {'day': '25', 'month': 'March', 'enabled': true},
    {'day': '26', 'month': 'March', 'enabled': true},
    {'day': '30', 'month': 'March', 'enabled': true},
    {'day': '2', 'month': 'April', 'enabled': true},
  ];

  // Sample times for reschedule
  final List<String> _availableTimes = [
    '9:00',
    '12:00',
    '13:00',
    '16:00',
    '16:30',
  ];

  // Lists to hold appointments for each tab
  List<Map<String, dynamic>> upcomingAppointments = [
    {
      'name': 'Dr. Erik Jules',
      'specialty': 'Heart Surgeon- LAU Medical Center',
      'time': '10:00 AM',
      'date': '12/09/25',
      'status': 'Confirmed',
      'profile': 'assets/Dr2.png',
      'id': 1,
    },
    {
      'name': 'Dr. Perla Stone',
      'specialty': 'Dentist - Beirut Clinics',
      'time': '5:00 PM',
      'date': '04/08/25',
      'status': 'Unconfirmed',
      'profile': 'assets/Dr3.png',
      'id': 2,
    },
  ];

  List<Map<String, dynamic>> completedAppointments = [
    {
      'name': 'Dr. Karl Gibbs',
      'specialty': 'Pediatrician - Byblos Medical Center',
      'time': '11:00 AM',
      'date': '22/07/25',
      'status': 'Completed',
      'profile': 'assets/Dr4.png',
      'id': 3,
    },
    {
      'name': 'Dr. Sally Strong',
      'specialty': 'Cardiologist - Tyre Clinics',
      'time': '02:30 PM',
      'date': '10/09/25',
      'status': 'Completed',
      'profile': 'assets/Dr5.png',
      'id': 4,
    },
  ];

  List<Map<String, dynamic>> canceledAppointments = [
    {
      'name': 'Dr. John Wilson',
      'specialty': 'Physiotherapist- LAU Medical Center',
      'time': '03:15 PM',
      'date': '09/09/25',
      'status': 'Canceled',
      'profile': 'assets/Dr6.png',
      'id': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 20),
            child: Text(
              'My Schedule',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Tab buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _buildTabButton('Upcoming', 0),
                  _buildTabButton('Completed', 1),
                  _buildTabButton('Canceled', 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Appointment lists based on selected tab
          Expanded(
            child:
            _selectedTabIndex == 0
                ? _buildAppointmentList(
              upcomingAppointments,
              showButtons: true,
            )
                : _selectedTabIndex == 1
                ? _buildAppointmentList(completedAppointments)
                : _buildAppointmentList(canceledAppointments),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF33D4C8),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
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
            // Navigate to HomePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
            // Navigate to SchedulePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SchedulePage()),
              );
              break;
            case 2:
            // Navigate to MapsScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapsScreen()),
              );
              break;
            case 3:
            // Navigate to TrafficAlertsPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrafficAlertsPage()),
              );
              break;
            case 4:
            // Navigate to ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF33D4C8) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(
      List<Map<String, dynamic>> appointments, {
        bool showButtons = false,
      }) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(
          appointment,
          showButtons: showButtons,
          onCancel: () => _showCancelDialog(appointment),
          onReschedule: () => _showRescheduleDialog(appointment),
        );
      },
    );
  }

  Widget _buildAppointmentCard(
      Map<String, dynamic> appointment, {
        bool showButtons = false,
        VoidCallback? onCancel,
        VoidCallback? onReschedule,
      }) {
    bool isConfirmed = appointment['status'] == 'Confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['specialty'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    appointment['profile'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.person, color: Colors.grey.shade600),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  appointment['time'],
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  appointment['date'],
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (appointment['status'] != 'Completed' &&
                    appointment['status'] != 'Canceled')
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          isConfirmed ? Icons.check_circle : Icons.cancel,
                          size: 18,
                          color: isConfirmed ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointment['status'],
                          style: TextStyle(
                            color: isConfirmed ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (showButtons)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF33D4C8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF33D4C8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onReschedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF33D4C8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Reschedule',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // New Reschedule Dialog
  void _showRescheduleDialog(Map<String, dynamic> appointment) {
    _selectedDateIndex = 2; // Reset to default selected date
    _selectedTimeIndex = 3; // Reset to default selected time

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Date selection
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dates
                      SizedBox(
                        height: 92,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableDates.length,
                          itemBuilder: (context, index) {
                            final date = _availableDates[index];
                            final isSelected = _selectedDateIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDateIndex = index;
                                });
                              },
                              child: Container(
                                width: 76,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color:
                                  isSelected
                                      ? const Color(0xFF33D4C8)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      date['day'],
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      date['month'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Time heading
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time selection
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(_availableTimes.length, (
                            index,
                            ) {
                          final isSelected = _selectedTimeIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTimeIndex = index;
                              });
                            },
                            child: Container(
                              width: 76,
                              height: 42,
                              decoration: BoxDecoration(
                                color:
                                isSelected
                                    ? const Color(0xFF33D4C8)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                  isSelected
                                      ? const Color(0xFF33D4C8)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _availableTimes[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      // Reschedule button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Update the appointment with new date and time
                            final selectedDate =
                            _availableDates[_selectedDateIndex];
                            final selectedTime =
                            _availableTimes[_selectedTimeIndex];

                            setState(() {
                              appointment['date'] =
                              "${selectedDate['day']}/${selectedDate['month']}";
                              appointment['time'] = selectedTime;
                            });

                            Navigator.pop(context);

                            // Show confirmation snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Appointment rescheduled successfully',
                                ),
                                backgroundColor: Color(0xFF33D4C8),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF33D4C8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Reschedule',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Remove the appointment from upcoming and add to canceled
              setState(() {
                upcomingAppointments.removeWhere(
                      (a) => a['id'] == appointment['id'],
                );
                appointment['status'] = 'Canceled';
                canceledAppointments.add(appointment);
              });
              Navigator.of(context).pop();

              // Show confirmation snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment canceled successfully'),
                  backgroundColor: Color(0xFF33D4C8),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
