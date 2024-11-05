
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class LJWebViewPage extends StatefulWidget {
  final String url;
  final List<String>? jsMethods;
  final Function(String method, JavaScriptMessage message)? jsCallback;

  const LJWebViewPage({
    Key? key,
    required this.url,
    this.jsMethods,
    this.jsCallback,
  }) : super(key: key);

  @override
  State<LJWebViewPage> createState() => _LJWebViewPageState();
}

class _LJWebViewPageState extends State<LJWebViewPage> {
  String? _title;
  bool _canBack = false;
  bool _canForward = false;

  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    _configWebView();
  }

  void _configWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params);
    _webViewController.setBackgroundColor(Colors.transparent);
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.enableZoom(false);
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) async {
          _title = await _webViewController.getTitle() ?? _title;
          _canBack = await _webViewController.canGoBack();
          _canForward = await _webViewController.canGoForward();

          setState(() {});
        },
        onNavigationRequest: (NavigationRequest request) async {
          if (!(request.url.startsWith("http:") ||
              request.url.startsWith("https:"))) {
            await launchUrl(Uri.parse(request.url));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
      (_webViewController.platform as AndroidWebViewController)
          .setTextZoom(100);
    }
    
    widget.jsMethods?.forEach((method) {
      _webViewController.addJavaScriptChannel(
        method,
        onMessageReceived: (JavaScriptMessage message) {
          widget.jsCallback?.call(method, message);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title ?? '')),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
