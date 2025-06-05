import 'package:flutter/material.dart';
import 'package:meditrack_new/signup_healthcare.dart';

class PracticeDetailsPage extends StatefulWidget {
  const PracticeDetailsPage({super.key});

  @override
  State<PracticeDetailsPage> createState() => _PracticeDetailsPageState();
}

class _PracticeDetailsPageState extends State<PracticeDetailsPage> {
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _workAddressController = TextEditingController();
  final TextEditingController _newLanguageController = TextEditingController();
  final TextEditingController _clinicEmailController = TextEditingController();

  // Days of availability
  final List<String> _daysShort = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<bool> _selectedDays = List.generate(7, (_) => false);

  // Time selection for each day
  final List<bool> _timeVisible = List.generate(7, (_) => false);
  final List<int> _startHours = List.generate(7, (_) => 9);
  final List<int> _startMinutes = List.generate(7, (_) => 0);
  final List<bool> _startAmPm = List.generate(
    7,
        (_) => true,
  ); // true = AM, false = PM
  final List<int> _endHours = List.generate(7, (_) => 5);
  final List<int> _endMinutes = List.generate(7, (_) => 0);
  final List<bool> _endAmPm = List.generate(
    7,
        (_) => false,
  ); // true = AM, false = PM

  // Online booking toggle
  bool _offerOnlineBooking = false;

  // Languages spoken
  final List<String> _selectedLanguages = ['Arabic', 'English'];

  void _addLanguage() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('Add Language'),
        content: TextField(
          controller: _newLanguageController,
          decoration: InputDecoration(
            hintText: 'Enter language',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newLanguageController.text.trim().isNotEmpty) {
                setState(() {
                  _selectedLanguages.add(
                    _newLanguageController.text.trim(),
                  );
                  _newLanguageController.clear();
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeLanguage(String language) {
    setState(() {
      _selectedLanguages.remove(language);
    });
  }

  // Time selector widget
  Widget _buildTimeSelector(int dayIndex) {
    return Visibility(
      visible: _timeVisible[dayIndex],
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 15),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_daysShort[dayIndex]} - Available Hours',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('From: ', style: TextStyle(fontSize: 14)),
                SizedBox(width: 5),
                // Hour selection
                Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _startHours[dayIndex],
                      icon: Icon(Icons.arrow_drop_down, size: 15),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _startHours[dayIndex] = newValue;
                          });
                        }
                      },
                      items:
                      List.generate(12, (i) => i + 1)
                          .map(
                            (hour) => DropdownMenuItem<int>(
                          value: hour,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              '$hour',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
                Text(
                  ' : ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Minute selection
                Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _startMinutes[dayIndex],
                      icon: Icon(Icons.arrow_drop_down, size: 15),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _startMinutes[dayIndex] = newValue;
                          });
                        }
                      },
                      items:
                      [0, 15, 30, 45]
                          .map(
                            (minute) => DropdownMenuItem<int>(
                          value: minute,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                // AM/PM selection
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<bool>(
                      value: _startAmPm[dayIndex],
                      icon: Icon(Icons.arrow_drop_down, size: 15),
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _startAmPm[dayIndex] = newValue;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem<bool>(
                          value: true,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('AM', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        DropdownMenuItem<bool>(
                          value: false,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('PM', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('To:     ', style: TextStyle(fontSize: 14)),
                SizedBox(width: 5),
                // Hour selection
                Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _endHours[dayIndex],
                      icon: Icon(Icons.arrow_drop_down, size: 15),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _endHours[dayIndex] = newValue;
                          });
                        }
                      },
                      items:
                      List.generate(12, (i) => i + 1)
                          .map(
                            (hour) => DropdownMenuItem<int>(
                          value: hour,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              '$hour',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
                Text(
                  ' : ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Minute selection
                Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _endMinutes[dayIndex],
                      icon: Icon(Icons.arrow_drop_down, size: 15),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _endMinutes[dayIndex] = newValue;
                          });
                        }
                      },
                      items:
                      [0, 15, 30, 45]
                          .map(
                            (minute) => DropdownMenuItem<int>(
                          value: minute,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                // AM/PM selection
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<bool>(
                      value: _endAmPm[dayIndex],
                      icon: Icon(Icons.arrow_drop_down, size: 15),
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _endAmPm[dayIndex] = newValue;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem<bool>(
                          value: true,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('AM', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        DropdownMenuItem<bool>(
                          value: false,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('PM', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF33D4C8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Healthcare Professional',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            color: Color.fromARGB(255, 191, 252, 252),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Practice Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33D4C8),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Choose where you consult and when you are available',
                  style: TextStyle(fontSize: 14, color: Color(0xFF33D4C8)),
                ),
              ],
            ),
          ),
          // Form section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clinic/Hospital Name
                  Text(
                    'Clinic / Hospital Name (Optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _clinicNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter clinic name',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Work Address
                  Text(
                    'Work Address',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _workAddressController,
                    decoration: InputDecoration(
                      hintText: 'Enter work address',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Availability
                  Text(
                    'Availability',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDays[index] = !_selectedDays[index];
                                _timeVisible[index] = _selectedDays[index];
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                _selectedDays[index]
                                    ? Color(0xFF33D4C8)
                                    : Colors.white,
                                border: Border.all(
                                  color:
                                  _selectedDays[index]
                                      ? Color(0xFF33D4C8)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _daysShort[index],
                                  style: TextStyle(
                                    color:
                                    _selectedDays[index]
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      Column(
                        children: List.generate(
                          7,
                              (index) => _buildTimeSelector(index),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Online Booking
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offer Online Booking?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: _offerOnlineBooking,
                        onChanged: (value) {
                          setState(() {
                            _offerOnlineBooking = value;
                          });
                        },
                        activeColor: Color(0xFF33D4C8),
                      ),
                    ],
                  ),

                  // Clinic Email for Online Booking
                  Visibility(
                    visible: _offerOnlineBooking,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          'Clinic Email Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _clinicEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter clinic email',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Online bookings will be sent to this email.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Languages Spoken
                  Text(
                    'Languages Spoken',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedLanguages.map(
                            (language) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(language),
                              SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeLanguage(language),
                                child: Icon(Icons.close, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _addLanguage,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                size: 16,
                                color: Color(0xFF33D4C8),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Add',
                                style: TextStyle(color: Color(0xFF33D4C8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => SignUpHealthcarePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF33D4C8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Finalize',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
