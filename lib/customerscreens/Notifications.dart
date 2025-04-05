import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> notifications = [];
  bool isLoading = true;
  late String uid;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!;
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });

    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    setState(() {
      notifications = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Color(0xFF006A4E),
      ),
      body: RefreshIndicator(
        onRefresh: fetchNotifications,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 150),
                      Center(
                        child: Text(
                          "No notifications yet.",
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      final DateTime createdAt = DateTime.parse(item['created_at']);
                      final String formattedDate = "${createdAt.day.toString().padLeft(2, '0')} "
                          "${_monthName(createdAt.month)} "
                          "${createdAt.year}, "
                          "${_formatTime(createdAt)}";

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF006A4E),
                            child: Icon(Icons.notifications, color: Colors.white),
                          ),
                          title: Text(
                            item['title'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['subtitle'] ?? '',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _monthName(int month) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month];
}

String _formatTime(DateTime dateTime) {
  int hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12 == 0 ? 12 : hour % 12;
  return "$hour:$minute $period";
}
}
