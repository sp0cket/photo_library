library photo_library;
import './src/photoListPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_provider/photo_provider.dart';
import 'dart:async';


class PhotoLibrary{
  static Future getAllPhoto({@required BuildContext context, isMultiChoice = true}){
    return _openGalleryContentPage(context, isMultiChoice);
  }
  static Future<String> getPhotoUrl(index){
    Future<String> url;

    url = PhotoProvider.getImageUrl(index);
    return url;
  }
  static FutureBuilder<Widget> getCertainPhoto({
    @required BuildContext context,
    @required List images,
    @required int idx,
    ValueChanged getImageCallback
  }){
    List<String> urls = List<String>();
    _getImageFromPhotoProvider(idx){
      if(images.length > 0){
        images.forEach((item){
          urls.add(item['fileDir']);
        });
        PhotoProvider.init(PhotoProviderType.FileArray, urls: urls);
        PhotoProvider.getImage(idx, width: 300, height: 300).then((list){
          getImageCallback?.call(list);
        });
      }
    }
    return FutureBuilder<Widget>(
      future: _getImageFromPhotoProvider(idx),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Container(
//                    color: Colors.black,
            );
          case ConnectionState.waiting:
            return new Container(
//                    color: Colors.yellow,
            );
          case ConnectionState.active:
            return new Container(
//                    color: Colors.green,
            );
          case ConnectionState.done:
            if (snapshot.hasError)
              return Container(
                color: Colors.red,
              );
            else
              return snapshot.data;
        }
      },
    );
  }
}

Future _openGalleryContentPage(
    BuildContext context, bool isMultiChoice) async {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (ctx) => PhotoListPage(sure: (chosenList){Navigator.pop(context, chosenList);},isMultiChoice: isMultiChoice),
    ),
  );
}



