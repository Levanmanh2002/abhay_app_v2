import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotiSkeletonView extends StatelessWidget {
  const NotiSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding(all: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: appTheme.whiteColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(1000),
            child: Skeleton.replace(width: 46.w, height: 46.h, child: Container()),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Skeleton.replace(
                    width: double.infinity,
                    height: 17.h,
                    child: Container(),
                  ),
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Skeleton.replace(
                    width: double.infinity,
                    height: 15.h,
                    child: Container(),
                  ),
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Skeleton.replace(
                    width: 49.w,
                    height: 15.h,
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
