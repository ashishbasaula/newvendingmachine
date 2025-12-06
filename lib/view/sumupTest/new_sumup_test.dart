import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/sumup_services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class SumUpLoginWebView extends StatefulWidget {
  @override
  _SumUpLoginWebViewState createState() => _SumUpLoginWebViewState();
}

class _SumUpLoginWebViewState extends State<SumUpLoginWebView> {
  final String clientId = "cc_classic_emaAPrREo4OsOVOoWgPcL41BgBJS1";
  final String redirectUri =
      "https://manage.vvsvend.com/sumup/callback"; // Must match SumUp app settings
  String? accessToken;
  String? refreshToken;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (navigation) async {
            final url = navigation.url;
            if (url.startsWith(redirectUri)) {
              // Extract auth code
              final uri = Uri.parse(url);
              final code = uri.queryParameters['code'];
              if (code != null) {
                print("Authorization code: $code");

                // Close WebView
                Navigator.of(context).pop();

                // Exchange code for access token
                final sumupServiceController = Get.find<SumupServices>();
                await sumupServiceController.exchangeAuthCode(code);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://api.sumup.com/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login with SumUp")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
