import 'package:flutter/material.dart';
import 'package:salesforce/config.dart';

class LazyLoadImage extends StatefulWidget {
  final String imageUrl;

  const LazyLoadImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _LazyLoadImageState createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConfig.appSize(context, .125),
      child: _isLoading
          ? Container(
              color: Colors.grey[300],
              height: AppConfig.appSize(context, .125),
              width: double.infinity,
            )
          : Image(
              image: NetworkImage(widget.imageUrl),
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  setState(() {
                    _isLoading = false;
                  });
                  return child;
                }
                return Container();
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Center(child: Icon(Icons.error));
              },
            ),
    );
  }
}
