# SETUP.md — Hướng dẫn chạy môi trường dự án

> Cho thành viên mới vào dự án. Làm theo từng bước, xong mục **Verify** là máy bạn sẵn sàng code.

> **Không muốn cài JDK/MySQL/Node?** Dựng bằng Docker: `cp .env.example .env` rồi
> `docker compose up --build` — xem [DEPLOY.md](DEPLOY.md).

---

## 1. Yêu cầu

| Phần mềm | Version | Ghi chú |
|---|---|---|
| JDK | **21** | Project target Java 17, nhưng team thống nhất dùng JDK 21. ⚠️ **Không dùng JDK 11** — TLS cũ không bắt tay được Maven Central (đã dính lỗi này) |
| MySQL | 8.x / 9.x | Port **3307** (không phải 3306 mặc định) |
| Git | bất kỳ | |
| IDE | IntelliJ / VS Code | IntelliJ khuyên dùng (Ultimate có hỗ trợ Spring; Community vẫn chạy được) |

**Kiểm tra JDK:**

```bash
java -version          # phải ra 21.x
echo $JAVA_HOME        # phải trỏ tới thư mục JDK 21
```

Nếu `JAVA_HOME` trỏ JDK 11 → đổi: *System Properties → Environment Variables → JAVA_HOME* → đường dẫn JDK 21, rồi **mở lại terminal/IDE** (biến env không tự refresh).

Maven **không cần cài** — repo đã có wrapper `mvnw`.

---

## 2. Clone & cấu hình secret

```bash
git clone https://github.com/HitroxVN/banhmyking.git banhmyking
cd banhmyking
```

Đổi teen file `application-dev.properties.example` thành `application-dev.properties`

```bash
cp src/main/resources/application-dev.properties.example \
   src/main/resources/application-dev.properties
```

Mở file vừa copy, sửa 2 dòng theo máy bạn:

```properties
spring.datasource.username=root
spring.datasource.password=<password MySQL máy bạn>
```

> File này là cấu hình riêng từng mays tránh conflict.

---

## 3. Tạo database

MySQL phải chạy ở port **3307**. Kết nối vào MySQL rồi tạo:

```sql
CREATE DATABASE banhmyking
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

> Charset bắt buộc `utf8mb4` — thiếu là mất tiếng Việt + emoji.
> Nếu MySQL của bạn chỉ chạy được port 3306: sửa `spring.datasource.url` trong `application-dev.properties` cho `3306`

> * Lưu ý: KHÔNG TỰ TẠO BẢNG BẰNG FILE. KHI CHẠY LẦN ĐẦU CÁC BẢNG SẼ TỰ ĐỘNG ĐƯỢC MIGRATE VÀO DB.

---

## 4. Chạy dự án

```bash
./mvnw clean verify       # build + test
./mvnw spring-boot:run    # chạy app
```

Lần chạy đầu Maven tải dependency (vài phút, có màn hình "Downloading...") — bình thường, các lần sau nhanh.

---

## 5. Verify — máy bạn đã sẵn sàng khi:

| Bước | Log                                        |
|---|--------------------------------------------|
| `./mvnw clean verify` | `BUILD SUCCESS`, 0 test fail               |
| `./mvnw spring-boot:run` | log có `Started BanhmykingApplication`     |
| `curl http://localhost:8080/api/v1/health` | JSON `{"success":true,"message":"OK",...}` |

Cả 3 xanh → OK.

## Chuỗi cơ sở (từ nhánh feature/multi-store)

1. **Sao lưu DB trước khi pull** (V11–V13 bỏ cột tồn kho cũ):
   `mysqldump -h 127.0.0.1 -P 3307 -u root -p banhmyking > backup_truoc_V11.sql`
2. `git pull`, chạy backend → log `now at version v13`.
3. `cd frontend && npm install && npm run dev`.
4. ADMIN → **Cơ sở**: kiểm tra "Cơ sở 1" (tạo từ dữ liệu cũ), ghim vị trí, đặt đơn tối thiểu; thêm cơ sở khác.
5. ADMIN → **Tài khoản**: gán cơ sở cho từng STAFF/SHIPPER; tạo tài khoản Quản lý cơ sở (MANAGER).
6. Thực đơn chung (món, giá) giờ ở ADMIN → **Thực đơn**; nhân viên chỉ báo hết món / nhập tồn ở **Tình trạng món**.

