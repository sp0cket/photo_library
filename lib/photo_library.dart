library photo_library;
import './src/photoListPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_provider/photo_provider.dart';
import 'dart:async';


class PhotoLibrary{
  static Future getPhoto({@required BuildContext context}){
    return _openGalleryContentPage(context);
  }
  static String getPhotoUrl(index){
    String url;
    PhotoProvider.getImageUrl(index).then((item){
      url = item;
    });
    return url;
  }
}

Future _openGalleryContentPage(
    BuildContext context) async {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => PhotoListPage(sure: (chosenList){Navigator.pop(context, chosenList);},),
    ),
  );
}



