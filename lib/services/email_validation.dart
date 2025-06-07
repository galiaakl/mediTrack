import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';

class EmailValidationService {
  // First level check - validate email format
  static bool isValidEmailFormat(String email) {
    return EmailValidator.validate(email);
  }

  // Second level check - disposable email domains
  static final List<String> disposableDomains = [
    'mailinator.com',
    'tempmail.com',
    'temp-mail.org',
    'guerrillamail.com',
    'fakeinbox.com',
    'mailnesia.com',
    'yopmail.com',
    // Add more as needed
  ];

  static bool isDisposableEmail(String email) {
    final domain = email.split('@').last.toLowerCase();
    return disposableDomains.contains(domain);
  }

  // Third level check (optional) - use email verification API
  // Note: This requires a subscription to a 3rd party service
  // You can use services like Abstract API, Hunter.io, Kickbox, etc.
  static Future<bool> verifyEmailExists(String email) async {
    try {
      // Example using Abstract API - replace with your actual API key
      // You would need to sign up for this service
      final apiKey = 'YOUR_ABSTRACT_API_KEY';
      final url = 'https://emailverification.abstractapi.com/v1/?api_key=$apiKey&email=$email';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if the email is deliverable based on the API response
        return data['deliverability'] == 'DELIVERABLE' &&
            data['is_disposable_email'] == false;
      }

      // Default to true if API call fails - this allows signup to proceed
      return true;
    } catch (e) {
      // Log the error but allow the process to continue
      print('Error verifying email: $e');
      return true;
    }
  }

  // Comprehensive email validation
  static Future<Map<String, dynamic>> validateEmail(String email) async {
    // Check format first
    if (!isValidEmailFormat(email)) {
      return {
        'isValid': false,
        'message': 'Invalid email format'
      };
    }

    // Check for disposable email
    if (isDisposableEmail(email)) {
      return {
        'isValid': false,
        'message': 'Disposable email addresses are not allowed'
      };
    }

    // Check if email exists (optional - requires API)
    // Uncomment this if you've subscribed to an email verification service
    /*
    final exists = await verifyEmailExists(email);
    if (!exists) {
      return {
        'isValid': false,
        'message': 'This email address appears to be invalid or non-existent'
      };
    }
    */

    return {
      'isValid': true,
      'message': 'Email is valid'
    };
  }
}