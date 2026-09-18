import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class OnboardingContent extends StatelessWidget {
  final String image;
  final String title;
  final String desc;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.desc,
    required this.isFirst,
    required this.isLast,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.black.withValues(alpha: 0.85),
                AppColors.black,
              ],
              stops: [0.4, 0.65, 1.0],
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: isFirst
                ? EdgeInsets.fromLTRB(20, 0, 20, 30)
                : EdgeInsets.all(20),

            decoration: isFirst
                ? null
                : BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.whitecolor,
                    fontWeight: FontWeight.bold,
                    fontSize: isFirst ? 36 : 24,
                  ),
                ),
                SizedBox(height: isLast ? 0 : 16),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.whitecolor,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: isLast ? 0 : 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.black,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: onNext,
                    child: Text(
                      isFirst ? "Explore Now" : (isLast ? "Finish" : "Next"),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                if (!isFirst) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: onBack,
                      child: Text(
                        "Back",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

        ),
      ],
    );
  }
}