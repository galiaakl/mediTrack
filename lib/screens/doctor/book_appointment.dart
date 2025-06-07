import 'package:flutter/material.dart';
import 'package:meditrack_new/screens/doctor/doctor_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  // TextEditingController to manage the search text
  final TextEditingController _searchController = TextEditingController();

  // List to store all doctors from the database
  List<Map<String, dynamic>> allDoctors = [];

  // List to store filtered doctors based on search
  List<Map<String, dynamic>> filteredDoctors = [];

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch doctors when the page initializes
    _fetchDoctors();

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  // Fetch doctors from Firestore
  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch doctors from Firestore collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('doctors').get();

      // If Firestore has doctors, use them
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          allDoctors = querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            // Add the document ID to the data
            data['id'] = doc.id;
            return data;
          }).toList();

          filteredDoctors = List.from(allDoctors);
        });
      } else {
        // If no doctors in Firestore, use the local data and populate Firestore
        await _populateFirestoreWithLocalData();
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      // If error occurs, use local data
      _useLocalDoctorsData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to populate Firestore with local doctor data
  Future<void> _populateFirestoreWithLocalData() async {
    try {
      // Add local doctors to Firestore
      for (var doctor in _getLocalDoctorsData()) {
        await FirebaseFirestore.instance.collection('doctors').add(doctor);
      }

      // Fetch doctors again after populating
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('doctors').get();

      setState(() {
        allDoctors = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        filteredDoctors = List.from(allDoctors);
      });
    } catch (e) {
      print('Error populating Firestore: $e');
      // If error occurs, use local data
      _useLocalDoctorsData();
    }
  }

  // Use local doctors data if Firestore is not available
  void _useLocalDoctorsData() {
    setState(() {
      allDoctors = _getLocalDoctorsData();
      filteredDoctors = List.from(allDoctors);
    });
  }

  // Local doctors data
  List<Map<String, dynamic>> _getLocalDoctorsData() {
    return [
      {
        'name': 'Dr. Floyd Miles',
        'specialty': 'Pediatrics',
        'picture': 'assets/Dr1.png',
        'bio': 'Experienced pediatrician with 10 years of practice. Specializes in child development and preventive care.',
        'tags': ['pediatric', 'children', 'development'],
      },
      {
        'name': 'Dr. Marvin McKinney',
        'specialty': 'Nephrologyist',
        'picture': 'assets/Dr2.png',
        'bio': 'Board-certified nephrologist specializing in kidney disorders and hypertension.',
        'tags': ['kidney', 'hypertension', 'dialysis'],
      },
      {
        'name': 'Dr. Guy Hawkins',
        'specialty': 'Dentist',
        'picture': 'assets/Dr4.png',
        'bio': 'Gentle dental care for all ages. Specializes in cosmetic dentistry and oral surgery.',
        'tags': ['teeth', 'dental', 'mouth', 'cosmetic'],
      },
      {
        'name': 'Dr. Savannah Nguyen',
        'specialty': 'Urologyist',
        'picture': 'assets/Dr3.png',
        'bio': 'Specializes in urologic oncology and minimally invasive surgical techniques.',
        'tags': ['urology', 'kidney', 'bladder'],
      },
      {
        'name': 'Dr. Emily Johnson',
        'specialty': 'Cardiologist',
        'reviews': '212 reviews',
        'picture': 'assets/Dr5.png',
        'bio': 'Heart specialist with expertise in interventional cardiology and cardiac imaging.',
        'tags': ['heart', 'cardio', 'chest pain', 'blood pressure'],
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Dermatologist',
        'picture': 'assets/Dr6.png',
        'bio': 'Board-certified dermatologist specializing in skin conditions, cosmetic procedures, and skin cancer treatment.',
        'tags': ['skin', 'acne', 'rash', 'eczema'],
      },
      {
        'name': 'Dr. Sarah Williams',
        'specialty': 'Ophthalmologist',
        'picture': 'assets/Dr5.png',
        'bio': 'Eye care specialist focusing on vision correction, cataract surgery, and retinal disorders.',
        'tags': ['eyes', 'vision', 'glasses', 'cataracts'],
      },
      {
        'name': 'Dr. James Rodriguez',
        'specialty': 'ENT Specialist',
        'picture': 'assets/Dr1.png',
        'bio': 'Ear, nose, and throat specialist with expertise in sleep apnea and sinus disorders.',
        'tags': ['ear', 'nose', 'throat', 'hearing', 'sinuses'],
      },
      {
        'name': 'Dr. Patricia Moore',
        'specialty': 'Nutritionist',
        'picture': 'assets/Dr3.png',
        'bio': 'Certified nutritionist focusing on weight management, sports nutrition, and medical diet therapy.',
        'tags': ['diet', 'nutrition', 'weight', 'metabolism'],
      },
      {
        'name': 'Dr. Robert Kim',
        'specialty': 'Neurologist',
        'picture': 'assets/Dr2.png',
        'bio': 'Specializes in treating disorders of the brain, spinal cord, and peripheral nerves.',
        'tags': ['brain', 'nervous system', 'headache', 'stroke'],
      },
      {
        'name': 'Dr. Linda Taylor',
        'specialty': 'Gynecologist',
        'picture': 'assets/Dr3.png',
        'bio': 'Women\'s health specialist with focus on reproductive health and fertility treatments.',
        'tags': ['women', 'pregnancy', 'fertility'],
      },
      {
        'name': 'Dr. Thomas Wright',
        'specialty': 'Pulmonologist',
        'picture': 'assets/Dr6.png',
        'bio': 'Lung specialist treating asthma, COPD, sleep apnea, and other respiratory conditions.',
        'tags': ['lungs', 'breathing', 'asthma', 'respiratory'],
      },
    ];
  }

  // Search functionality
  void _onSearchChanged() {
    _filterDoctors();
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        filteredDoctors = List.from(allDoctors);
      });
      return;
    }

    setState(() {
      filteredDoctors = allDoctors.where((doctor) {
        // Search by name
        if (doctor['name'].toLowerCase().contains(query)) {
          return true;
        }

        // Search by specialty
        if (doctor['specialty'].toLowerCase().contains(query)) {
          return true;
        }

        // Search by tags
        if (doctor.containsKey('tags') && doctor['tags'] is List) {
          List<String> tags = List<String>.from(doctor['tags']);
          for (var tag in tags) {
            if (tag.toLowerCase().contains(query)) {
              return true;
            }
          }
        }

        return false;
      }).toList();
    });
  }

  // Update the search box with hashtag
  void _updateSearchWithHashtag(String hashtag) {
    setState(() {
      _searchController.text = hashtag.substring(1); // Remove the # character
    });
  }

  // Update the search box with specialty
  void _updateSearchWithSpecialty(String specialty) {
    setState(() {
      _searchController.text = specialty;
    });
  }

  @override
  void dispose() {
    // Clean up the controller and listener when the widget is disposed
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightTealColor = Color.fromARGB(255, 191, 252, 252);
    final tealColor = Color(0xFF33D4C8);

    // List of hashtags
    final List<String> hashtags = [
      '#heart',
      '#teeth',
      '#urology',
      '#eyes',
      '#mouth',
      '#diet',
      '#pediatric',
      '#brain',
      '#skin',
      '#lungs',
    ];

    // List of specialties
    final List<Map<String, dynamic>> specialties = [
      {
        'icon': Icons.favorite,
        'color': Color.fromARGB(255, 255, 71, 51),
        'title': 'Cardiologist',
      },
      {
        'icon': Icons.visibility,
        'color': Color.fromARGB(255, 82, 177, 245),
        'title': 'Ophthalmologist',
      },
      {
        'icon': Icons.hearing,
        'color': Color.fromARGB(255, 251, 224, 135),
        'title': 'ENT',
      },
      {
        'icon': Icons.female,
        'color': Color.fromARGB(255, 250, 108, 195),
        'title': 'Gynecologist',
      },
      {
        'icon': Icons.accessibility_new,
        'color': Color.fromARGB(255, 197, 138, 255),
        'title': 'Physiotherapist',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: lightTealColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tealColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Image.asset('assets/LogoNoText.png', height: 30),
      ),
      body: Column(
        children: [
          Container(
            color: lightTealColor,
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Find verified specialists!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tealColor,
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController, // Add the controller here
                    decoration: InputDecoration(
                      hintText: 'Example "heart"',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hashtags
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: hashtags.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      // Update search text with selected hashtag
                      _updateSearchWithHashtag(hashtags[index]);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: tealColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: tealColor.withOpacity(0.5)),
                      ),
                    ),
                    child: Text(
                      hashtags[index],
                      style: TextStyle(fontSize: 14, color: tealColor),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom section
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(tealColor),
              ),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Specialties Title
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Top Specialties',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Top Specialties
                  Container(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: specialties.length,
                      itemBuilder: (context, index) {
                        final specialty = specialties[index];
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                // Update search text with selected specialty
                                _updateSearchWithSpecialty(specialty['title']);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: specialty['color'],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        specialty['icon'],
                                        color: Color.fromARGB(
                                          215,
                                          255,
                                          255,
                                          255,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    Text(
                                      specialty['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Doctors Title - Shows "Popular Doctors" or "Search Results" based on search state
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _searchController.text.isEmpty ? 'Popular Doctors' : 'Search Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Show message if no doctors found
                  if (filteredDoctors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No doctors found for "${_searchController.text}"',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Doctors List
                  if (filteredDoctors.isNotEmpty)
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to doctor detail page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorProfilePage(
                                      doctorId: doctor['id'],
                                      doctorName: doctor['name'],
                                      specialty: doctor['specialty'],
                                      imageAsset: doctor['picture'],
                                      bio: doctor['bio'] ?? 'No bio available',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Doctor image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        doctor['picture'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Doctor info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            doctor['specialty'],
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                          if (doctor.containsKey('bio') && doctor['bio'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                doctor['bio'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF33D4C8),
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // Highlight the Schedule tab
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