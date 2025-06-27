import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/contact_us_cubit.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width >= 500;

    return BlocProvider(
      create: (_) => ContactUsCubit(),
      child: Scaffold(
        backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
        appBar: const CustomAppBar(title: "Help"),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/ic_launcher.png", width: 300.w),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CustomText(
                  text:
                      "We're here to help you! Reach out to us via WhatsApp or email for any queries.",
                  color: Storage.themeState == 1 ? Colors.white : bColor,
                  fontSize: isWidth ? 16 : 14,
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 15),
                  Card(
                    color: Storage.themeState == 1
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading:
                            Image.asset("assets/images/gmail.png", width: 50.w),
                        title: CustomText(
                          text: "Send us an Email",
                          color: Colors.white,
                          fontSize: isWidth ? 14 : 17,
                        ),
                        onTap: () =>
                            context.read<ContactUsCubit>().sendEmail(context),
                      ),
                    ),
                  ),
                  Card(
                    color: Storage.themeState == 1
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Image.asset("assets/images/whatsapp.png",
                            width: 50.w),
                        title: CustomText(
                          text: "Contact us via WhatsApp",
                          color: Colors.white,
                          fontSize: isWidth ? 14 : 17,
                        ),
                        onTap: () => context
                            .read<ContactUsCubit>()
                            .openWhatsApp(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
