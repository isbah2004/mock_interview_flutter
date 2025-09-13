// import 'package:flutter/material.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final List<Widget>? actions;
//   final Widget? leading;
//   final bool centerTitle;
//   final Color? backgroundColor;

//   const CustomAppBar({
//     super.key,
//     required this.title,
//     this.actions,
//     this.leading,
//     this.centerTitle = true,
//     this.backgroundColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         title,
//         style: Theme.of(
//           context,
//         ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//       ),
//       centerTitle: centerTitle,
//       backgroundColor:
//           backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
//       elevation: 0,
//       actions: actions,
//       leading: leading,
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
