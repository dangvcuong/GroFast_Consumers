import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/oder_detailscreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DatabaseReference _notificationsRef =
      FirebaseDatabase.instance.ref().child('notifications');
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final Login_Controller login_controller = Login_Controller();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _listenForChanges(); // Lắng nghe sự thay đổi trong thông báo
  }

  // Hàm lấy thông báo theo userId
  void _fetchNotifications() async {
    if (currentUser != null) {
      String userId = currentUser!.uid;

      try {
        // Lấy dữ liệu thông báo từ Firebase theo userId
        final snapshot = await _notificationsRef.child(userId).get();

        if (snapshot.exists) {
          List<Map<String, dynamic>> notifications = [];
          final data = snapshot.value;

          if (data is Map) {
            data.forEach((key, value) {
              if (value is Map) {
                // Thêm 'id' (key) vào mỗi thông báo
                final notification = Map<String, dynamic>.from(value);
                notification['id'] = key; // Gắn key làm id
                notifications.add(notification);
              }
            });

            // Sắp xếp thông báo theo timestamp từ mới nhất đến cũ nhất
            notifications.sort((a, b) {
              int timestampA = a['timestamp'] ?? 0;
              int timestampB = b['timestamp'] ?? 0;
              return timestampB.compareTo(timestampA); // Sắp xếp giảm dần
            });

            // Cập nhật trạng thái và danh sách thông báo
            setState(() {
              _notifications = notifications;
              _isLoading = false;
            });
          }
        } else {
          // Không có thông báo
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching notifications: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm lắng nghe sự thay đổi của thông báo
  // Hàm lắng nghe sự thay đổi của thông báo
  void _listenForChanges() {
    if (currentUser != null) {
      String userId = currentUser!.uid;

      // Lắng nghe khi có thông báo được thêm vào
      _notificationsRef.child(userId).onChildAdded.listen((event) {
        // Chỉ thêm thông báo mới nếu chưa có trong danh sách
        final notification =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        notification['id'] = event.snapshot.key;

        // Kiểm tra xem thông báo đã tồn tại trong danh sách chưa
        if (!_notifications.any((n) => n['id'] == notification['id'])) {
          setState(() {
            _notifications.insert(0, notification); // Chèn vào đầu danh sách
            _notifications.sort((a, b) {
              int timestampA = a['timestamp'] ?? 0;
              int timestampB = b['timestamp'] ?? 0;
              return timestampB.compareTo(timestampA); // Sắp xếp giảm dần
            });
          });
        }
      });

      // Lắng nghe khi có thông báo thay đổi
      _notificationsRef.child(userId).onChildChanged.listen((event) {
        final updatedNotification =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        updatedNotification['id'] = event.snapshot.key;

        // Cập nhật thông báo đã thay đổi nếu nó có trong danh sách
        setState(() {
          _notifications = _notifications.map((notification) {
            if (notification['id'] == updatedNotification['id']) {
              return updatedNotification;
            } else {
              return notification;
            }
          }).toList();

          // Sắp xếp lại sau khi cập nhật
          _notifications.sort((a, b) {
            int timestampA = a['timestamp'] ?? 0;
            int timestampB = b['timestamp'] ?? 0;
            return timestampB.compareTo(timestampA); // Sắp xếp giảm dần
          });
        });
      });

      // Lắng nghe khi có thông báo bị xóa
      _notificationsRef.child(userId).onChildRemoved.listen((event) {
        setState(() {
          _notifications.removeWhere(
            (notification) => notification['id'] == event.snapshot.key,
          );
        });
      });
    }
  }

  // Hàm xóa thông báo theo id
  void _deleteNotification(String? notificationId) async {
    if (notificationId == null || currentUser == null) {
      print('Invalid notificationId or user is not logged in');
      return;
    }

    try {
      // Xóa thông báo từ Firebase
      await _notificationsRef
          .child(currentUser!.uid)
          .child(notificationId)
          .remove();

      // Cập nhật lại danh sách thông báo sau khi xóa
      setState(() {
        _notifications.removeWhere(
            (notification) => notification['id'] == notificationId);
      });
      login_controller.ThongBao(context, 'Thông báo đã bị xóa');
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Hàm chuyển đổi timestamp thành định dạng ngày/giờ
  String _formatTimestamp(int? timestamp) {
    if (timestamp == null || timestamp == 0) {
      return 'Không xác định';
    }
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          automaticallyImplyLeading: false, // Ẩn nút quay lại
          backgroundColor: Colors.blueAccent,
          title: const Text(
            'Thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true, // Căn giữa tiêu đề
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text(
            'Bạn cần đăng nhập để xem thông báo.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ẩn nút quay lại
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Căn giữa tiêu đề
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'Không có thông báo nào.',
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final notificationId = notification['id'];
                    final idorder = notification['idOrder'];
                    return Dismissible(
                      key: Key(notificationId ?? index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        if (notificationId != null) {
                          _deleteNotification(notificationId);
                        }
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetail(idorder),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            title: Text(
                              notification['title'] ?? 'Không có tiêu đề',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  notification['body'] ?? 'Không có nội dung',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTimestamp(
                                      notification['timestamp'] as int?),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            leading: const Icon(
                              Icons.notifications_active,
                              color: Colors.blueAccent,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
