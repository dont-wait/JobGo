import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyDetailPage extends StatelessWidget {
  final Map<String, dynamic> employer;

  const CompanyDetailPage({super.key, required this.employer});

  @override
  Widget build(BuildContext context) {
    final logoUrl = employer['e_logo_url'];
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(employer['e_company_name'] ?? 'Chi tiết công ty'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red,),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với logo
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: logoUrl != null && logoUrl.isNotEmpty
                          ? NetworkImage(logoUrl)
                          : const AssetImage("assets/images/role_candidate1.jpg")
                              as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        employer['e_company_name'] ?? 'Chưa có tên',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Giới thiệu
            const Text(
              "Giới thiệu",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                employer['e_company_description'] ?? 'Chưa có mô tả',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Thông tin liên hệ
            const Text(
              "Thông tin liên hệ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _info(Icons.location_on, employer['e_company_address'] ?? 'Chưa có địa chỉ'),
            _info(Icons.language, employer['e_website'] ?? 'Chưa có website'),
            _info(Icons.email_outlined, employer['e_email'] ?? 'Chưa có email'),
            _info(Icons.phone_outlined, employer['e_phone'] ?? 'Chưa có số điện thoại'),
            _info(Icons.groups_rounded, employer['e_company_size'] ?? 'Chưa có quy mô'),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    );
  }
  void _confirmDelete(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text(
            "Xác nhận xóa",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
      content: const Text(
        "Bạn có chắc muốn xóa hồ sơ công ty này không?",
        style: TextStyle(fontSize: 15, color: Colors.black87),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx), // Hủy
          child: const Text(
            "Hủy",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(ctx); // đóng dialog

            try {
              final supabase = Supabase.instance.client;
              await supabase
                  .from('employers')
                  .update({
                    'e_company_name': null,
                    'e_company_description': null,
                    'e_company_address': null,
                    'e_website': null,
                    'e_phone': null,
                    'e_email': null,
                    'e_industry': null,
                    'e_company_size': null,
                  })
                  .eq('u_id', employer['u_id']);

              if (context.mounted) {
                Navigator.pop(context); // quay về trang trước
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã xóa hồ sơ công ty"),
                    backgroundColor: Colors.red,
                  ),
                );
                
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi xóa: $e")),
                );
              }
            }
          },
          icon: const Icon(Icons.delete, color: Colors.white),
          label: const Text("Xác nhận"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ),
  );
}


}

