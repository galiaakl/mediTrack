import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'healthcarethirdpage.dart';

class ProfessionalInfoPage extends StatefulWidget {
  const ProfessionalInfoPage({Key? key}) : super(key: key);

  @override
  State<ProfessionalInfoPage> createState() => _ProfessionalInfoPageState();
}

class _ProfessionalInfoPageState extends State<ProfessionalInfoPage> {
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _selectedSpeciality;
  String? _selectedSubSpeciality;
  bool _isLoading = false;

  final List<String> _specialities = [
    'Cardiologist',
    'Neurologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic Surgeon',
    'Psychiatrist',
  ];

  final List<String> _allSubSpecialities = [
    'Interventional Cardiology (EP)',
    'Heart Failure',
    'Nuclear Cardiology',
    'Stroke',
    'Epilepsy',
    'Movement Disorders',
    'Pediatric Dermatology',
    'Dermatopathology',
    'Mohs Surgery',
    'Neonatology',
    'Pediatric Cardiology',
    'Pediatric Neurology',
    'Sports Medicine',
    'Spine Surgery',
    'Hand Surgery',
    'Child & Adolescent',
    'Addiction',
    'Geriatric Psychiatry',
  ];

  // Add new method to save data to Firebase
  Future<void> _saveProfessionalInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      String userId = currentUser.uid;

      // Create data to save
      Map<String, dynamic> professionalData = {
        'specialty': _selectedSpeciality,
        'subSpecialty': _selectedSubSpeciality,
        'licenseNumber': _licenseController.text,
        'bio': _bioController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in Firestore - both collections
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update healthcare_providers collection
      batch.update(
          FirebaseFirestore.instance.collection('healthcare_providers').doc(userId),
          professionalData
      );

      // Also update main users collection
      batch.update(
          FirebaseFirestore.instance.collection('users').doc(userId),
          professionalData
      );

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Professional information saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the next page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PracticeDetailsPage(),
        ),
      );
    } catch (e) {
      print('Error saving professional info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving professional info: $e'),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Color.fromARGB(255, 191, 252, 252),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Professional Info',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF33D4C8),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Let patients know who you are and how to reach you',
                        style: TextStyle(fontSize: 14, color: Color(0xFF33D4C8)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Speciality',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSpeciality,
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Select Speciality'),
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSpeciality = newValue;
                              });
                            },
                            items:
                            _specialities.map((String speciality) {
                              return DropdownMenuItem<String>(
                                value: speciality,
                                child: Text(speciality),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Sub-Speciality (optional)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSubSpeciality,
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Select Sub-Speciality'),
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSubSpeciality = newValue;
                              });
                            },
                            items:
                            _allSubSpecialities.map((String subSpeciality) {
                              return DropdownMenuItem<String>(
                                value: subSpeciality,
                                child: Text(subSpeciality),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Medical ID / License Number',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _licenseController,
                        decoration: InputDecoration(
                          hintText: 'Enter your license number',
                          contentPadding: const EdgeInsets.symmetric(
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
                      const SizedBox(height: 20),
                      const Text(
                        'Upload Certificate',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Certificate upload functionality can be added here
                            // Similar to the _onEditProfilePicture method from the first code
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF33D4C8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Upload File'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Write a short bio or introduction',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tell your patient about yourself!',
                          contentPadding: const EdgeInsets.all(15),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            if (_selectedSpeciality != null &&
                                _licenseController.text.isNotEmpty) {
                              // Save to Firebase and navigate to next page
                              _saveProfessionalInfo();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all required fields'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF33D4C8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Continue',
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
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33D4C8)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}