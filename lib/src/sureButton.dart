import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SureButton extends StatefulWidget {

  SureButton({
    Key key,
    this.sureCallback,
    this.enable = true
  }) : super(key: key);
  bool enable;
  VoidCallback sureCallback;

  @override
  _SureButton createState() => _SureButton();
}

class _SureButton extends State<SureButton> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(widget.enable && widget.sureCallback != null){
          widget.sureCallback();
        }
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  border: new Border.all(color: Colors.green),
                  borderRadius: const BorderRadius.all(const Radius.circular(3.0)),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(13, 5, 13, 5),
                  child: Text(
                      '确定',
                      style: TextStyle(color: Colors.white, fontSize: 16)
                  ),
                ),
              ),
            )
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              color: widget.enable ? Colors.transparent : Colors.white.withOpacity(0.5),
            ),
          )
        ],
      ),
    );
  }
}