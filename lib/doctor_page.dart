import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DoctorProfilePage extends StatefulWidget {
  final String? doctorId;
  final String doctorName;
  final String specialty;
  final String imageAsset;
  final String bio;

  const DoctorProfilePage({
    Key? key,
    this.doctorId,
    this.doctorName = 'Dr. Floyd Miles',
    this.specialty = 'Pediatrics',
    this.imageAsset = 'assets/Dr1.png',
    this.bio = 'Experienced pediatrician with 10 years of practice. Specializes in child development and preventive care.',
  }) : super(key: key);

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isLoading = false;

  // Map to store available times for each date (could be fetched from Firestore)
  Map<String, List<String>> _availableTimes = {};

  @override
  void initState() {
    super.initState();
    _loadDoctorAvailability();
  }

  // Load doctor availability from Firestore
  Future<void> _loadDoctorAvailability() async {
    if (widget.doctorId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Try to fetch doctor availability from Firestore
      DocumentSnapshot availabilityDoc = await FirebaseFirestore.instance
          .collection('doctor_availability')
          .doc(widget.doctorId)
          .get();

      if (availabilityDoc.exists && availabilityDoc.data() != null) {
        Map<String, dynamic> data = availabilityDoc.data() as Map<String, dynamic>;

        setState(() {
          // Convert Firestore data to our format
          data.forEach((key, value) {
            if (value is List) {
              _availableTimes[key] = List<String>.from(value);
            }
          });
        });
      } else {
        // If no availability data exists, generate some sample data
        _generateSampleAvailability();
      }
    } catch (e) {
      print('Error loading doctor availability: $e');
      // Generate sample data if there's an error
      _generateSampleAvailability();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Generate sample availability data
  void _generateSampleAvailability() {
    // Generate availability for next 14 days
    for (int i = 0; i < 14; i++) {
      DateTime date = DateTime.now().add(Duration(days: i));

      // Format the date as a string key (yyyy-MM-dd)
      String dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Randomly select 3-7 time slots as available for this date
      List<String> availableSlots = [];
      int availableCount = 3 + (date.day % 5); // 3-7 slots based on day number

      // Add some time slots based on a simple algorithm (not truly random but deterministic)
      for (int j = 0; j < _timeSlots.length; j++) {
        if ((j + date.day) % 3 == 0 && availableSlots.length < availableCount) {
          availableSlots.add(_timeSlots[j]);
        }
      }

      _availableTimes[dateKey] = availableSlots;
    }
  }

  // Get available times for the selected date
  List<String> _getAvailableTimesForSelectedDate() {
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _availableTimes[dateKey] ?? [];
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  // Book appointment
  Future<void> _bookAppointment() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Add appointment to Firestore
      await FirebaseFirestore.instance.collection('appointments').add({
        'doctorId': widget.doctorId,
        'doctorName': widget.doctorName,
        'specialty': widget.specialty,
        'date': Timestamp.fromDate(_selectedDate),
        'time': _selectedTime,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
        // You would typically add userId here from authentication
        // 'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      // Update availability to remove the booked slot
      String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
      List<String> updatedSlots = List.from(_getAvailableTimesForSelectedDate())
        ..remove(_selectedTime);

      setState(() {
        _availableTimes[dateKey] = updatedSlots;
        _selectedTime = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error booking appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tealColor = Color(0xFF33D4C8);
    final availableTimes = _getAvailableTimesForSelectedDate();

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(tealColor),
        ),
      )
          : Stack(
        children: [
          // Doctor image with gradient overlay at the top
          Container(
            height: 300,
            width: double.infinity,
            child: Stack(
              children: [
                // Doctor image
                Image.asset(
                  widget.imageAsset,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                // Doctor name and specialty at the bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctorName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.specialty,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content (scrollable)
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 280),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoItem(
                          context,
                          '4.8',
                          'Ratings',
                          Icons.star,
                          Color(0xFFFFC107),
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          context,
                          '8+',
                          'Years Exp',
                          Icons.work,
                          Color(0xFF33D4C8),
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          context,
                          '300+',
                          'Patients',
                          Icons.people,
                          Color(0xFF33D4C8),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // About section
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.bio,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Schedule an appointment section
                    Text(
                      'Schedule an Appointment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date selector
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 14, // Show next 14 days
                        itemBuilder: (context, index) {
                          DateTime date = DateTime.now().add(Duration(days: index));
                          bool isSelected = _selectedDate.day == date.day &&
                              _selectedDate.month == date.month &&
                              _selectedDate.year == date.year;
                          String dateKey = DateFormat('yyyy-MM-dd').format(date);
                          bool hasSlots = (_availableTimes[dateKey] ?? []).isNotEmpty;

                          return Container(
                            margin: EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: hasSlots
                                  ? () {
                                setState(() {
                                  _selectedDate = date;
                                  _selectedTime = null;
                                });
                              }
                                  : null,
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? tealColor
                                      : (hasSlots ? Colors.white : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? tealColor
                                        : (hasSlots ? Colors.grey.shade300 : Colors.grey.shade300),
                                  ),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('EEE').format(date), // Day of week
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : (hasSlots ? Colors.black : Colors.grey),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      DateFormat('d').format(date), // Day number
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : (hasSlots ? Colors.black : Colors.grey),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM').format(date), // Month
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white
                                            : (hasSlots ? Colors.black : Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),

                    // Time selector
                    Text(
                      'Select Time Slot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    availableTimes.isEmpty
                        ? Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'No available slots for ${_formatDate(_selectedDate)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                        : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTimes.map((time) {
                        bool isSelected = _selectedTime == time;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? tealColor : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                isSelected ? tealColor : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),

                    // Book Now button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedTime != null ? _bookAppointment : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tealColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context,
      String value,
      String label,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }
}