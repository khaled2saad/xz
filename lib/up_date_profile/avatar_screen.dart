import 'package:flutter/material.dart';
import 'package:movies_app/core/app_colors.dart';
import 'package:movies_app/core/app_assets.dart';

class AvatarScreen extends StatelessWidget {
  static const String routeName = "/avatar";

  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> avatars = [
      AppAssets.image1,
      AppAssets.image2,
      AppAssets.image3,
      AppAssets.image4,
      AppAssets.image5,
      AppAssets.image6,
      AppAssets.image7,
      AppAssets.image8,
      AppAssets.image9,
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text(
          'Pick Avatar',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1,
            ),
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, avatars[index]);
                },
                child: ClipOval(
                  child: Image.asset(
                    avatars[index],
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.graycolor,
                      child: const Icon(Icons.person, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}