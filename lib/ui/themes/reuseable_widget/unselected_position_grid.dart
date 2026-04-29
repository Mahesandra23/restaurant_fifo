// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:game_hub/pages/setup_profile/widget/reuseable/select_button2.dart';

// /// ini adalah class untul list preference (dalam bentuk grid) yang belum di pilih. Di gunakan pada halaman setup profile dan setting.
// class UnselectedPositionGrid extends StatelessWidget {
//   final List<String> unselectedPositions;
//   final void Function(String pos) onSelect;

//   const UnselectedPositionGrid({
//     super.key,
//     required this.unselectedPositions,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       crossAxisSpacing: 8.w,
//       mainAxisSpacing: 8.h,
//       childAspectRatio: 2.8,
//       padding: EdgeInsets.zero,
//       children: unselectedPositions.map((position) {
//         return SelectButton2(
//           title: position,
//           isSelected: false,
//           onSelect: () => onSelect(position),
//         );
//       }).toList(),
//     );
//   }
// }
