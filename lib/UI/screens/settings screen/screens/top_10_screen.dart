import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/top_10_cubit.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';
import 'package:kotaby/storage.dart';
import 'package:shimmer/shimmer.dart';

class Top10Screen extends StatelessWidget {
  const Top10Screen({super.key});

  Widget buildUserAvatar(BuildContext context, String? image, String name) {
    return image != null && image.isNotEmpty
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OpenImage(image: image, name: name),
                ),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: bColor,
              backgroundImage: NetworkImage(image),
            ),
          )
        : const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person),
          );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Top10Cubit()..loadUsers(),
      child: BlocBuilder<Top10Cubit, Top10State>(
        builder: (context, state) {
          final cubit = context.read<Top10Cubit>();

          return Scaffold(
            appBar: CustomAppBar(
              title: "Top 10",
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Storage.themeState == 1 ? Colors.white : bColor,
                  ),
                  onPressed: () => cubit.loadUsers(),
                ),
              ],
            ),
            backgroundColor:
                Storage.themeState == 1 ? primaryColor : Colors.white,
            body: Builder(
              builder: (context) {
                if (state is Top10Loading) {
                  return ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) => Shimmer.fromColors(
                      baseColor: Colors.white70.withOpacity(.1),
                      highlightColor: Colors.grey.shade100,
                      child: const ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 24,
                        ),
                        title: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: SizedBox(
                            height: 12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.grey),
                            ),
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(right: 40),
                          child: SizedBox(
                            height: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (state is Top10Empty) {
                  return const Center(
                    child: CustomText(
                      text: "لا يوجد مستخدمين لعرضهم",
                      color: Colors.white,
                    ),
                  );
                } else if (state is Top10Error) {
                  return const Center(
                    child: CustomText(
                      text: "حدث خطأ، حاول مرة أخرى",
                      color: Colors.white,
                    ),
                  );
                } else if (state is Top10Loaded) {
                  final users = state.users.reversed.take(10).toList();

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final bgColor = index == 0
                          ? const Color(0xffFFD700)
                          : index == 1
                              ? const Color(0xffc0c0c0)
                              : index == 2
                                  ? const Color(0xffCD7F32)
                                  : Storage.themeState == 1
                                      ? Colors.transparent
                                      : Colors.white;

                      return Card(
                        color: bgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ListTile(
                          leading: buildUserAvatar(
                              context, user.image, user.userName),
                          title: CustomText(
                            text: user.userName,
                            color: cubit.getTextColor(index),
                          ),
                          subtitle: CustomText(
                            text: user.email,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: cubit.getSubTextColor(index),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox(); // fallback
              },
            ),
          );
        },
      ),
    );
  }
}

class OpenImage extends StatelessWidget {
  final String image;
  final String name;

  const OpenImage({super.key, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: CustomAppBar(title: name),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
