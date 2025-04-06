import 'package:flutter/material.dart';
import '../Services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });

      // ✅ Gọi API đánh dấu đã đọc sau khi hiển thị
      await _notificationService.markAllAsRead();
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thông báo")),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
            ? ListView(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Không có thông báo nào"),
              ),
            )
          ],
        )
            : ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            final createdAt =
            DateTime.parse(notification['createdAt']);
            final formattedDate =
            DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
            final isRead = notification['isRead'] ?? false;

            return ListTile(
              leading: Icon(
                Icons.notifications,
                color: isRead ? Colors.grey : Colors.deepPurple,
              ),
              title: Text(
                notification['message'],
                style: TextStyle(
                  fontWeight:
                  isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(formattedDate),
            );
          },
        ),
      ),
    );
  }
}
