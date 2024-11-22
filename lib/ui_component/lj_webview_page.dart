import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class LJWebViewPage extends StatefulWidget {
  final String url;
  final String? title;
  final Color progressColor;
  final List<String>? jsMethods;
  final Function(String method, JavaScriptMessage message)? jsCallback;

  const LJWebViewPage({
    Key? key,
    required this.url,
    this.title,
    this.progressColor = Colors.blue,
    this.jsMethods,
    this.jsCallback,
  }) : super(key: key);

  @override
  State<LJWebViewPage> createState() => _LJWebViewPageState();
}

class _LJWebViewPageState extends State<LJWebViewPage> {
  bool _canBack = false;
  bool _canForward = false;

  late WebViewController _webViewController;

  late ValueNotifier<String> _titleNotifier;
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();

    _titleNotifier = ValueNotifier(widget.title ?? '');

    _configWebView();

    if (widget.url.startsWith('http')) {
      _webViewController.loadRequest(Uri.parse(widget.url));
    } else {
      _webViewController.loadHtmlString(widget.url);
    }
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
        onProgress: (int progress) {
          _progressNotifier.value = progress * 0.01;
        },
        onPageFinished: (String url) async {
          _titleNotifier.value =
              await _webViewController.getTitle() ?? widget.title ?? '';
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
      appBar: AppBar(
        title: ValueListenableBuilder(
            valueListenable: _titleNotifier,
            builder: (BuildContext context, String title, Widget? child) {
              return Text(title);
            }),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0), // 设置PreferredSize的高度
          child: ValueListenableBuilder(
              valueListenable: _progressNotifier,
              builder: (BuildContext context, double progress, Widget? child) {
                if (progress >= 1) return const SizedBox();

                return LinearProgressIndicator(
                  value: progress,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.progressColor),
                );
              }),
        ),
      ),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
