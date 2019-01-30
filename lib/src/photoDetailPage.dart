import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_provider/photo_provider.dart';
import './pageBottomWidget.dart';
import './sureButton.dart';
import 'dart:async';
class PhotoDetailPage extends StatefulWidget {
  PhotoDetailPage({
    @required this.photoCount,
    @required this.index,
    @required this.chosenList,
    this.previewSelected = false,
  });
  int photoCount;
  int index;
  List<int> chosenList;
  bool previewSelected;
  @override
  State<StatefulWidget> createState() => new _PhotoDetailPage();
}

class _PhotoDetailPage extends State<PhotoDetailPage> {
  int count = 0;
  int currentPage;
  PageController pageController;
  StreamController<int> pageChangeController = StreamController.broadcast();
  Stream<int> get pageStream => pageChangeController.stream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageChangeController.add(0);
    pageController = PageController(
      initialPage: widget.index,
    );
    setState(() {
      if(widget.previewSelected){
        currentPage = widget.index + 1;
      }else{
        currentPage = widget.photoCount - widget.index;
      }

    });
  }
  @override
  void dispose() {
    pageChangeController.close();
    super.dispose();
  }

  void _onPageChanged(int value) {
    setState(() {
      if(widget.previewSelected){
        currentPage = value + 1;
      }else{
        currentPage = widget.photoCount - value;
      }

    });
    pageChangeController.add(value);
  }
  @override
  Widget build(BuildContext context) {
    bool isChecked = widget.previewSelected ? true : widget.chosenList.indexOf(widget.photoCount - currentPage) >= 0;
    int itemCount = widget.previewSelected ? widget.chosenList.length : widget.photoCount;
    Future<Widget> _getImageFromPhotoProvider(int index) async {
//      print('getimage$index');
      int photoIndex = widget.previewSelected ? widget.chosenList[index] : index;
      var list = await PhotoProvider.getImage(photoIndex, height: 800, width: 800);
      return Container(
        color: Colors.black,
        child: Image.memory(list, fit: BoxFit.fitWidth,
        ),
      );
    }
    Widget _buildItem(BuildContext context, int idx) {
      return FutureBuilder<Widget>(
        future: _getImageFromPhotoProvider(idx),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Container(
                    color: Colors.black,
              );
            case ConnectionState.waiting:
              return new Container(
                    color: Colors.black,
              );
            case ConnectionState.active:
              return new Container(
                    color: Colors.black,
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

    void _changeCheck(){
      setState(() {
        int index;
        if(widget.previewSelected){
          index = currentPage - 1;
        }else{
          index = widget.photoCount - currentPage;
        }
        if(isChecked){
          widget.previewSelected ? widget.chosenList.removeAt(index) : widget.chosenList.remove(index);
        }else{
          widget.chosenList.add(index);
        }
      });
      if(widget.previewSelected && widget.chosenList.length <= 0){
        Navigator.pop(context);
      }
    }

    // TODO: implement build
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            backgroundColor: Colors.white,
            leading: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: 100,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.keyboard_arrow_left, color: Colors.black),
                        Text('$currentPage/$itemCount', style: TextStyle(color: Colors.black, fontSize: 16.0),)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              SureButton()
            ],
          ),
        ),
        body:
        Hero(
          tag: 'hero${widget.index}',
//          flightShuttleBuilder: (flightContext, animation, direction,
//              fromContext, toContext) {
//            if(direction == HeroFlightDirection.push) {
//              return Icon(
//                Icons.audiotrack,
//                size: 150.0,
//              );
//            } else if (direction == HeroFlightDirection.pop){
//              return Icon(
//                Icons.audiotrack,
//                size: 70.0,
//              );
//            }
//          },
          child: PageView.builder(
            pageSnapping: false,
            physics: const PageScrollPhysics(parent: const BouncingScrollPhysics()),
            reverse: widget.previewSelected ? false : true,
            controller: pageController,
            itemBuilder: _buildItem,
            itemCount: itemCount,
            onPageChanged: _onPageChanged,
          ),
        ),
        bottomNavigationBar: PageBottomWidget(
//          leading: Row(
//            children: <Widget>[
//              Text('图片', style: TextStyle(color: Colors.white, fontSize: 16.0),),
//              Icon(Icons.keyboard_arrow_left, color: Colors.black),
//            ],
//          ),
//          middle: Text('原图', style: TextStyle(color: Colors.white, fontSize: 16.0),),
          trailing: Row(
            children: <Widget>[
              Checkbox(
                value: isChecked,
                activeColor: Colors.green,
                onChanged: (bool newValue){
                  _changeCheck();
                },
              ),
              Text('选择', style: TextStyle(color: Colors.white, fontSize: 16.0))
            ],
          ),
          trailingCallback: (){
            _changeCheck();
          },
        ),
    );
  }
}
