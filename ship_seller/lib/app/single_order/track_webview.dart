import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TrackWebViewUI extends StatefulWidget {
  String url;
  TrackWebViewUI({Key? key, required this.url}) : super(key: key);

  @override
  State<TrackWebViewUI> createState() => _TrackWebViewUIState();
}

class _TrackWebViewUIState extends State<TrackWebViewUI> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: webView(),
    );
  }

  Widget webView(){
    return WebView(
      zoomEnabled: false,
      initialUrl: widget.url,
      onProgress: (progress){
        print(progress);
      },
      onWebResourceError: (error){
        print(error.description);
      },
      onPageStarted: (msg){
        print('started');
        print(msg);
      },
    );
  }
}
