import 'package:flutter/material.dart';
import '../../util/constants.dart' as Constants;

class SharedWidgets {
  static Widget networkImageWithLoading(String imageUrl) {
    return Image.network(loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
          height: Constants.isMobile
              ? Constants.itemImageHeightMobile
              : Constants.itemImageHeightTablet,
          width: Constants.isMobile
              ? Constants.itemImageWidthMobile
              : Constants.itemImageWidthTablet,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ));
    },
        height: Constants.isMobile
            ? Constants.itemImageHeightMobile
            : Constants.itemImageHeightTablet,
        width: Constants.isMobile
            ? Constants.itemImageWidthMobile
            : Constants.itemImageWidthTablet,
        fit: BoxFit.fill,
        imageUrl);
  }

  static Widget screenTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: Constants.isMobile
              ? Constants.screenTitleFontSizeMobile
              : Constants.screenTitleFontSizeTablet,
          fontFamily: 'Jost',
          fontWeight: FontWeight.bold),
    );
  }

  static Widget SortMenu(
      List<String> items,
      double menuHeight,
      bool isSortingMenuVisible,
      void Function() onOpenClose,
      void Function(int oldIndex, int newIndex) onReorder) {
    return Card(
        color: Colors.white70,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort by',
                        style: TextStyle(
                            fontSize: Constants.isMobile
                                ? Constants.sortMenuFontSizeMobile
                                : Constants.sortMenuFontSizeTablet,
                            fontFamily: 'Jost'),
                      ),
                      RotatedBox(
                          quarterTurns: isSortingMenuVisible ? 2 : 0,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              size: Constants.isMobile
                                  ? Constants.iconSizeMobile
                                  : Constants.iconSizeTablet,
                            ),
                            onPressed: () {
                              onOpenClose();
                            },
                          )),
                    ]),
                if (isSortingMenuVisible)
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Divider(
                        height: 2,
                      )),
                AnimatedContainer(
                  curve: Curves.linearToEaseOut,
                  duration: Duration(milliseconds: 500),
                  height: menuHeight,
                  child: ReorderableListView(
                    children: <Widget>[
                      for (int index = 0; index < items.length; index += 1)
                        Column(
                          key: Key('$index'),
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    items[index],
                                    style: TextStyle(
                                        fontSize: Constants.isMobile
                                            ? Constants.sortMenuFontSizeMobile
                                            : Constants.sortMenuFontSizeTablet,
                                        fontFamily: 'Jost'),
                                  ),
                                  ReorderableDragStartListener(
                                      key: ValueKey<String>(items[index]),
                                      index: index,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 10, 0),
                                        child: Icon(
                                          Icons.drag_handle,
                                          size: Constants.isMobile
                                              ? Constants.iconSizeMobile
                                              : Constants.iconSizeTablet,
                                        ),
                                      )),
                                ]),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        )
                    ],
                    onReorder: (int oldIndex, int newIndex) {
                      onReorder(oldIndex, newIndex);
                    },
                  ),
                )
              ],
            )));
  }
  static Widget categoryTitleWidget(String category){
    return Container(
        width: double.infinity,
        child: Padding(
            padding:
            EdgeInsets.symmetric(vertical: 0, horizontal: 3),
            child: Text(category,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: Constants.isMobile
                        ? Constants.itemTitleFontSizeMobile
                        : Constants.itemTitleFontSizeTablet,
                    fontWeight: FontWeight.bold))));
  }

  static Widget itemTitleWidget(String title){
    return Text(
      title,
      style: TextStyle(
          color: Colors.white,
          fontSize: Constants.isMobile
              ? Constants.itemTitleFontSizeMobile
              : Constants.itemTitleFontSizeTablet,
          fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget itemPriceWidget(int price){
    return Text(
      "\$$price",
      style: TextStyle(
          color: Colors.white,
          fontSize: Constants.isMobile
              ? Constants.itemTitleFontSizeMobile
              : Constants.itemTitleFontSizeTablet,
          fontWeight: FontWeight.bold),
    );
  }

  static Widget itemDateWidget(String dateString){
    return Text(
      dateString,
      style: TextStyle(
          fontSize: Constants.isMobile
              ? Constants.itemSubtitleFontSizeMobile
              : Constants.itemSubtitleFontSizeTablet,
          fontWeight: FontWeight.bold,
          color: Colors.white),
    );
  }

  static Widget itemDescriptionWidget(String description){
    return Text(
      description,
      textAlign: TextAlign.justify,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: Colors.white,
          fontSize: Constants.isMobile
              ? Constants.itemDescriptionFontSizeMobile
              : Constants.itemDescriptionFontSizeTablet),
    );
  }

  static Widget itemAgeGroupsWidget(List<String> ageGroups){
    return Row(
      children: [
        for (var group in ageGroups)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            height: Constants.isMobile
                ? Constants.itemAgeGroupHeightMobile
                : Constants.itemAgeGroupHeightTablet,
            decoration: BoxDecoration(
              color: Color(0xff568f56),
              borderRadius:
              BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(
                child: Text(
                  group,
                  style: TextStyle(
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                    fontSize: Constants.isMobile
                        ? Constants.itemAgeGroupFontSizeMobile
                        : Constants.itemAgeGroupFontSizeTablet,
                  ),
                )),
          )
      ],
    );
  }
}
