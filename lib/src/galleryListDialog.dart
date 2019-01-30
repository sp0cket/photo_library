import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class GalleryListDialog extends StatefulWidget {

  GalleryListDialog({
    Key key,
    this.boxWidth = 80,
    this.currentGalleryIndex
  }) : super(key: key);
  double boxWidth;
  int currentGalleryIndex;

  @override
  _GalleryListDialog createState() => _GalleryListDialog();
}

class _GalleryListDialog extends State<GalleryListDialog> {

  Widget _imageBox (width){
    return Container(
      width: width + 3.0,
      height: width + 3.0,
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            left: 2.0,
            top: 2.0,
            child: Container(
              width: width,
              height: width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  boxShadow: [ BoxShadow(
                    color: Colors.grey,
                    offset: Offset(1.0, 1.0),
                  ) ]
              ),
            ),
          ),
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white), right: BorderSide(color: Colors.white)),
                color: Colors.grey,
                boxShadow: [ BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.5, 1.5),
                ) ]
            ),
//            child: Image.memory(bytes),
          ),

        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Container(
        height: 800,
        child: Scrollbar(
          child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return FlatButton(
                onPressed: (){
                  Navigator.pop(context, index);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            _imageBox(widget.boxWidth),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text('list$index'),
                            )
                          ],
                        ),
                      ),
                      Offstage(
                        offstage: index != widget.currentGalleryIndex,
                        child: Radio(
                          value: index,
                          activeColor: Colors.green,
                          groupValue: index,
                          onChanged: (newValue){},
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: 6
          ),
        ),
      ),
    );
  }
}