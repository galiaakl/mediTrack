import 'package:flutter/material.dart';
import 'package:meditrack_new/screens/profile_setup/regularuserthirdpage.dart';

class HealthProfilePage extends StatefulWidget {
  const HealthProfilePage({Key? key}) : super(key: key);

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> {
  String selectedGender = 'Male';
  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  String? selectedBloodType;
  bool isSmokeFree = false;
  bool hasAllergies = false;
  bool hasChronicDiseases = false;
  bool takesDailyMedication = false;

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF33D4C8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Regular User',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gender',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = 'Male';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                          selectedGender == 'Male'
                              ? Color(0xFF33D4C8)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.male,
                              color:
                              selectedGender == 'Male'
                                  ? Colors.white
                                  : Colors.grey,
                              size: 40,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Male',
                              style: TextStyle(
                                color:
                                selectedGender == 'Male'
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = 'Female';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                          selectedGender == 'Female'
                              ? Color(0xFF33D4C8)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.female,
                              color:
                              selectedGender == 'Female'
                                  ? Colors.white
                                  : Colors.grey,
                              size: 40,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Female',
                              style: TextStyle(
                                color:
                                selectedGender == 'Female'
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Date Of Birth',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildDateDropdown('Day', selectedDay, 31, (value) {
                    setState(() {
                      selectedDay = value;
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildDateDropdown('Month', selectedMonth, 12, (value) {
                    setState(() {
                      selectedMonth = value;
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildDateDropdown('Year', selectedYear, 100, (value) {
                    setState(() {
                      selectedYear = value;
                    });
                  }),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildInputWithSuffix(
                      controller: weightController,
                      label: 'Weight',
                      suffix: 'kg',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputWithSuffix(
                      controller: heightController,
                      label: 'Height',
                      suffix: 'cm',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Blood Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBloodType,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    hint: const Text(
                      'Select your blood type',
                      style: TextStyle(color: Colors.grey),
                    ),
                    items:
                    ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((
                        String value,
                        ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedBloodType = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Select All That is Correct',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildCheckbox('I am a smoker', isSmokeFree, (value) {
                setState(() {
                  isSmokeFree = value ?? false;
                });
              }),
              _buildCheckbox('I have allergies', hasAllergies, (value) {
                setState(() {
                  hasAllergies = value ?? false;
                });
              }),
              _buildCheckbox('I have chronic diseases', hasChronicDiseases, (
                  value,
                  ) {
                setState(() {
                  hasChronicDiseases = value ?? false;
                });
              }),
              _buildCheckbox('I take daily medication', takesDailyMedication, (
                  value,
                  ) {
                setState(() {
                  takesDailyMedication = value ?? false;
                });
              }),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmergencyContactsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF33D4C8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDropdown(
      String label,
      int? selectedValue,
      int itemCount,
      ValueChanged<int?> onChanged,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: selectedValue,
            hint: Text(label, style: const TextStyle(color: Colors.grey)),
            isExpanded: true,
            items: List.generate(itemCount, (index) {
              int value = label == 'Year' ? 2024 - index : index + 1;
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  value.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildInputWithSuffix({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: label,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
      String title,
      bool value,
      void Function(bool?) onChanged,
      ) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF33D4C8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Text(title),
      ],
    );
  }
}
