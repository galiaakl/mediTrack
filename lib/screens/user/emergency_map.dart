import 'package:flutter/material.dart';

class EmergencyMapsScreen extends StatefulWidget {
  const EmergencyMapsScreen({super.key});

  @override
  State<EmergencyMapsScreen> createState() => _EmergencyMapsScreenState();
}

class _EmergencyMapsScreenState extends State<EmergencyMapsScreen> {
  bool facilityNearLocation = false;
  bool openNow = false;
  bool open24_7 = false;

  // Multi-selection quick filter states
  bool _showAll = true;
  bool _showHospitals = false;
  bool _showClinics = false;
  bool _showPharmacies = false;
  bool _showLabs = false;
  bool _showUCC = false;
  bool _showRC = false;

  String? selectedFacility = 'hospital1';

  List<String> facilities = [
    'Hospitals',
    'Clinics',
    'Pharmacies',
    'Labs (Medical Tests)',
    'Urgent Care Centers',
    'Rehabilitation Centers',
  ];

  List<String> services = [
    'Diagnostic Imaging',
    'Surgery Department',
    'Blood Bank',
    'Vaccination',
    'Covid-19 Testing',
    'Emergency Room',
    'Maternity Ward',
    'Physical Therapy',
    'Intensive Care Unit',
    'Dialysis Center',
  ];

  List<String> specialties = [
    'Pediatrics',
    'Cardiology',
    'Surgery',
    'Dermatology',
    'Mental Health',
    'Neurology',
    'Orthopedics',
    'Gynecology',
    'Oncology',
    'Urology',
    'Endocrinology',
    'Gastroenterology',
    'Pulmonology',
    'Ophthalmology',
    'ENT',
  ];

  List<bool> selectedFacilities = List.filled(6, false);
  List<bool> selectedServices = List.filled(10, false);
  List<bool> selectedSpecialties = List.filled(15, false);

  // Facilities
  Map<String, dynamic> facilityInfos = {
    'hospital1': {
      'name': 'LAU Medical Center Saint John\'s Hospital',
      'distance': '7 mins away',
      'is24_7': true,
      'position': const Offset(110, 355),
      'type': 'hospital',
    },
    'hospital2': {
      'name': 'General City Hospital',
      'distance': '12 mins away',
      'is24_7': true,
      'position': const Offset(220, 380),
      'type': 'hospital',
    },
    'hospital3': {
      'name': 'Memorial Hospital',
      'distance': '18 mins away',
      'is24_7': true,
      'position': const Offset(200, 20),
      'type': 'hospital',
    },
    'pharmacy1': {
      'name': 'Central Pharmacy',
      'distance': '5 mins away',
      'is24_7': false,
      'position': const Offset(350, 320),
      'type': 'pharmacy',
    },
    'pharmacy2': {
      'name': 'MediMart Pharmacy',
      'distance': '9 mins away',
      'is24_7': true,
      'position': const Offset(120, 180),
      'type': 'pharmacy',
    },
    'pharmacy3': {
      'name': 'Community Pharmacy',
      'distance': '15 mins away',
      'is24_7': false,
      'position': const Offset(280, 240),
      'type': 'pharmacy',
    },
    'lab1': {
      'name': 'ProHealth Laboratory',
      'distance': '8 mins away',
      'is24_7': false,
      'position': const Offset(160, 460),
      'type': 'lab',
    },
    'lab2': {
      'name': 'Diagnostic Labs',
      'distance': '14 mins away',
      'is24_7': false,
      'position': const Offset(310, 200),
      'type': 'lab',
    },
  };

  String? selectedFacilityKey;

  @override
  void initState() {
    super.initState();
    selectedFacilityKey = 'hospital1';
  }

  bool _shouldDisplayFacility(String type) {
    // If "All" is selected and no individual filters are selected, show everything
    if (_showAll &&
        !_showHospitals &&
        !_showClinics &&
        !_showPharmacies &&
        !_showLabs &&
        !_showUCC &&
        !_showRC)
      return true;

    // Check if the specific facility type is selected in quick filters
    if (type == 'hospital' && _showHospitals) return true;
    if (type == 'clinics' && _showClinics) return true;
    if (type == 'pharmacy' && _showPharmacies) return true;
    if (type == 'lab' && _showLabs) return true;
    if (type == 'UCC' && _showUCC) return true;
    if (type == 'RC' && _showRC) return true;

    // If any quick filter is selected but this facility type isn't, doesn't show
    if (_showHospitals ||
        _showClinics ||
        _showPharmacies ||
        _showLabs ||
        _showUCC ||
        _showRC)
      return false;

    // Check detailed filter selections as backup
    bool anyFacilitySelected = selectedFacilities.contains(true);
    if (!anyFacilitySelected) return true;

    if (type == 'hospital' && selectedFacilities[0]) return true;
    if (type == 'clinics' && selectedFacilities[1]) return true;
    if (type == 'pharmacy' && selectedFacilities[2]) return true;
    if (type == 'lab' && selectedFacilities[3]) return true;
    if (type == 'UCC' && selectedFacilities[4]) return true;
    if (type == 'RC' && selectedFacilities[5]) return true;

    return false;
  }

