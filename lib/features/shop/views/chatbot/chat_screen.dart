import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
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
  XFile? _selectImage;
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
    // updateMessageStatus();
    print("CHat_ID: $_chatUser.id");
    updateMessageStatus(_chatUser.id);
  }

  Future<void> updateMessageStatus(String userId) async {
    final DatabaseReference chatMessagesRef =
        FirebaseDatabase.instance.ref('chats/$userId/messages');

    try {
      final DatabaseEvent event = await chatMessagesRef.once();
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final Map<String, dynamic> updates = {};

        data.forEach((key, value) {
          if (value['status'] == 2) {
            updates[key] = {
              ...value,
              // 'status': 2, // Cập nhật trạng thái số nếu cần
              'trangThai': 'Đã xem', // Thay đổi trạng thái nếu cần
            };
          }
        });

        if (updates.isNotEmpty) {
          await chatMessagesRef.update(updates);
          print('Cập nhật trạng thái thành công!');
        }
      }
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái tin nhắn: $e');
    }
  }

  void _loadMessages() async {
    final messagesRef =
        _database.ref().child('chats').child(_chatUser.id).child('messages/');

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
        name: messageData['name'] ?? 'unknown',
        size: messageData['size'] ?? 0,
        height: messageData['height']?.toDouble() ?? 200.0,
        width: messageData['width']?.toDouble() ?? 200.0,
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
        'trangThai': 'Chưa xem',
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

  Future<types.ImageMessage> _uploadImage(
      List<int> bytes, String fileName) async {
    try {
      // Tải ảnh lên Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images/${const Uuid().v4()}.png');
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
                // const Divider(color: Colors.white),
                // _buildIconButton(Icons.insert_drive_file, Colors.green,
                //     _handleFileSelection),
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

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    if (result != null) {
      final bytes = await result.readAsBytes();
      final message = await _uploadImage(bytes, result.name);
    }
    return;
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

  Widget _buildMessage(Widget previousBubble,
      {required types.Message message, required bool nextMessageInGroup}) {
    final status = message.metadata?['status'] ?? 1;
    final isSender = status == 1;

    return Center(
      child: Align(
        alignment: isSender ? Alignment.topRight : Alignment.topLeft,
        child: ChatBubble(
          margin: const EdgeInsets.only(right: 10),
          clipper: isSender
              ? ChatBubbleClipper4(type: BubbleType.sendBubble) // Bóng chat gửi
              : ChatBubbleClipper4(type: BubbleType.receiverBubble),
          // Bóng chat nhận
          alignment: isSender ? Alignment.topRight : Alignment.topLeft,
          backGroundColor:
              isSender ? const Color(0xFFE3F2FD) : const Color(0xFFFFFFFF),
          child: message is types.TextMessage
              ? Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isSender ? Colors.black : Colors.black,
                  ),
                )
              : message is types.ImageMessage
                  ? Image.network(
                      message.uri ?? "", // Lấy URL ảnh từ message
                      fit: BoxFit.cover,
                      width: 200,
                      height: 450,
                    )
                  : Text(
                      "Hình ảnh hoặc file",
                      style: TextStyle(
                        color: isSender ? Colors.black : Colors.black54,
                      ),
                    ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhắn tin với cửa hàng',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SizedBox(
        child: Expanded(
          child: Center(
            widthFactor: double.infinity,
            child: Chat(
              messageWidthRatio: 0.84,
              messages: _messages,
              onAttachmentPressed: _handleAttachmentPressed,
              onSendPressed: _handleSendPressed,
              user: _chatUser,
              bubbleBuilder: _buildMessage,
              theme: DefaultChatTheme(
                inputBackgroundColor: Colors.white,
                inputTextDecoration: InputDecoration(
                  hintText: "Nhập văn bản...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
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
                inputTextCursorColor: Colors.blue,
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
        ),
      ),
    );
  }
}
