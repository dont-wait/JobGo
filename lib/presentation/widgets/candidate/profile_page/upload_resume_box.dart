// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../../core/configs/theme/app_colors.dart';

// class UploadResumeBox extends StatelessWidget {
//   const UploadResumeBox({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primary),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: AppColors.primary,
//             child: const Icon(Icons.upload, color: Colors.white),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Upload a new resume',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'PDF, DOCX up to 10MB',
//             style: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: 12),
//           // ElevatedButton(
//           //   onPressed: () {},
//           //   child: const Text('Browse Files'),
//           // ),
//           ElevatedButton(
//             onPressed: () async {
//               final result = await FilePicker.platform.pickFiles(
//                 type: FileType.custom,
//                 allowedExtensions: ['pdf', 'docx'],
//               );

//               if (result != null) {
//                 final supabase = Supabase.instance.client;
//                 final file = File(result.files.single.path!);

//                 final response = await supabase.storage
//                     .from('cv-bucket')
//                     .upload('cv/${file.uri.pathSegments.last}', file);

//                 print("Uploaded: $response");
//               }
//             },
//             child: const Text('Browse Files'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import '../../../../core/configs/theme/app_colors.dart';

class UploadResumeBox extends StatefulWidget {
  const UploadResumeBox({super.key});

  @override
  State<UploadResumeBox> createState() => _UploadResumeBoxState();
}

class _UploadResumeBoxState extends State<UploadResumeBox> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.upload, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload a new resume',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PDF, DOCX up to 10MB',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadResume,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Browse Files'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadResume() async {
    try {
      // Chọn file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result == null) return;

      setState(() => _isUploading = true);

      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final filePath = '${authUser.id}/$fileName';

      // Upload lên Supabase Storage
      await supabase.storage
          .from('cv-bucket')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // Lấy public URL
      final publicUrl = supabase.storage
          .from('cv-bucket')
          .getPublicUrl(filePath);

      // Update c_resume trong bảng candidates - sử dụng ProfileProvider để thêm vào mảng
      if (!mounted) return;
      await context.read<ProfileProvider>().addResume(publicUrl);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload thành công: $fileName'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload thất bại: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}
