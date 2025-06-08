// contact_us_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsCubit extends Cubit<void> {
  ContactUsCubit() : super(null);

  final String emailAddress = "ahmedosamayousef123@gmail.com";
  final String whatsappNumber = "+201090188577";

  Future<void> sendEmail(BuildContext context) async {
    String? encodeQueryParameters(Map<String, dynamic> params) {
      return params.entries
          .map((MapEntry<String, dynamic> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final emailUrl = Uri(
        scheme: 'mailto',
        path: "ahmedosamayousef123@gmail.com",
        query: encodeQueryParameters(
          <String, String>{
            'subject': 'Contact Us',
            'body':
                'Hello, I would like to contact you. Please reply to this email. Thanks',
          },
        ));
    try {
      await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
      // if (await canLaunchUrl(emailUrl)) {
      //   await launchUrl(emailUrl);
      // } else {
      //   _showSnackBar(
      //       context, "No email app found. Please install an email client.");
      // }
    } catch (e) {
      _showSnackBar(context, "Error launching email client: $e");
    }
  }

  Future<void> openWhatsApp(BuildContext context) async {
    final whatsappUrl = "https://wa.me/${whatsappNumber.replaceAll('+', '')}";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar(context, "No WhatsApp app found. Please install WhatsApp.");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
