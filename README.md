# JobGo 💼

Ứng dụng tìm việc làm được xây dựng với Flutter theo kiến trúc Clean Architecture.

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── common/                   # Utilities dùng chung (extensions, helpers)
├── core/                     # Core configurations
│   └── configs/
│       ├── theme/            # Theme & Colors
│       └── assets/           # Asset paths
├── data/                     # Data Layer
│   ├── model/                # DTOs, API response models
│   └── repository/           # Repository implementations
├── domain/                   # Domain Layer
│   ├── entity/               # Business entities
│   ├── repository/           # Repository interfaces
│   └── usecases/             # Use cases
└── presentation/             # Presentation Layer
    ├── bloc/                 # State management (BLoC)
    ├── pages/                # Screens/Pages
    └── widgets/              # Reusable widgets
```

---

## 🎨 Core - Theme & Colors

### AppColors

Sử dụng màu sắc đã định nghĩa sẵn để đảm bảo tính nhất quán trong toàn bộ ứng dụng.

```dart
import 'package:jobgo/core/configs/theme/app_colors.dart';

// Primary colors
AppColors.primary        // #0A73B7 - Màu chính
AppColors.primaryLight   // #4DA3E0 - Màu chính sáng
AppColors.primaryDark    // #065A8D - Màu chính tối

// Background colors
AppColors.lightBackground // #F5F5F5
AppColors.white           // #FFFFFF

// Text colors
AppColors.textPrimary    // #1A1A1A - Text chính
AppColors.textSecondary  // #6B7280 - Text phụ
AppColors.textHint       // #9CA3AF - Hint text

// Status colors
AppColors.success        // #10B981 - Thành công
AppColors.error          // #EF4444 - Lỗi
AppColors.warning        // #F59E0B - Cảnh báo

// Border colors
AppColors.border         // #E5E7EB
AppColors.divider        // #F3F4F6
```

**Ví dụ sử dụng:**
```dart
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

### AppTheme

Theme đã được cấu hình sẵn với Material 3.

```dart
import 'package:jobgo/core/configs/theme/app_theme.dart';

// Trong MaterialApp
MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)
```

**Các style đã được định nghĩa:**
- ✅ AppBar theme (transparent, no elevation)
- ✅ Input decoration (rounded corners, focus border)
- ✅ ElevatedButton (full width, rounded)
- ✅ OutlinedButton (rounded, grey border)

---

## 🖼️ Core - Assets

### AppIcons

Định nghĩa đường dẫn icons để dễ quản lý.

```dart
import 'package:jobgo/core/configs/assets/app_icons.dart';

AppIcons.google     // 'assets/icons/google.svg'
AppIcons.facebook   // 'assets/icons/facebook.svg'
AppIcons.briefcase  // 'assets/icons/briefcase.svg'
```

> **Lưu ý:** Cần thêm icons vào thư mục `assets/icons/` và khai báo trong `pubspec.yaml`

---

## 🧩 Presentation - Common Widgets

### CustomTextField

Text field với label, hỗ trợ validation.

```dart
import 'package:jobgo/presentation/widgets/common/custom_text_field.dart';

CustomTextField(
  label: 'Email Address',
  hintText: 'Enter your email',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  },
)
```

**Props:**
| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `label` | String | ✅ | Label hiển thị phía trên |
| `hintText` | String | ✅ | Placeholder text |
| `controller` | TextEditingController? | ❌ | Controller |
| `obscureText` | bool | ❌ | Ẩn text (password) |
| `suffixIcon` | Widget? | ❌ | Icon bên phải |
| `keyboardType` | TextInputType? | ❌ | Loại bàn phím |
| `validator` | Function? | ❌ | Validation function |

### SocialButton

Button cho đăng nhập mạng xã hội.

```dart
import 'package:jobgo/presentation/widgets/common/social_button.dart';

SocialButton(
  label: 'Google',
  icon: Icon(Icons.g_mobiledata, color: Colors.red),
  onPressed: () {
    // Handle Google sign in
  },
)
```

**Props:**
| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `label` | String | ✅ | Text hiển thị |
| `icon` | Widget | ✅ | Icon bên trái |
| `onPressed` | VoidCallback? | ❌ | Callback khi nhấn |

---

## 📱 Pages đã có

| Page | Path | Mô tả |
|------|------|-------|
| WelcomePage | `pages/welcome/welcome_page.dart` | Trang chủ với Login/SignUp options |

---

## 🚀 Bắt đầu

```bash
# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

---

## 📝 Quy tắc đặt tên

| Loại | Convention | Ví dụ |
|------|------------|-------|
| Files | snake_case | `login_page.dart` |
| Classes | PascalCase | `LoginPage` |
| Variables | camelCase | `emailController` |
| Constants | camelCase | `AppColors.primary` |
| Folders | snake_case | `auth/`, `common/` |

---

## 🤝 Contributing

1. Tạo branch mới từ `main`
2. Đặt tên branch theo format: `feat/feature-name` hoặc `fix/bug-name`
3. Commit theo format: `feat: add login page` hoặc `fix: button color`
4. Tạo Pull Request
