# Admin Module - JobGo

## Tổng quan

Module quản trị viên (Admin) cho ứng dụng JobGo với đầy đủ chức năng quản lý hệ thống.

## Cấu trúc thư mục

```
lib/
├── data/
│   └── models/
│       ├── admin_stats_model.dart      # Model thống kê admin
│       ├── admin_user_model.dart        # Model người dùng
│       └── job_moderation_model.dart    # Model kiểm duyệt công việc
│
├── presentation/
│   ├── pages/
│   │   └── admin/
│   │       ├── admin_app_shell.dart              # Shell navigation chính
│   │       ├── dashboard/
│   │       │   └── admin_dashboard_page.dart     # Trang tổng quan hệ thống
│   │       ├── moderation/
│   │       │   └── job_moderation_page.dart      # Trang kiểm duyệt tin tuyển dụng
│   │       ├── users/
│   │       │   └── user_management_page.dart     # Trang quản lý người dùng
│   │       └── profile/
│   │           └── admin_profile_page.dart       # Trang hồ sơ admin
│   │
│   └── widgets/
│       └── admin/
│           ├── dashboard/
│           │   ├── admin_header.dart             # Header trang dashboard
│           │   ├── stat_card.dart                # Card hiển thị thống kê
│           │   ├── growth_chart.dart             # Biểu đồ tăng trưởng
│           │   └── admin_recent_activity.dart    # Hoạt động gần đây
│           │
│           ├── moderation/
│           │   ├── moderation_tabs.dart          # Tabs (Pending/Approved/Rejected)
│           │   ├── job_moderation_card.dart      # Card công việc cần kiểm duyệt
│           │   └── rejection_dialog.dart         # Dialog từ chối công việc
│           │
│           └── users/
│               ├── user_type_tabs.dart           # Tabs (Candidates/Employers)
│               ├── user_card.dart                # Card người dùng
│               └── user_detail_dialog.dart       # Dialog chi tiết người dùng
```

## Các màn hình chính

### 1. Dashboard - Tổng quan hệ thống
**File:** `admin_dashboard_page.dart`

**Chức năng:**
- Hiển thị thống kê tổng quan:
  - Tổng số người dùng (Total Users): 15,402
  - Số công việc đang chờ (Pending Jobs): 42
  - Doanh thu nền tảng (Platform Revenue): $128,450
- Biểu đồ tăng trưởng (Growth Trends):
  - Hiển thị xu hướng tăng trưởng người dùng và công việc
  - Dữ liệu 7 ngày gần nhất
- Hoạt động gần đây (Recent Activities):
  - Đăng ký người dùng mới
  - Phê duyệt công việc
  - Nhà tuyển dụng mới

### 2. Job Moderation - Kiểm duyệt tin tuyển dụng
**File:** `job_moderation_page.dart`

**Chức năng:**
- Tabs để lọc công việc:
  - **Pending**: Công việc đang chờ duyệt
  - **Approved**: Công việc đã phê duyệt
  - **Rejected**: Công việc bị từ chối
- Thao tác với mỗi công việc:
  - **Approve**: Phê duyệt công việc
  - **Reject**: Từ chối với các lý do:
    - Incomplete Description
    - Incorrect Category
    - Violates TOS / Spam
    - Misleading Information
    - Inappropriate Content
- Hiển thị thông tin công việc:
  - Tiêu đề, công ty, địa điểm
  - Mức lương
  - Thời gian đăng

### 3. User Management - Quản lý người dùng
**File:** `user_management_page.dart`

**Chức năng:**
- Tìm kiếm người dùng (theo tên, email, vai trò)
- Tabs để lọc:
  - **Candidates**: Ứng viên
  - **Employers**: Nhà tuyển dụng
- Hiển thị trạng thái người dùng:
  - **ACTIVE**: Đang hoạt động (màu xanh lá)
  - **BLOCKED**: Bị chặn (màu đỏ)
  - **OFFLINE**: Ngoại tuyến (màu xám)
- Thao tác với người dùng:
  - **View**: Xem chi tiết
  - **Block/Unblock**: Chặn/Mở chặn
  - **Delete**: Xóa người dùng

### 4. Admin Profile - Hồ sơ Admin
**File:** `admin_profile_page.dart`

**Chức năng:**
- Hiển thị thông tin admin:
  - Tên: Marcus Sterling
  - Vai trò: Super Administrator
  - Email
- Các tùy chọn cài đặt:
  - Account Information
  - Security & MFA
  - Notification Settings
  - System Logs
  - Help Center
- Nút đăng xuất (Log Out)

## Cách sử dụng

### Điều hướng đến Admin Module

```dart
// Từ bất kỳ đâu trong app:
Navigator.pushNamed(context, '/admin');
```

### Thay đổi trang chủ để test (trong main.dart)

```dart
// Thay đổi dòng này:
home: const WelcomePage(),

// Thành:
home: const AdminAppShell(),
```

## Màu sắc sử dụng

Tất cả màu sắc được định nghĩa trong `AppColors`:

- **Primary**: #0A73B7 (Xanh dương chính)
- **Success**: #10B981 (Xanh lá - phê duyệt, active)
- **Error**: #EF4444 (Đỏ - từ chối, xóa)
- **Warning**: #F59E0B (Vàng - cảnh báo, pending)
- **Background**: #F5F5F5 (Nền sáng)
- **White**: #FFFFFF (Trắng)

## Mock Data

Tất cả dữ liệu hiện tại đều là mock data. Để tích hợp API thực:

1. Thay thế hàm `_loadDashboardStats()` trong `admin_dashboard_page.dart`
2. Thay thế hàm `_loadJobs()` trong `job_moderation_page.dart`
3. Thay thế hàm `_loadUsers()` trong `user_management_page.dart`

## Navigation

Admin module sử dụng Bottom Navigation Bar với 4 tab:

1. **Home** - Dashboard tổng quan
2. **Search** - Quản lý người dùng
3. **Jobs** - Kiểm duyệt công việc
4. **Profile** - Hồ sơ admin

## Tính năng nổi bật

✅ Giao diện đẹp mắt, hiện đại theo design mẫu
✅ Biểu đồ tăng trưởng tùy chỉnh với CustomPainter
✅ Tabs để lọc và tổ chức dữ liệu
✅ Dialogs cho các thao tác quan trọng
✅ Thông báo SnackBar sau mỗi hành động
✅ Tìm kiếm realtime
✅ Responsive và smooth animations
✅ Code được tổ chức tốt, dễ bảo trì

## Lưu ý

- Tất cả các file admin đã được tạo và không có lỗi compile
- Module hoàn toàn độc lập, không ảnh hưởng đến code hiện có
- Sẵn sàng tích hợp API backend
- Tuân thủ patterns và conventions của dự án
