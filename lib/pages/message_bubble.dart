import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderName;
  final String senderPhotoUrl;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.senderName,
    required this.senderPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    // 吹き出しの形を定義
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4), // 自分の発言は左下を少し角張らせる
      bottomRight: Radius.circular(isMe ? 4 : 16), // 相手の発言は右下を少し角張らせる
    );

    // アバターアイコン（画像URLがない場合はデフォルトアイコン）
    Widget avatar = CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey[300],
      backgroundImage: senderPhotoUrl.isNotEmpty
          ? NetworkImage(senderPhotoUrl)
          : null,
      child: senderPhotoUrl.isEmpty 
          ? Icon(Icons.smart_toy, color: Colors.grey[700]) // AIっぽくロボットアイコンに
          : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // 下揃えにするとチャットっぽい
        children: [
          // 左側（AI）のアイコン
          if (!isMe) ...[
            avatar,
            const SizedBox(width: 8),
          ],

          // メッセージ本文
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 153, 153, 153)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blueAccent : Colors.grey[200],
                    borderRadius: borderRadius,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 右側（自分）のアイコンは今回は省略（自分の顔は見えなくていいことが多いので）
        ],
      ),
    );
  }
}