## Giá khuyến mãi + Combo (từ nhánh feature/combo-sale)

1. **Sao lưu DB trước khi pull**: `mysqldump -h 127.0.0.1 -P 3307 -u root -p banhmyking > backup_truoc_V14.sql`
2. `git pull`, chạy backend → log `now at version v14` (chỉ thêm cột/bảng, món cũ thành "món lẻ", chưa có KM).
3. `cd frontend && npm install && npm run dev`.
4. ADMIN → **Thực đơn** → tab **Món lẻ**: đặt *Giá khuyến mãi* (+ *Bắt đầu*/*Kết thúc* nếu cần, giờ Việt Nam).
5. ADMIN → **Thực đơn** → tab **Combo**: thêm combo từ các món lẻ; giá combo phải thấp hơn tổng giá lẻ.
6. Món đang nằm trong combo không xoá được — sửa/xoá combo trước. Combo không có tồn riêng: nhập tồn cho từng món lẻ ở **Tình trạng món**.

## Tin tức, Tuyển dụng, Phản hồi (từ nhánh feature/news-careers)

1. **Sao lưu DB trước khi pull**: `mysqldump -h 127.0.0.1 -P 3307 -u root -p banhmyking > backup_truoc_V15.sql` (root không mật khẩu thì bỏ `-p`).
2. `git pull`, chạy backend → log `now at version v15` (chỉ tạo 5 bảng mới, dữ liệu cũ giữ nguyên).
3. `cd frontend && npm install && npm run dev` (thêm `react-markdown`, `rehype-sanitize`).
4. ADMIN → **Tin tức**: soạn bài Markdown, xem trước, hẹn giờ bằng "Thời điểm đăng" (giờ Việt Nam), ghim bài nổi bật.
5. ADMIN → **Tuyển dụng**: tạo tin (chọn cơ sở hoặc "Toàn chuỗi", hạn nộp); tab **Hồ sơ** xem/tải CV. MANAGER xem hồ sơ cơ sở mình ở **Hồ sơ ứng tuyển**.
6. ADMIN → **Cấu hình trang web** → điền *Email liên hệ* để nhận email báo phản hồi mới; xử lý ở **Phản hồi** (MANAGER thấy phản hồi cơ sở mình).
7. **CV là dữ liệu cá nhân**: lưu ở thư mục `private-uploads/cv/` (cấu hình `app.private-upload-dir`), đã nằm trong `.gitignore`, KHÔNG phục vụ qua `/uploads/**`. Khi triển khai phải sao lưu thư mục này cùng DB.
8. Form công khai giới hạn 5 lần gửi/giờ/IP (hồ sơ + phản hồi chung, đếm trong bộ nhớ — khởi động lại backend là đếm lại). Chạy sau reverse proxy tin cậy thì đặt `app.trust-forwarded-for=true`.

## Thông báo realtime (từ nhánh feature/realtime-don-hang)

1. Không có migration, không thêm dependency backend — `git pull` rồi chạy backend như thường.
2. Frontend thêm `vitest`: `cd frontend && npm install`; chạy test bằng `npm run test`.
3. Luồng đẩy tin: `GET /api/v1/realtime/stream` (SSE, cần Bearer token; tối đa 5 kết nối/người).
4. Kiểm tra tay — khách mở `/orders/{mã}`, staff mở `/staff/orders` (ẩn danh): khách đặt đơn mới → staff nghe "ting", đơn hiện ngay.
5. Staff chuyển đơn sang "Đang làm" → trang theo dõi của khách nhảy trạng thái ngay.
6. Khách ở trang chủ, staff đổi trạng thái → khách thấy toast "Bếp đang làm bánh của bạn".
7. Staff phân công shipper → cửa sổ shipper kêu và hiện đơn.
8. Staff chuyển sang tab khác, đặt đơn mới → tiêu đề tab thành "(1) Đơn mới — …"; quay lại tab thì trở lại bình thường.
9. Tắt backend → ô trạng thái "Đang nối lại…"; bật lại → "Trực tiếp" và dữ liệu khớp ngay.
10. Gửi phản hồi ở trang Liên hệ → huy hiệu "Phản hồi" của admin tăng ngay.
11. Đăng xuất → Network không còn request `realtime/stream` treo; mở 6 tab cùng tài khoản → tab đầu "Đang nối lại…" (giới hạn 5).

## LỖI THÌ CHỊU. HỎI CHAT.
