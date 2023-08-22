import 'package:flutter/material.dart';

class SharedWidgets {
  static Widget networkImageWithLoading(String imageUrl){
    return Image.network(
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
              height: 180,
              width: 350,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ));
        },
        height: 180,
        width: 350,
        fit: BoxFit.fill,
        imageUrl);
  }
}