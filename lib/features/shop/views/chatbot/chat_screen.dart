import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final types.User _chatUser = types.User(
    id: FirebaseAuth.instance.currentUser?.uid ?? '',
    firstName: FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous',
  );

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenForNewMessages(); // Lắng nghe tin nhắn mới
  }

  void _loadMessages() async {
    final messagesRef =
        _database.ref().child('chats').child(_chatUser.id).child('messages');

    final snapshot = await messagesRef.orderByChild('createdAt').get();
    final loadedMessages = <types.Message>[];

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        final messageData = child.value as Map<dynamic, dynamic>;
        final message = _convertMessageFromData(messageData);
        if (message != null) {
          loadedMessages.add(message);
        }
      }
    }

    setState(() {
      _messages.clear();
      _messages.addAll(loadedMessages
          .reversed); // Đảm bảo danh sách tin nhắn theo thứ tự thời gian
    });
  }

  void _listenForNewMessages() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final messagesRef =
        _database.ref().child('chats').child(userId).child('messages');

    messagesRef.onChildAdded.listen((event) {
      final messageData = event.snapshot.value as Map<dynamic, dynamic>;
      final message = _convertMessageFromData(messageData);
      if (message != null && !_messages.any((msg) => msg.id == message.id)) {
        setState(() {
          _messages.insert(0, message);
        });
      }
    });
  }

  types.Message? _convertMessageFromData(Map<dynamic, dynamic> messageData) {
    final author = _chatUser;
    final createdAt = messageData['createdAt'];
    final id = messageData['id'];
    final status = messageData['status'] ?? 1; // Mặc định status là 1

    if (messageData['text'] != null) {
      return types.TextMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        text: messageData['text'],
        metadata: {'status': status}, // Lưu trạng thái vào metadata
      );
    } else if (messageData['imageUrl'] != null) {
      return types.ImageMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        uri: messageData['imageUrl'],
        name: messageData['name'],
        size: messageData['size'],
        height: messageData['height'],
        width: messageData['width'],
        metadata: {'status': status}, // Thêm trạng thái vào metadata
      );
    } else if (messageData['fileUrl'] != null) {
      return types.FileMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        mimeType: messageData['mimeType'],
        name: messageData['name'],
        size: messageData['size'],
        uri: messageData['fileUrl'],
        metadata: {'status': status}, // Thêm trạng thái vào metadata
      );
    }
    return null;
  }

  void _handleSendPressed(types.PartialText message) async {
    if (message.text.isNotEmpty) {
      final textMessage = types.TextMessage(
        author: _chatUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message.text,
      );

      await _saveMessageToFirebase(textMessage);
      // Không thêm tin nhắn trực tiếp vào _messages, vì đã có Firebase xử lý
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message); // Add new message to the top
    });
  }

  Future<void> _saveMessageToFirebase(types.Message message) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User is not logged in');
        return;
      }

      // Tham chiếu đến chat của người dùng
      final messageRef =
          FirebaseDatabase.instance.ref('chats/$userId/messages').push();

      // Lấy thông tin người dùng từ Firebase
      final userRef = FirebaseDatabase.instance.ref('users/$userId');
      final userSnapshot = await userRef.get();
      print('Du lieu user: $userSnapshot');

      if (!userSnapshot.exists) {
        print('User data does not exist in Firebase');
        return;
      }

      // Kiểm tra và ép kiểu giá trị trả về từ Firebase
      final userData = userSnapshot.value;
      if (userData == null || userData is! Map) {
        print('User data is invalid or not a map');
        return;
      }

      // Ép kiểu an toàn sang Map<String, dynamic>
      final userMap = Map<String, dynamic>.from(userData);

      // Tạo dữ liệu tin nhắn
      final messageData = {
        'authorId': message.author.id,
        'createdAt': message.createdAt,
        'id': message.id,
        'status': 1,
        'nameUser': userMap['name'] ?? 'Unknown',
        'imageUser': userMap['image'] ?? 'default_image_url',
      };

      // Thêm nội dung tin nhắn tùy theo loại tin nhắn
      if (message is types.TextMessage) {
        messageData['text'] = message.text;
      } else if (message is types.ImageMessage) {
        messageData['imageUrl'] = message.uri;
        messageData['name'] = message.name;
        messageData['size'] = message.size;
        messageData['height'] = message.height;
        messageData['width'] = message.width;
      } else if (message is types.FileMessage) {
        messageData['fileUrl'] = message.uri;
        messageData['name'] = message.name;
        messageData['size'] = message.size;
        messageData['mimeType'] = message.mimeType;
      }

      // Lưu dữ liệu tin nhắn vào Firebase
      await messageRef.set(messageData);
      print('Message saved successfully');
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Container(
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: <Widget>[
                _buildIconButton(
                    Icons.photo_library, Colors.blue, _handleImageSelection),
                const Divider(color: Colors.white),
                _buildIconButton(Icons.insert_drive_file, Colors.green,
                    _handleFileSelection),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Icon(
          icon,
          color: color,
          size: 28.0,
        ),
      ),
    );
  }

  Future<types.ImageMessage> _uploadImage(
      List<int> bytes, String fileName) async {
    try {
      // Tải ảnh lên Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images/${const Uuid().v4()}.jpg');
      await storageRef.putData(Uint8List.fromList(bytes));
      final imageUrl =
          await storageRef.getDownloadURL(); // Lấy URL của ảnh đã tải lên

      // Tạo message kiểu ImageMessage
      final imageMessage = types.ImageMessage(
        author: _chatUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: 200.0,
        id: const Uuid().v4(),
        name: fileName,
        size: bytes.length,
        uri: imageUrl, // Lưu URL của ảnh
        width: 200.0,
      );

      // Lưu tin nhắn vào Firebase Realtime Database
      await _saveMessageToFirebase(imageMessage);

      // Trả về imageMessage để có thể thêm vào giao diện nếu cần
      return imageMessage;
    } catch (e) {
      print("Error uploading image: $e");
      // Trả về đối tượng mặc định nếu có lỗi
      return types.ImageMessage(
        author: _chatUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: 0.0,
        id: const Uuid().v4(),
        name: "error",
        size: 0,
        uri: "", // Không có URL nếu lỗi
        width: 0.0,
      );
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final message =
          await _uploadImage(bytes, result.name); // Tải ảnh và lưu tin nhắn
      _addMessage(message); // Thêm tin nhắn vào UI
    }
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _chatUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: result.files.single.extension,
        name: result.files.single.name,
        size: result.files.single.size,
        uri:
            result.files.single.path!, // Đường dẫn file trên máy của người dùng
      );

      await _saveMessageToFirebase(
          message); // Lưu tin nhắn vào Firebase Realtime Database
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat với cửa hàng")),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              onAttachmentPressed: _handleAttachmentPressed,
              onSendPressed: _handleSendPressed,
              user: _chatUser,
              theme: DefaultChatTheme(
                inputBackgroundColor: Colors.white,
                inputTextDecoration: InputDecoration(
                  hintText: "Nhập văn bản...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                inputTextColor: Colors.black,
                inputTextStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                primaryColor: const Color(0xFF80DEEA),
                backgroundColor: const Color(0xFFF5F5F5),
                sentMessageBodyTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                receivedMessageBodyTextStyle: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                sendButtonIcon: const Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
                attachmentButtonIcon: const Icon(
                  Icons.photo_library,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
