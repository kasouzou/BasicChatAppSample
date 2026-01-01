//　※このクラスのファイル名について、SplashScreenがアプリ起動時に一瞬だけ表示される機能そのものの名前なので、意味が重複するが、SplashScreenPageとし、SplashScreenは一つの塊としてみて、SplashScreenという機能を提供するPageであることをここに強く宣言しておく。わかりにくくてごめん♡

import 'package:chat_app_sample/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChromeを使うために必要

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    // アプリの起動時に画面が自動で次に遷移するよう設定
    // 💡 UI関連の変更はinitStateに移動
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _navigateToNextScreen();
  }

  // 画面遷移ロジック
  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(),
        settings: RouteSettings(name: 'ChatPage'), // ← 名前を付ける
      ),
    );
  }

  @override
  void dispose() {
    // 💡 画面が破棄される時に元のUI設定に戻す
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // スプラッシュ画面のステータスバーとナビゲーションバーを非表示にする
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Container(
      decoration:  const BoxDecoration(
        gradient: LinearGradient(
          // グラデーションの向き（左上から右下へ）
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 0, 204, 255), // 水色
            Color.fromARGB(193, 0, 5, 79),    // 濃い紺（少し透明）
          ],
        ),
      ),
      child: Scaffold(
        // スプラッシュ画面の背景色
        backgroundColor: Colors.transparent, // Containerの背景色を優先させるため透明に設定
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ロゴ画像を表示（角を丸くする）
              ClipRRect( // ここを追加
                borderRadius: BorderRadius.circular(20.0), // ここで角の丸みを設定（例: 20.0）
                child: 
                Image.asset(
                  'assets/icon/icon.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    // エラー発生時にコンソール出力
                    print('画像の読み込みに失敗しました: $error');
                    return Icon(
                      Icons.error,
                      size: 100,
                      color: Colors.white, // 自作,
                    ); // 代替表示
                  }
                ),
              ), // ここを追加
              const SizedBox(height: 20),
              // ロゴの下にテキストを表示
              Text(
                'AI搭載アプリ',
                style: TextStyle(
                  color: Colors.white, // 自作
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
