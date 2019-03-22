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
    this.isMultiChoice,
    this.sureCallback
  });
  final int photoCount;
  final int index;
  final List<int> chosenList;
  final bool previewSelected;
  final bool isMultiChoice;
  final ValueChanged sureCallback;
  @override
  State<StatefulWidget> createState() => new _PhotoDetailPage();
}

class _PhotoDetailPage extends State<PhotoDetailPage> {
  int count = 0;
  int currentPage;
  PageController pageController;
  StreamController<int> pageChangeController = StreamController.broadcast();
  StreamController<bool> isSelectedController = StreamController();
  StreamController<List> listController = StreamController<List>();
  bool isChecked = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
    isSelectedController.close();
    listController.close();
    super.dispose();
  }

  void _onPageChanged(int value) {
    if(widget.previewSelected){
      currentPage = value + 1;
    }else{
      currentPage = widget.photoCount - value;
    }
    pageChangeController.sink.add(currentPage);
    isChecked = widget.previewSelected ? true : widget.chosenList.indexOf(widget.photoCount - currentPage) >= 0;
    isSelectedController.sink.add(isChecked);
  }
  @override
  Widget build(BuildContext context) {
    isChecked = widget.previewSelected ? true : widget.chosenList.indexOf(widget.photoCount - currentPage) >= 0;
    isSelectedController.sink.add(isChecked);
    int itemCount = widget.previewSelected ? widget.chosenList.length : widget.photoCount;
    Future<Widget> _getImageFromPhotoProvider(int index) async {
//      print('getimage$index');
      int photoIndex = widget.previewSelected ? widget.chosenList[index] : index;
      var image = await PhotoProvider.getImage(photoIndex);
      return Container(
        color: Colors.black,
        child: Image.memory(image.image, fit: BoxFit.fitWidth),
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
      int index = widget.previewSelected ? currentPage - 1 : widget.photoCount - currentPage;
      if(widget.isMultiChoice){
        if(isChecked){
          widget.previewSelected ? widget.chosenList.removeAt(index) : widget.chosenList.remove(index);
        }else{
          widget.chosenList.add(index);
        }
      }else{
        if(widget.chosenList.length > 0){
          widget.chosenList.clear();
        }
        if(!widget.previewSelected){
          widget.chosenList.add(index);
        }
      }
      isChecked = !isChecked;
      isSelectedController.sink.add(isChecked);
      listController.sink.add(widget.chosenList);
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
                        StreamBuilder(
                            stream: pageChangeController.stream,
                            initialData: currentPage,
                            builder: (context, AsyncSnapshot snapshot)=>
                                Text('${snapshot.data}/$itemCount', style: TextStyle(color: Colors.black, fontSize: 16.0),)
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              StreamBuilder(
                stream: listController.stream,
                initialData: widget.chosenList,
                builder: (context, AsyncSnapshot snapshot)=>SureButton(
                  enable: snapshot.data.length > 0,
                  sureCallback: (){
                    print('确认');
                    Navigator.pop(context);
                    widget.sureCallback?.call(widget.chosenList);
                  },
                ),
              )
            ],
          ),
        ),
        body:
        Hero(
          tag: 'hero${widget.index}',
          child:
      PageView.builder(
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
          trailing: Row(
            children: <Widget>[
              StreamBuilder(
                stream: isSelectedController.stream,
                initialData: false,
                builder: (context, AsyncSnapshot snapshot)=>
                Checkbox(
                  value: snapshot.data,
                  activeColor: Colors.green,
                  onChanged: (bool newValue){
                    _changeCheck();
                  },
                )
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
