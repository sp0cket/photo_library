import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_provider/photo_provider.dart';
import './photoDetailPage.dart';
import './pageBottomWidget.dart';
import './galleryListDialog.dart';
import './sureButton.dart';
class PhotoListPage extends StatefulWidget {
  PhotoListPage({@required this.sure});
  ValueChanged sure;
  @override
  State<StatefulWidget> createState() => new _PhotoListPage();
}

class _PhotoListPage extends State<PhotoListPage> {
  List<int> chosenList = [];
  int count = 0;
  int currentGalleryIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPhotoProvider();
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
    var list = await PhotoProvider.getImage(index, width: 300, height: 300);
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
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (context) => new PhotoDetailPage(
                      photoCount: count,
                      index: index,
                      chosenList: chosenList
                  )
                )
              );//
            },
            child: Hero(
              tag: 'hero$index',
              flightShuttleBuilder: (flightContext, animation, direction,
                  fromContext, toContext) {
                if(direction == HeroFlightDirection.push) {
                  return Icon(
                    Icons.audiotrack,
                    size: 150.0,
                  );
                } else if (direction == HeroFlightDirection.pop){
                  return Icon(
                    Icons.audiotrack,
                    size: 70.0,
                  );
                }
              },
              child: Image.memory(list, fit: BoxFit.cover,),
            ),
          )
        ),
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
              setState(() {
                if(chosenList.indexOf(index) >= 0){
                  chosenList.remove(index);
                }else{
                  chosenList.add(index);
                }
              });
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
                    child: Image.asset('images/chosen.png',color: Colors.white,)
                ),
              ),
            )
          ),
        )
      ],
    );
  }

  Widget _imageFutureBuilder(idx){
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

  Widget _context() {
    return Stack(
      children: <Widget>[
        Scrollbar(
          child: GridView.custom(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: 2.0, crossAxisSpacing: 2.0),
            childrenDelegate: SliverChildBuilderDelegate(
                (context, int)=>_imageFutureBuilder(count - int - 1),
              childCount: count,

            )),
//            itemCount: count,
//            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                crossAxisCount: 4, mainAxisSpacing: 2.0, crossAxisSpacing: 2.0),
//            itemBuilder: (ctx, idx) {
//              return _imageFutureBuilder(count - idx - 1);
//            }),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: PageBottomWidget(
            leading: Row(
              children: <Widget>[
                Text('图片', style: TextStyle(color: Colors.white, fontSize: 16.0),),
                Image.asset('images/triangle_more.png'),
              ],
            ),
//            leadingCallback: (){ _displayGalleryList(); },
//            middle: Text('原图', style: TextStyle(color: Colors.white, fontSize: 16.0),),
            trailing: Text('预览 ${chosenList.length > 0 ? '( '+ chosenList.length.toString() + ' )' : ''}', style: TextStyle(color: Colors.white, fontSize: 16.0)),
            trailingCallback: (){ _displayPhotoDetailPage(); },
          ),
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
            SureButton(
              enable: chosenList.length > 0,
              sureCallback: (){
                print('确认');
                widget.sure?.call(chosenList);
              },
            )
          ],
        ),
      ),
      body: _context(),
    );
  }
}