  // Toggle individual filter and update "All" state accordingly
  void _toggleFilter(String type) {
    setState(() {
      if (type == 'all') {
        // If All is off, turns on and everything else off
        if (!_showAll) {
          _showAll = true;
          _showHospitals = false;
          _showClinics = false;
          _showPharmacies = false;
          _showLabs = false;
          _showUCC = false;
          _showRC = false;
        }
        // If All is on, it stays on (can't deselect All without selecting something else)
      } else {
        // Toggle the filter
        if (type == 'hospitals') {
          _showHospitals = !_showHospitals;
        } else if (type == 'clinics') {
          _showClinics = !_showClinics;
        } else if (type == 'pharmacies') {
          _showPharmacies = !_showPharmacies;
        } else if (type == 'labs') {
          _showLabs = !_showLabs;
        } else if (type == 'UCC') {
          _showUCC = !_showUCC;
        } else if (type == 'RC') {
          _showRC = !_showRC;
        }

        // Update "All" button state
        if (_showHospitals ||
            _showClinics ||
            _showPharmacies ||
            _showLabs ||
            _showUCC ||
            _showRC) {
          // If any filter is selected, turn off "All"
          _showAll = false;
        } else {
          // If no filters are selected, turn on "All"
          _showAll = true;
        }

        // Filter selections
        selectedFacilities[0] = _showHospitals;
        selectedFacilities[1] = _showClinics;
        selectedFacilities[2] = _showPharmacies;
        selectedFacilities[3] = _showLabs;
        selectedFacilities[4] = _showUCC;
        selectedFacilities[5] = _showRC;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 252, 181, 181),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(255, 252, 181, 181),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const Spacer(),
                    Image.asset('assets/RedLogo.png', width: 40, height: 40),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Search section
              Container(
                color: const Color.fromARGB(255, 252, 181, 181),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for facility, service, or doctor',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {
                          _showFilterBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Multi-select
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      // All button
                      _buildQuickFilterButton(
                        icon: Icons.grid_view,
                        label: 'All',
                        isSelected: _showAll,
                        onTap: () {
                          _toggleFilter('all');
                        },
                      ),
                      const SizedBox(width: 8),
                      // Hospitals button
                      _buildQuickFilterButton(
                        icon: Icons.local_hospital,
                        label: 'Hospitals',
                        isSelected: _showHospitals,
                        onTap: () {
                          _toggleFilter('hospitals');
                        },
                      ),
                      // Clinics button
                      _buildQuickFilterButton(
                        icon: Icons.medical_services,
                        label: 'Clinics',
                        isSelected: _showClinics,
                        onTap: () {
                          _toggleFilter('clinics');
                        },
                      ),
                      const SizedBox(width: 8),
                      // Pharmacy button
                      _buildQuickFilterButton(
                        icon: Icons.local_pharmacy,
                        label: 'Pharmacy',
                        isSelected: _showPharmacies,
                        onTap: () {
                          _toggleFilter('pharmacies');
                        },
                      ),
                      const SizedBox(width: 8),
                      // Labs button
                      _buildQuickFilterButton(
                        icon: Icons.science,
                        label: 'Labs',
                        isSelected: _showLabs,
                        onTap: () {
                          _toggleFilter('labs');
                        },
                      ),
                      // UCC button
                      _buildQuickFilterButton(
                        icon: Icons.local_hospital,
                        label: 'Urgent Care Centers',
                        isSelected: _showUCC,
                        onTap: () {
                          _toggleFilter('UCC');
                        },
                      ),
                      // RC button
                      _buildQuickFilterButton(
                        icon: Icons.healing,
                        label: 'Rehabilitation Centers',
                        isSelected: _showRC,
                        onTap: () {
                          _toggleFilter('RC');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Map Section
              Expanded(
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/EmergencyMap.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // Location markers
                    ...facilityInfos.entries.map((entry) {
                      final key = entry.key;
                      final info = entry.value;
                      final position = info['position'] as Offset;
                      final type = info['type'] as String;
                      final distance = info['distance'] as String;

                      // Check if this facility should be displayed based on filters
                      if (!_shouldDisplayFacility(type)) {
                        return const SizedBox.shrink(); // Don't show this facility
                      }

                      // Icon color based on facility type
                      Color markerColor;
                      IconData markerIcon;
                      switch (type) {
                        case 'hospital':
                          markerColor = Colors.red;
                          markerIcon = Icons.local_hospital;
                          break;
                        case 'pharmacy':
                          markerColor = Colors.amber;
                          markerIcon = Icons.local_pharmacy;
                          break;
                        case 'lab':
                          markerColor = Colors.green;
                          markerIcon = Icons.science;
                          break;
                        default:
                          markerColor = Colors.blue;
                          markerIcon = Icons.location_on;
                      }

                      return Positioned(
                        left: position.dx,
                        top: position.dy,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFacilityKey =
                                  key == selectedFacilityKey ? null : key;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: markerColor,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  markerIcon,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (type == 'hospital')
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    253,
                                    134,
                                    125,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  distance,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),

                    // "You're here"
                    const Positioned(
                      left: 20,
                      top: 620,
                      child: Column(
                        children: [
                          Icon(Icons.my_location, size: 40, color: Colors.red),
                          Text(
                            'You are here',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              backgroundColor: Color.fromARGB(
                                156,
                                255,
                                255,
                                255,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Facility info popup
                    if (selectedFacilityKey != null)
                      _buildFacilityInfoPopup(
                        facilityInfos[selectedFacilityKey]!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF33D4C8),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
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

  Widget _buildQuickFilterButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityInfoPopup(Map<String, dynamic> info) {
    final position = info['position'] as Offset;
    final type = info['type'] as String;

    // Icon based on facility type
    IconData facilityIcon;
    Color facilityColor;
    switch (type) {
      case 'hospital':
        facilityIcon = Icons.local_hospital;
        facilityColor = Colors.red;
        break;
      case 'pharmacy':
        facilityIcon = Icons.local_pharmacy;
        facilityColor = Colors.amber;
        break;
      case 'lab':
        facilityIcon = Icons.science;
        facilityColor = Colors.green;
        break;
      default:
        facilityIcon = Icons.location_on;
        facilityColor = Colors.blue;
    }

    return Positioned(
      left: position.dx - 0,
      top: position.dy - 120,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: facilityColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(facilityIcon, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${info['distance']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (info['is24_7'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Open 24/7',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              // Make the entire container scrollable
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Facilities filter
                    _buildFilterSection(
                      title: 'Facilities',
                      icon: Icons.business,
                      color: const Color(0xFF00AAA0),
                      options: facilities,
                      selectedOptions: selectedFacilities,
                      onChanged: (index, value) {
                        setState(() {
                          selectedFacilities[index] = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Services filter
                    _buildFilterSection(
                      title: 'Services',
                      icon: Icons.medical_services,
                      color: const Color(0xFF00AAA0),
                      options: services,
                      selectedOptions: selectedServices,
                      onChanged: (index, value) {
                        setState(() {
                          selectedServices[index] = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Specialties filter
                    _buildFilterSection(
                      title: 'Specialties',
                      icon: Icons.local_hospital,
                      color: const Color(0xFF00AAA0),
                      options: specialties,
                      selectedOptions: selectedSpecialties,
                      onChanged: (index, value) {
                        setState(() {
                          selectedSpecialties[index] = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Location filter
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF00AAA0)),
                        const SizedBox(width: 8),
                        const Text(
                          'Location',
                          style: TextStyle(
                            color: Color(0xFF00AAA0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: facilityNearLocation,
                          activeColor: const Color(0xFF00AAA0),
                          onChanged: (value) {
                            setState(() {
                              facilityNearLocation = value!;
                            });
                          },
                        ),
                        const Text('Facility Near Current location'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Availability filter
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Color(0xFF00AAA0)),
                        const SizedBox(width: 8),
                        const Text(
                          'Availability',
                          style: TextStyle(
                            color: Color(0xFF00AAA0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: openNow,
                          activeColor: const Color(0xFF00AAA0),
                          onChanged: (value) {
                            setState(() {
                              openNow = value!;
                            });
                          },
                        ),
                        const Text('Open Now'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: open24_7,
                          activeColor: const Color(0xFF00AAA0),
                          onChanged: (value) {
                            setState(() {
                              open24_7 = value!;
                            });
                          },
                        ),
                        const Text('Open 24/7'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Apply Filter button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AAA0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Applies filters and update state in parent widget
                          this.setState(() {
                            // Updates quick filter buttons based on selected facilities
                            bool anySelected = selectedFacilities.contains(
                              true,
                            );

                            // If no facilities are selected, selects "All"
                            if (!anySelected) {
                              _showAll = true;
                              _showHospitals = false;
                              _showClinics = false;
                              _showPharmacies = false;
                              _showLabs = false;
                              _showUCC = false;
                              _showRC = false;
                            } else {
                              // Otherwise, updates quick filters based on facility selections
                              _showAll = false;
                              _showHospitals = selectedFacilities[0];
                              _showClinics = selectedFacilities[1];
                              _showPharmacies = selectedFacilities[2];
                              _showLabs = selectedFacilities[3];
                              _showUCC = selectedFacilities[4];
                              _showRC = selectedFacilities[5];

                              // If all quick filters selected, shows "All"
                              if (_showHospitals &&
                                  _showClinics &&
                                  _showPharmacies &&
                                  _showLabs &&
                                  _showUCC &&
                                  _showRC) {
                                _showAll = true;
                                _showHospitals = false;
                                _showClinics = false;
                                _showPharmacies = false;
                                _showLabs = false;
                                _showUCC = false;
                                _showRC = false;
                              }
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> options,
    required List<bool> selectedOptions,
    required Function(int, bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: const Text('Select'),
            children: [
              Container(
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(options[index]),
                      value: selectedOptions[index],
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: color,
                      onChanged: (value) {
                        onChanged(index, value!);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
