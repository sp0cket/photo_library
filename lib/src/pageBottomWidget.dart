import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PageBottomWidget extends StatefulWidget {

  PageBottomWidget({
    this.leading,
    this.middle,
    this.trailing,
    this.leadingCallback,
    this.middleCallback,
    this.trailingCallback,
    Key key,
  }) : super(key: key);
  Widget leading, middle, trailing;
  VoidCallback leadingCallback,middleCallback,trailingCallback;

  @override
  _PageBottomWidget createState() => _PageBottomWidget();
}

class _PageBottomWidget extends State<PageBottomWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff36373C),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Offstage(
            offstage: widget.leading == null,
            child: FlatButton(
              onPressed: (){
                if(widget.leadingCallback != null){
                  widget.leadingCallback();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: widget.leading,
              ),
            ),
          ),
          Offstage(
            offstage: widget.middle == null,
            child: FlatButton(
              onPressed: (){
                if(widget.middleCallback != null){
                  widget.middleCallback();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: widget.middle,
              ),
            ),
          ),
          Offstage(
            offstage: widget.trailing == null,
            child: FlatButton(
              onPressed: (){
                if(widget.trailingCallback != null){
                  widget.trailingCallback();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: widget.trailing,
              ),
            ),
          )
        ],
      ),
    );
  }
}