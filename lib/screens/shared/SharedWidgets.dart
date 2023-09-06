import 'package:flutter/material.dart';

import '../../util/constants.dart';

class SharedWidgets {
  static Widget networkImageWithLoading(String imageUrl){
    return Image.network(
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
              height: MyConstants.isMobile ? MyConstants.itemImageHeightMobile : MyConstants.itemImageHeightTablet,
              width: MyConstants.isMobile ? MyConstants.itemImageWidthMobile : MyConstants.itemImageWidthTablet,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ));
        },
        height: MyConstants.isMobile ? MyConstants.itemImageHeightMobile : MyConstants.itemImageHeightTablet,
        width: MyConstants.isMobile ? MyConstants.itemImageWidthMobile : MyConstants.itemImageWidthTablet,
        fit: BoxFit.fill,
        imageUrl);
  }


}