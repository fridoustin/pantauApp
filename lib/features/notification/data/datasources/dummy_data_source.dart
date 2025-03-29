import 'package:pantau_app/features/notification/domain/entities/notification_entity.dart';

class DummyDataSource {
  final List<NotificationEntity> _dummyData = [
    NotificationEntity(
      id: '1',
      title: 'Work Order Baru Dibuat',
      message: 'Anda telah membuat work order baru dengan judul "xxxxx".',
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
      isRead: true,
    ),
    NotificationEntity(
      id: '2',
      title: 'Work Order Baru Dibuat',
      message: 'Anda telah membuat work order baru dengan judul "xxxxx".',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      isRead: true,
    ),
    NotificationEntity(
      id: '3',
      title: 'Work Order Baru Dibuat',
      message: 'Anda telah membuat work order baru dengan judul "xxxxx".',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
    ),
    NotificationEntity(
      id: '4',
      title: 'Laporan Kerja Berhasil Terkirim',
      message: 'Laporan Anda terkait work order dengan judul "xxxxx" telah dikirim dan sedang diproses.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
    ),
    NotificationEntity(
      id: '5',
      title: 'Work Order Baru Dibuat',
      message: 'Anda telah membuat work order baru dengan judul "xxxxx".',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
    NotificationEntity(
      id: '6',
      title: 'Laporan Kerja Berhasil Terkirim',
      message: 'Laporan Anda terkait work order dengan judul "xxxxx" telah dikirim dan sedang diproses.',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      isRead: true,
    ),
    NotificationEntity(
      id: '7',
      title: 'Status Work Order Diperbarui',
      message: 'Status work order dengan judul "xxxxx" kini dalam status "tunda", Periksa detail tugas.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    NotificationEntity(
      id: '8',
      title: 'Work Order Baru',
      message: 'Anda menerima work order baru dari admin dengan judul "xxxxx".',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
  ];

  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(seconds: 1)); // delay simulation
    return _dummyData;
  }

  Future<void> markAsRead(String notificationId) async {
    final index =
        _dummyData.indexWhere((element) => element.id == notificationId);
    if (index != -1) {
      _dummyData[index] = NotificationEntity(
        id: _dummyData[index].id,
        title: _dummyData[index].title,
        message: _dummyData[index].message,
        createdAt: _dummyData[index].createdAt,
        isRead: true,
      );
    }
  }
}
