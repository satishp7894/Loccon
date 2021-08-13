import 'package:flutter/material.dart';
import 'package:loccon/utils/apptheme.dart';

class MessageCountView extends StatelessWidget {
  final int count;
  MessageCountView({@required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(height: 24, width: 24,
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 12),),
    );
  }
}
