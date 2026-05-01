# Hướng dẫn sử dụng LazyListController và LazyListView

## Tổng quan
`LazyListController` và `LazyListView` là một cặp widget custom được sử dụng để tạo danh sách có thể tải thêm dữ liệu khi scroll (infinite scroll/pagination).

## 1. Thiết lập LazyListController trong Cubit

### Khai báo
```dart
/// Trong Cubit class
late final LazyListController<Model> requestPopularNowBookList;
```

### Khởi tạo trong init()
```dart
init() {
    requestPopularNowBookList = LazyListController(
      limit: limit,                    // Số lượng item mỗi lần tải
      onLoad: (page) async {           // Hàm được gọi khi cần tải dữ liệu
        return callAPIList(
          // Các tham số API của bạn
          page: page,
          limit: limit,
        );
      },
    );
}
```

## 2. Sử dụng LazyListView trong UI

```dart
Expanded(
  child: LazyListView(
    controller: cubit.requestPopularNowBookList,  // Controller đã khởi tạo
    hasRefresh: true,                             // Bật/tắt pull-to-refresh
    shrinkWrap: false,                           // Có nên shrink wrap không
    callInit: false,                             // Có tự động gọi load đầu tiên không
    emptyView: const NoDataWidget(),             // Widget hiển thị khi không có dữ liệu
    skeletonView: () => const RankBookView(),    // Widget skeleton khi loading
    itemBuilder: (index, item) {                 // Hàm build từng item
      final isLast = index == cubit.requestPopularNowBookList.length - 1;
      
      return Padding(
        padding: padding(bottom: isLast ? 0 : 20),
        child: RankBookView(
          index: index,
          type: TypeRankBookView.popular_screen,
          book: item,
        ),
      );
    },
  ),
),
```

## 3. Các thuộc tính quan trọng

### LazyListController
- `limit`: Số lượng item tải mỗi lần
- `onLoad`: Callback function nhận tham số `page` và trả về Future<List<T>>

### LazyListView
- `controller`: LazyListController để quản lý dữ liệu
- `hasRefresh`: Bật pull-to-refresh (true/false)
- `shrinkWrap`: Có nên wrap theo nội dung (true/false)
- `callInit`: Có tự động gọi load trang đầu (true/false)
- `emptyView`: Widget hiển thị khi danh sách rỗng
- `skeletonView`: Widget hiển thị khi đang loading
- `itemBuilder`: Hàm build UI cho từng item

## 4. Cách hoạt động

1. **Khởi tạo**: Controller được tạo với `limit` và `onLoad` callback
2. **Load dữ liệu**: Khi cần dữ liệu, `onLoad` được gọi với số trang
3. **Hiển thị**: `itemBuilder` được gọi cho từng item trong danh sách
4. **Pagination**: Khi scroll đến cuối, tự động load trang tiếp theo
5. **Refresh**: Khi pull-to-refresh, reset về trang 1 và load lại

## 5. Ví dụ callAPIList function

```dart
Future<List<BookModel>> callAPIList({int? page, int? limit}) async {
  try {
    final response = await apiService.getPopularBooks(
      page: page ?? 1,
      limit: limit ?? 10,
    );
    
    return response.data; // Trả về List<BookModel>
  } catch (e) {
    // Handle error
    return [];
  }
}
```

## 6. Lưu ý quan trọng

- **Generic Type**: Sử dụng `<Model>` để định nghĩa kiểu dữ liệu
- **Memory Management**: Controller sẽ tự động dispose khi widget bị hủy
- **Error Handling**: Xử lý lỗi trong `callAPIList` function
- **Loading State**: `skeletonView` chỉ hiện khi loading lần đầu
- **Empty State**: `emptyView` hiện khi danh sách trống sau khi load xong

## 7. Các tình huống sử dụng

- ✅ Danh sách sách phổ biến
- ✅ Timeline social media  
- ✅ Danh sách sản phẩm
- ✅ Comment section
- ✅ Search results với pagination

## 8. Troubleshooting

**Lỗi thường gặp:**
- Controller chưa được khởi tạo → Kiểm tra `init()` được gọi
- API không trả về đúng format → Kiểm tra response structure
- Scroll không load thêm → Kiểm tra `onLoad` callback
- Refresh không hoạt động → Đảm bảo `hasRefresh: true`