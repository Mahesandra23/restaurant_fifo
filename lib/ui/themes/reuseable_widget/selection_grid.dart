// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:restaurant_fifo/core/enums/toggle_category.dart';
// import 'package:restaurant_fifo/ui/themes/app_colors.dart';
// import 'package:restaurant_fifo/ui/themes/typography/text_style_app.dart';

// /// ini adalah tampilan untuk button grid yang bisa di select dan di unselect
// class SelectionGrid extends StatelessWidget {
//   final List<String> items;
//   final Set<String> selectedItems;
//   final ToggleCategory category;
//   final void Function(String item) onToggle;

//   const SelectionGrid({
//     super.key,
//     required this.items,
//     required this.selectedItems,
//     required this.category,
//     required this.onToggle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.zero,
//       crossAxisCount: 2,
//       crossAxisSpacing: 8.w,
//       mainAxisSpacing: 8.h,
//       childAspectRatio: 2.8,
//       children: items.map((item) {
//         final isSelected = selectedItems.contains(item);
//         return selectButton(
//           title: item,
//           isSelected: isSelected,
//           onSelect: () => onToggle(item),
//         );
//       }).toList(),
//     );
//   }

//   Widget selectButton({
//     required String title,
//     required bool isSelected,
//     required VoidCallback onSelect,
//   }) {
//     return InkWell(
//       onTap: onSelect,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16).w,
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColorsCustom.buttonPurple
//               : AppColorsCustom.darkGray,
//           borderRadius: BorderRadius.circular(12.r),
//           border: isSelected
//               ? Border.all(
//                   color: AppColorsCustom.borderButtonPurple, width: 1.w)
//               : null,
//         ),
//         child: Center(
//           child: Text(
//             title,
//             style: AppTextStyle.bodyXs.regular.copyWith(
//               color: isSelected ? Colors.white : Colors.white70,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
