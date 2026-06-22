import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../context/auth_provider.dart';
import '../models/chat_message.dart';

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({super.key});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  static const _background = Color(0xFF111827);
  static const _surface = Color(0xFF1F2937);
  static const _messageSurface = Color(0xFF374151);

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isSending = false;
  bool _isAtBottom = true;
  int _unreadCount = 0;
  int _lastMessageCount = 0;

  CollectionReference<Map<String, dynamic>> get _messages =>
      FirebaseFirestore.instance.collection('messages');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final distance =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    final atBottom = distance < 80;
    if (atBottom != _isAtBottom || (atBottom && _unreadCount > 0)) {
      setState(() {
        _isAtBottom = atBottom;
        if (atBottom) _unreadCount = 0;
      });
    }
  }

  void _handleMessagesUpdated(int count) {
    if (count <= _lastMessageCount) {
      _lastMessageCount = count;
      return;
    }
    final newMessages = count - _lastMessageCount;
    _lastMessageCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isAtBottom) {
        _scrollToBottom(animated: true);
      } else {
        setState(() => _unreadCount += newMessages);
      }
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
    setState(() {
      _isAtBottom = true;
      _unreadCount = 0;
    });
  }

  Future<void> _sendMessage(String author) async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      await _messages.add({
        'author': author,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
      });
      _controller.clear();
      _focusNode.requestFocus();
      _isAtBottom = true;
    } on FirebaseException catch (error) {
      if (mounted) {
        _showError(_firestoreMessage(error));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _likeMessage(String messageId) async {
    try {
      await _messages.doc(messageId).update({'likes': FieldValue.increment(1)});
    } on FirebaseException catch (error) {
      if (mounted) _showError(_firestoreMessage(error));
    }
  }

  String _firestoreMessage(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'Firestore Rules chưa cho phép thao tác này.';
    }
    return 'Không thể cập nhật cuộc trò chuyện. Vui lòng thử lại.';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _wrapSelection(String prefix, String suffix) {
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final selected = text.substring(start, end);
    final replacement = '$prefix$selected$suffix';
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(
        offset: start + replacement.length - suffix.length,
      ),
    );
    _focusNode.requestFocus();
    setState(() {});
  }

  void _insertText(String value) {
    final selection = _controller.selection;
    final offset = selection.isValid
        ? selection.start
        : _controller.text.length;
    _controller.value = TextEditingValue(
      text: _controller.text.replaceRange(offset, offset, value),
      selection: TextSelection.collapsed(offset: offset + value.length),
    );
    _focusNode.requestFocus();
    setState(() {});
  }

  Future<void> _signInWithGoogle() async {
    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } catch (_) {
      if (mounted) _showError('Không thể đăng nhập Google lúc này.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final username =
        user?.displayName ?? user?.email?.split('@').first ?? 'Người dùng';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat cộng đồng'),
            Text(
              'Admissions Compass',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _messages
                      .orderBy('timestamp', descending: false)
                      .limitToLast(100)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _errorState(snapshot.error);
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    final messages = snapshot.data!.docs
                        .map(ChatMessage.fromFirestore)
                        .toList();
                    _handleMessagesUpdated(messages.length);
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'Hãy là người đầu tiên gửi tin nhắn!',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) => _messageBubble(
                        messages[index],
                        messages[index].author == username,
                      ),
                    );
                  },
                ),
                if (!_isAtBottom)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.extended(
                      heroTag: 'scroll-chat-bottom',
                      onPressed: _scrollToBottom,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      label: Text(
                        _unreadCount > 0 ? '$_unreadCount tin mới' : 'Mới nhất',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          user == null ? _loginGate(auth.loading) : _composer(username),
        ],
      ),
    );
  }

  Widget _errorState(Object? error) {
    final message =
        error is FirebaseException && error.code == 'permission-denied'
        ? 'Firestore Rules chưa cho phép đọc collection messages.'
        : 'Không thể tải tin nhắn.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessage message, bool isOwn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isOwn
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isOwn) ...[_avatar(message.author), const SizedBox(width: 10)],
          Flexible(
            child: Column(
              crossAxisAlignment: isOwn
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isOwn ? 'Bạn' : message.author,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatChatTime(message.timestamp),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isOwn ? const Color(0xFF2563EB) : _messageSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isOwn ? 18 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 18),
                    ),
                    border: isOwn
                        ? null
                        : Border.all(color: const Color(0xFFF97316)),
                  ),
                  child: SelectableText(
                    message.content,
                    style: const TextStyle(color: Colors.white, height: 1.35),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _likeMessage(message.id),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.favorite_border,
                          color: Color(0xFFF9A8D4),
                          size: 18,
                        ),
                      ),
                    ),
                    Text(
                      '${message.likes}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    if (isOwn) ...[
                      const SizedBox(width: 10),
                      const Text(
                        '✓✓ Đã gửi',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isOwn) ...[const SizedBox(width: 10), _avatar('Bạn')],
        ],
      ),
    );
  }

  Widget _avatar(String name) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: getAvatarColor(name),
      child: Text(
        getInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _loginGate(bool loading) {
    return Container(
      width: double.infinity,
      color: _surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.login, color: Color(0xFF60A5FA), size: 38),
          const SizedBox(height: 8),
          const Text(
            'Đăng nhập để tham gia trò chuyện',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bạn cần đăng nhập bằng Google để gửi tin nhắn.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: loading ? null : _signInWithGoogle,
            icon: const Icon(Icons.login),
            label: const Text('Đăng nhập với Google'),
          ),
        ],
      ),
    );
  }

  Widget _composer(String username) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _toolButton('B', () => _wrapSelection('**', '**')),
                  _toolButton('I', () => _wrapSelection('_', '_')),
                  _toolIcon(Icons.code, () => _wrapSelection('`', '`')),
                  _toolIcon(Icons.link, () => _wrapSelection('[', '](url)')),
                  _toolIcon(Icons.emoji_emotions, () => _insertText(' 😊')),
                  _toolIcon(Icons.card_giftcard, () => _insertText(' 🎁')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 1000,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _sendMessage(username),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Viết tin nhắn của bạn...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: _background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _controller.text.trim().isEmpty || _isSending
                      ? null
                      : () => _sendMessage(username),
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đang chat dưới tên $username',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                Text(
                  '${_controller.text.length}/1000',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _toolIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      color: Colors.white70,
      icon: Icon(icon, size: 20),
    );
  }
}
