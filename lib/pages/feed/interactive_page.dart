import 'package:flutter/material.dart';
import 'package:loccon/utils/connection.dart';

class InteractivePage extends StatefulWidget {
  final List<String> images;
  InteractivePage({this.images});
  @override
  _InteractivePageState createState() => _InteractivePageState();
}

class _InteractivePageState extends State<InteractivePage> {
  String _currentImage = '';
  final TransformationController _imageController = TransformationController();

  @override
  void initState() {
    _currentImage = widget.images[0];
    super.initState();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
               Expanded(
                 child: InteractiveViewer(maxScale: 5,
                   transformationController: _imageController,
                   child: Image.network(
                     '${Connection.feedImagePath}' + _currentImage),
                 ),
               ),
               Container(height: 150,
                 child: ListView.builder(
                   physics: BouncingScrollPhysics(),
                   scrollDirection: Axis.horizontal,
                   itemCount: widget.images.length,
                   itemBuilder: (c, i) {
                     return GestureDetector(
                       child: Container(
                         margin: const EdgeInsets.all(8),
                         padding: const EdgeInsets.all(1),
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.black),
                           color: Colors.white,
                         ),

                         child: Image.network('${Connection.feedImagePath}' + widget.images[i]),
                       ),
                       onTap: () {
                         setState(() {
                           _currentImage = widget.images[i];
                           _imageController.value = Matrix4.identity();
                         });
                       },
                     );
                   }),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
