import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF00FF41), Color(0xFF008F11)]),
              boxShadow: [BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.4), blurRadius: 8)],
            ),
            child: const Icon(Icons.assistant, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF008F11).withOpacity(0.7) : const Color(0xFF0A1A0A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: const Color(0xFF00FF41).withOpacity(0.25)),
                boxShadow: isUser ? [BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.15), blurRadius: 8)] : null,
              ),
              child: Text(message.text,
                style: GoogleFonts.rajdhani(color: isUser ? Colors.white : const Color(0xFF00FF41), fontSize: 15, height: 1.4)),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF008F11).withOpacity(0.3),
              border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.5)),
            ),
            child: const Icon(Icons.person, color: Color(0xFF00FF41), size: 18),
          ),
        ],
      ),
    );
  }
}
