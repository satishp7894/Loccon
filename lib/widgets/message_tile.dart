import 'package:flutter/material.dart';
import 'package:loccon/utils/apptheme.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSender, isSelected;
  MessageTile({@required this.message, @required this.isSender,  this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (isSender) {
      return Container(
        color: isSelected ? Colors.grey.withOpacity(.4) : Colors.transparent,
        margin: isSelected ? EdgeInsets.symmetric(horizontal: 8, vertical: 5)
            : EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.3,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Text('$message', style: TextStyle(fontWeight: FontWeight.w500,
                  color: Colors.white, fontSize: 16.8), maxLines: null,),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: isSelected ? Colors.grey.withOpacity(.4) : Colors.transparent,
        margin: isSelected ? EdgeInsets.symmetric(horizontal: 8, vertical: 5)
            : EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.3,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text('$message', style: TextStyle(fontWeight: FontWeight.w500,
                  color: AppTheme.accentColor, fontSize: 16.8),),
            ),
          ],
        ),
      );
    }
  }
}