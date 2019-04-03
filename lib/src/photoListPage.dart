import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:photo_provider/photo_provider.dart';
import './photoDetailPage.dart';
import './pageBottomWidget.dart';
import './galleryListDialog.dart';
import './sureButton.dart';
class PhotoListPage extends StatefulWidget {
  PhotoListPage({this.onDone, this.isMultiChoice});
  final bool isMultiChoice;
  final Function onDone;
  @override
  State<StatefulWidget> createState() => new _PhotoListPage();
}

class _PhotoListPage extends State<PhotoListPage> {
  List<int> chosenList = [];
  int count = 0;
  int currentGalleryIndex = 0;
  List<Uint8List> photoList;
  StreamController<List> _streamController = StreamController<List>.broadcast();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _streamController.close();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPhotoProvider();

    print('init');
  }

  _initPhotoProvider() {
    PhotoProvider.init(PhotoProviderType.All);
    PhotoProvider.getImagesCount().then((count) {
      setState(() {
        this.count = count;
      });
    });
  }

  Future<Widget> _getImageFromPhotoProvider(int index) async {
//    print('getimage$index');
    var image = await PhotoProvider.getImage(index, width: 200, height: 200);
    bool isSelected = chosenList.indexOf(index) >= 0;
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: (){
                Navigator.of(context, rootNavigator: true).push(
                    new PageRouteBuilder(
                        opaque: false,
                        barrierDismissible:true,
                        pageBuilder: (BuildContext context, _, __) {
                          return PhotoDetailPage(
                              photoCount: count,
                              index: index,
                              chosenList: chosenList,
                              isMultiChoice: widget.isMultiChoice,
                              sureCallback: widget.onDone != null ? widget.onDone(chosenList) : (){}
                          );
                        }
                    )
                ).then((dynamic){
                  setState(() {});
                });
              },
              child: Hero(
                tag: 'hero$index',
                child: Image.memory(image.image, fit: BoxFit.cover,),
              ),
            )
        ),
      ],
    );
  }

  Widget _imageFutureBuilder(idx){
    return FutureBuilder<Widget>(
      future: _getImageFromPhotoProvider(idx),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Container();
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.active:
            return Container();
          case ConnectionState.done:
            if (snapshot.hasError)
              return Container(
                color: Colors.white,
              );
            else
              return snapshot.data;
        }
      },
    );
  }

  Widget _context() {
    Widget _mainView(index){
      Widget _chosenView(){
        return StreamBuilder(
          stream: _streamController.stream,
          initialData: chosenList,
          builder: (context, AsyncSnapshot snapshot){
            List list = snapshot.data;
            bool isSelected = list.indexOf(index) >= 0;
            return Stack(
              children: <Widget>[
                IgnorePointer(
                  child: AnimatedContainer(
                    color: isSelected ? Colors.black.withOpacity(0.5) : Colors.transparent,
                    duration: Duration(milliseconds: 300),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: GestureDetector(
                    onTap: (){
                      if(widget.isMultiChoice){
                        chosenList.indexOf(index) >= 0 ?  chosenList.remove(index) : chosenList.add(index);
                      }else{
                        if(chosenList.length > 0){
                          var tmpIdx = chosenList[0];
                          chosenList.clear();
                          if(index != tmpIdx){
                            chosenList.add(index);
                          }
                        }else{
                          chosenList.add(index);
                        }

                      }
                      _streamController.sink.add(chosenList);
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
                      decoration: BoxDecoration(
                        border: new Border.all(color: Colors.transparent),
                      ),
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            border: new Border.all(color: isSelected ? Colors.green : Colors.white),
                            borderRadius:
                            const BorderRadius.all(const Radius.circular(2.0)),
                            color: isSelected ? Colors.green : Colors.transparent
                        ),
                        child: Offstage(
                            offstage: !isSelected,
                            child:
                            Center(
                              child: Icon(Icons.check, color: Colors.white,size: 13,),
                            )
                        ),
                      ),
                    )
                  ),
                )
              ],
            );
          },
        );
      }
      return Stack(
        children: <Widget>[
          _imageFutureBuilder(index),
          _chosenView()
        ],
      );
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: Scrollbar(
            child:
            GridView.custom(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 2.0, crossAxisSpacing: 2.0),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, int idx){
                  var index = count - idx - 1;
                  return _mainView(index);
                },
                childCount: count,

              )),
          ),
        ),
        PageBottomWidget(
          leading: Row(
            children: <Widget>[
              Text('图片', style: TextStyle(color: Colors.white, fontSize: 16.0),),
//                Image.asset('images/triangle_more.png'),
            ],
          ),
//            leadingCallback: (){ _displayGalleryList(); },
//            middle: Text('原图', style: TextStyle(color: Colors.white, fontSize: 16.0),),
          trailing: StreamBuilder(
              stream: _streamController.stream,
              initialData: chosenList,
              builder: (context, AsyncSnapshot snapshot)=>
              Text('预览 ${snapshot.data.length > 0 ? '( '+ snapshot.data.length.toString() + ' )' : ''}', style: TextStyle(color: Colors.white, fontSize: 16.0))
          ),
          trailingCallback: (){ _displayPhotoDetailPage(); },
        )
      ],
    );
  }

  void _displayGalleryList() async {
    var result = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => GalleryListDialog(currentGalleryIndex: currentGalleryIndex,),
    );
    if(result != null){
      print('result: $result');
      setState(() {
        currentGalleryIndex = result;
      });
    }
  }

  void _displayPhotoDetailPage(){
    if(chosenList.length > 0){
      Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) => new PhotoDetailPage(
                  photoCount: count,
                  index: 0,
                  chosenList: chosenList,
                  previewSelected: true,
                  isMultiChoice: widget.isMultiChoice
              )
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45.0),
        child: AppBar(
          backgroundColor: Colors.white,
          leading: OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: 100,
            child:GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(Icons.keyboard_arrow_left, color: Colors.black, size: 30,),
                    ),
                    Text('图片', style: TextStyle(
                        color: Colors.black, fontSize: 18
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            StreamBuilder(
              stream: _streamController.stream,
              initialData: chosenList,
              builder: (context, AsyncSnapshot snapshot)=>SureButton(
                enable: snapshot.data.length > 0,
                sureCallback: (){
                  if(widget.onDone != null){
                    widget.onDone(chosenList);
                  }
                },
              ),
            )
          ],
        ),
      ),
      body: _context(),
    );
  }
}


