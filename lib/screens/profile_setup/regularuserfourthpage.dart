import 'package:flutter/material.dart';
import '../auth/signup.dart';

class HealthInfoPage extends StatefulWidget {
  const HealthInfoPage({super.key});

  @override
  State<HealthInfoPage> createState() => _HealthInfoPageState();
}

class _HealthInfoPageState extends State<HealthInfoPage> {
  List<String> medicalConditions = [];
  List<String> allergies = [];

  final TextEditingController medicationsController = TextEditingController();
  final TextEditingController newConditionController = TextEditingController();
  final TextEditingController newAllergyController = TextEditingController();

  bool agreeToShare = false;

  @override
  void dispose() {
    medicationsController.dispose();
    newConditionController.dispose();
    newAllergyController.dispose();
    super.dispose();
  }

  void _showAddDialog(String title, String hint, Function(String) onAdd) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
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
                'Your Health Info',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us about your health (optional)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Medical Conditions
              const Text(
                'Medical Conditions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...medicalConditions.map(
                        (condition) => _buildChip(
                      label: condition,
                      onDeleted: () {
                        setState(() {
                          medicalConditions.remove(condition);
                        });
                      },
                    ),
                  ),
                  _buildAddChip(
                    label: '+ Add Medical Condition',
                    onTap: () {
                      _showAddDialog(
                        'Medical Condition',
                        'Enter medical condition',
                            (value) {
                          setState(() {
                            medicalConditions.add(value);
                          });
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Allergies
              const Text(
                'Allergies',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...allergies.map(
                        (allergy) => _buildChip(
                      label: allergy,
                      onDeleted: () {
                        setState(() {
                          allergies.remove(allergy);
                        });
                      },
                    ),
                  ),
                  _buildAddChip(
                    label: '+ Add Allergy',
                    onTap: () {
                      _showAddDialog('Allergy', 'Enter allergy', (value) {
                        setState(() {
                          allergies.add(value);
                        });
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Current Medications
              const Text(
                'Current Medications (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: medicationsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: 'Enter your medications',
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Consent Checkbox
              Row(
                children: [
                  Checkbox(
                    value: agreeToShare,
                    onChanged: (value) {
                      setState(() {
                        agreeToShare = value ?? false;
                      });
                    },
                    activeColor: Color(0xFF33D4C8),
                  ),
                  Expanded(
                    child: Text(
                      'I agree to share my health profile with caregivers in case of emergency',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Finalize Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage(userRole: 'regular'),
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
                    'Finalize',
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

  Widget _buildChip({required String label, required VoidCallback onDeleted}) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 14)),
      backgroundColor: Colors.grey.shade200,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAddChip({required String label, required VoidCallback onTap}) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Color(0xFF33D4C8)),
      ),
      backgroundColor: Colors.grey.shade200,
      onPressed: onTap,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
