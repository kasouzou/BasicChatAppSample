import 'package:flutter/material.dart';
import 'message_bubble.dart';


// メッセージを管理するためのシンプルなクラス
class ChatMessage {
  final String text;
  final bool isMe; // trueなら自分、falseならAI
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();

  // ---送るアイコンが押したときに通常アイコンに変化させて押した感を出す用---
  bool _isSendingPressed = false; 
  // ------------------

  // --- AIが返答中かどうかを管理するフラグ（これを使って二重送信を防ぐよ） ---
  bool _isAiResponding = false;
  // ------------------------------------------------------------------

  // --- ここを追加：リストのリモコン（過去の会話履歴をスクロール中または閲覧中でも、メッセージ送信時は最新メッセージに画面を戻す用） ---
  final ScrollController _scrollController = ScrollController(); 
  // --------------------------------
  
  // ここでメッセージのリストを保持します
  final List<ChatMessage> _messages = [];

  // メッセージ送信時の処理
  void _sendMessage() async {
    final text = _controller.text.trim();
    
    // 入力が空、またはAIが返答中なら処理を中断（ガード句）
    if (text.isEmpty || _isAiResponding) return;

    // 1. まず自分のメッセージをリストに追加して画面更新
    setState(() {
      _isAiResponding = true; // AIの返答モード開始
      _messages.insert(0, ChatMessage(
        text: text,
        isMe: true, // 自分
        timestamp: DateTime.now(),
      ));
    });
    
    _controller.clear(); // 入力欄をクリア

    // --- // 過去の会話履歴をスクロール中または閲覧中でも、メッセージ送信時は最新メッセージに画面を戻す用 ---
    // メッセージが画面に描画されるのを一瞬待ってからスクロールさせるよ
    _scrollToBottom();
    // ------------------------------

    // 2. AIが考えている風の演出（1秒待機）
    await Future.delayed(const Duration(seconds: 1));

    // 3. ボットからの定型文返信を追加
    setState(() {
      _messages.insert(0, ChatMessage(
        text: "AIからの返信です。\n「$text」と言いましたね？", 
        isMe: false, // AI（相手）
        timestamp: DateTime.now(),
      ));
      _isAiResponding = false; // AIの返答が完了したので解除
    });

    // AIの返信が来たときも最新位置へスクロール
    _scrollToBottom();
  }

  // スクロール処理を共通化したよ
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // reverse: true なので、0が一番下（最新）だよ
          duration: const Duration(milliseconds: 300), // 0.3秒かけて動く
          curve: Curves.easeOut, // 動きの種類（滑らかに止まる）
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 使い終わったリモコンを破棄する
    _controller.dispose();       // 入力欄のリモコンも忘れずに破棄！
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            
            Color.fromARGB(107, 0, 2, 48), 
            Color.fromARGB(255, 0, 17, 255),
            // Color.fromARGB(193, 0, 17, 255),
            
            
          ],
        ),
      ),       
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'AIチャット',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          // elevationを大きくすると影が強く出るよ。透明度の高いデザインなら小さめ(4とか)でも綺麗かも！
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: Column(
          children: [
            // チャット履歴表示エリア
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // ここで紐付け！
                reverse: true, // デフォルトだと最新のものが上に行くので逆転させることで最新を下にして、チャットアプリらしくする。
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageBubble(
                    text: message.text,
                    isMe: message.isMe,
                    senderName: message.isMe ? 'あなた' : 'AIボット',
                    senderPhotoUrl: '', 
                  );
                },
              ),
            ),
            // 入力エリア
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      // AIが返答中は入力欄を無効にする（ケアレスミス防止！）
                      enabled: !_isAiResponding, //If false the text field is "disabled":
                      decoration: InputDecoration(
                        hintText: _isAiResponding ? 'AIが返答中...' : 'メッセージを入力...',
                        filled: true, // 背景を塗りつぶす
                        fillColor: _isAiResponding ? Colors.white30 : Colors.white70, 
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)), // 角を丸く
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      // エンターキーでも送信できるようにする
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // --- 送信ボタンの切り替えロジック ---
                  GestureDetector(
                    // AIが返答中でない時だけ「押し込み」を検知
                    onTapDown: (_) {
                      if (!_isAiResponding) setState(() => _isSendingPressed = true);
                    },
                    onTapUp: (_) {
                      setState(() => _isSendingPressed = false);
                    },
                    onTapCancel: () {
                      setState(() => _isSendingPressed = false);
                    },
                    // AIが返答中ならタップしても反応しないようにする
                    onTap: _isAiResponding ? null : _sendMessage, 
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        // 押されている間は「塗りつぶし」、そうでない時は「アウトライン」
                        _isSendingPressed ? Icons.send : Icons.send_outlined,
                        // AIが返答中は色を薄くして「今は押せないよ」と視覚的に伝える
                        color: _isAiResponding ? Colors.white38 : Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  // -------------------------------
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}