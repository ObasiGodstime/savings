library animated_progress_button;
import 'package:flutter/material.dart';
import 'package:animated_progress_button/animated_progress_button.dart';
import '../size_config.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';

class LoadButton extends StatefulWidget {
  const LoadButton(
      {Key key,
      @required this.text,
      @required this.controller,
      this.loadedIcon,
      this.height,
      this.loadingText,
      this.onPressed})
      : super(key: key);


  /// Initial text display
  final String text;

  /// Loading text
  final String loadingText;

  /// You can also customized the last icon appear in the animation progress.
  final Widget loadedIcon;

  /// Default 50.
  final double height;

  /// AnimatedButtonController to help control the animation progress.
  /// Call [controller.completed()] when getting response from your request
  /// Call [controller.reset()] to restart button animation
  final LoadButtonController controller;

  /// Customize on pressing action
  final VoidCallback onPressed;

  @override
  _LoadButtonState createState() => _LoadButtonState();
}

class _LoadButtonState extends State<LoadButton>
    with TickerProviderStateMixin {
  static int simulatedLoadingTime = 3;
  bool _isLoading = false;
  AnimationController _animationController;
  Animation<double> _progressAnimation;
  Animation<double> _buttonWidthAnimation;
  Animation<Offset> _checkIconOffsetAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller?.addLoadedListener((bool shouldReset) {
      if (shouldReset) {
        _animationController.reset();
        _isLoading = false;
        return;
      }
      _animationController.forward(from: 0.6);
    });
    _animationController = AnimationController(
        duration: Duration(seconds: simulatedLoadingTime), vsync: this)
      ..addListener(() {
        if (_animationController.value >= 0.6 &&
            !(widget.controller?.value ?? true)) {
          _animationController.stop(canceled: false);
        }
        setState(() {});
      });
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.0, 0.7, curve: Curves.ease)));
    _buttonWidthAnimation = Tween<double>(begin: 400, end: 50).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.7, 0.9, curve: Curves.decelerate)));
    _checkIconOffsetAnimation =
        Tween<Offset>(begin: Offset(0, -2), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController,
                curve: Interval(0.9, 1.0, curve: Curves.easeOutBack)));
  }

  bool get _progressLoadingCompleted => _progressAnimation.value == 1.0;
  bool get _visibleIcon => _checkIconOffsetAnimation.value.dy > -2;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 50,
      width: double.infinity,
      // margin: EdgeInsets.only(top: 32.0, left: 5.0, right: 5.0),
      child: FlatButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          if (_isLoading) return;
          _isLoading = true;
          _animationController.forward();
          if (widget.onPressed != null) {
            widget.onPressed();
          }
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: Hexcolor("0066F5"),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3),
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 1.0)
                ]),
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                          _progressLoadingCompleted
                              ? ""
                              : _isLoading
                                  ? (widget.loadingText.toUpperCase() ?? 'IN PROGRESS ...')
                                  : (widget.text.toUpperCase() ?? ''),
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ],
                ),
                _progressLoadingCompleted
                    ? Container()
                    : Container(
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(.5)),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                Visibility(
                  visible: _visibleIcon,
                  child: SlideTransition(
                      position: _checkIconOffsetAnimation,
                      child: Center(
                          child: widget.loadedIcon ??
                              Icon(Icons.check, color: Colors.white))),
                )
              ],
            )),
      ),
    );
  }
}

typedef void OnLoaded(bool shouldReset);

class LoadButtonController extends ValueNotifier<bool> {
  OnLoaded _callback;

  LoadButtonController({bool value = false}) : super(value);

  void completed() {
    value = true;
    if (_callback != null) {
      _callback(false);
    }
  }

  void addLoadedListener(OnLoaded callback) {
    this._callback = callback;
  }

  void reset() {
    value = false;
    if (_callback != null) {
      _callback(true);
    }
  }
}
