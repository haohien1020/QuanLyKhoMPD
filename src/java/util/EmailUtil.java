package util;

import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailUtil {

    // private static final String SMTP_HOST = getConfig("SMTP_HOST");
    // private static final String SMTP_PORT = getConfig("SMTP_PORT");
    // private static final String SMTP_USER = getConfig("SMTP_USER");
    // private static final String SMTP_PASS = getConfig("SMTP_PASS");
    // private static final String SMTP_FROM = getConfig("SMTP_FROM");

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SMTP_USER = "haohien1020@gmail.com";
    private static final String SMTP_PASS = "ylgg pkyx divs qxtg";
    private static final String SMTP_FROM = "haohien1020@gmail.com";

    private EmailUtil() {
    }

    public static boolean isConfigured() {
        return isNotBlank(SMTP_HOST)
                && isNotBlank(SMTP_PORT)
                && isNotBlank(SMTP_USER)
                && isNotBlank(SMTP_PASS);
    }

    public static void sendPasswordResetEmail(String toEmail, String resetLink) throws MessagingException {
        if (!isConfigured()) {
            throw new MessagingException("SMTP is not configured");
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(isNotBlank(SMTP_FROM) ? SMTP_FROM : SMTP_USER));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("Reset your Generator Management System password");
        message.setText("You requested a password reset.\n\n"
                + "Open this link to set a new password:\n"
                + resetLink + "\n\n"
                + "This link expires in 1 hour. If you did not request this, you can ignore this email.");

        Transport.send(message);
    }

    public static void sendContractEmailAsync(
            model.Customer customer,
            model.Generator generator,
            model.Warehouse warehouse,
            model.CustomerRentalContract contract,
            model.User seller,
            double rentalPrice) {
        new Thread(() -> {
            try {
                if (!isConfigured()) {
                    System.err.println("SMTP is not configured. Cannot send contract email.");
                    return;
                }

                // Date formats
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                String startDateStr = contract.getStartDate() != null ? sdf.format(new java.util.Date(contract.getStartDate().getTime())) : "-";
                String returnDateStr = contract.getExpectedReturnDate() != null ? sdf.format(new java.util.Date(contract.getExpectedReturnDate().getTime())) : "-";

                // Currency formats
                java.text.DecimalFormat df = new java.text.DecimalFormat("#,###");
                String depositStr = df.format(contract.getDepositAmount() != null ? contract.getDepositAmount() : java.math.BigDecimal.ZERO);
                String totalStr = df.format(contract.getTotalAmount() != null ? contract.getTotalAmount() : java.math.BigDecimal.ZERO);
                String priceStr = df.format(rentalPrice);

                // Note formatting
                String noteSection = "";
                if (contract.getNote() != null && !contract.getNote().trim().isEmpty()) {
                    noteSection = "<div class=\"note-box\"><strong>Ghi chú từ nhân viên:</strong> " + htmlEscape(contract.getNote()) + "</div>";
                }

                // Prepare HTML template
                String html = getContractEmailTemplate()
                        .replace("{CONTRACT_CODE}", contract.getContractCode())
                        .replace("{CUSTOMER_NAME}", htmlEscape(customer.getCustomerName()))
                        .replace("{SELLER_NAME}", htmlEscape(seller.getFullName()))
                        .replace("{WAREHOUSE_NAME}", htmlEscape(warehouse.getWarehouseName()))
                        .replace("{WAREHOUSE_ADDRESS}", htmlEscape(warehouse.getAddress() != null ? warehouse.getAddress() : "-"))
                        .replace("{GENERATOR_NAME}", htmlEscape(generator.getGeneratorName()))
                        .replace("{SERIAL_NUMBER}", htmlEscape(generator.getSerialNumber() != null ? generator.getSerialNumber() : "-"))
                        .replace("{POWER_VALUE}", htmlEscape(generator.getPowerValue() != null ? generator.getPowerValue() : "-"))
                        .replace("{BRAND}", htmlEscape(generator.getBrand() != null ? generator.getBrand() : "-"))
                        .replace("{FUEL_TYPE}", htmlEscape(generator.getFuelType() != null ? generator.getFuelType() : "-"))
                        .replace("{START_DATE}", startDateStr)
                        .replace("{EXPECTED_RETURN_DATE}", returnDateStr)
                        .replace("{RENTAL_PRICE}", priceStr)
                        .replace("{DEPOSIT_AMOUNT}", depositStr)
                        .replace("{TOTAL_AMOUNT}", totalStr)
                        .replace("{NOTE_SECTION}", noteSection);

                Properties props = new Properties();
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");
                props.put("mail.smtp.host", SMTP_HOST);
                props.put("mail.smtp.port", SMTP_PORT);

                Session session = Session.getInstance(props, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
                    }
                });

                MimeMessage message = new MimeMessage(session);
                message.setFrom(new InternetAddress(isNotBlank(SMTP_FROM) ? SMTP_FROM : SMTP_USER));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(customer.getEmail()));
                message.setSubject("Xác nhận Hợp đồng Thuê Máy phát điện #" + contract.getContractCode(), "UTF-8");
                message.setContent(html, "text/html; charset=UTF-8");

                Transport.send(message);
                System.out.println("Contract email sent successfully to " + customer.getEmail());
            } catch (Exception e) {
                System.err.println("Error sending contract email: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();
    }

    private static String htmlEscape(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private static String getContractEmailTemplate() {
        return "<!DOCTYPE html>\n"
                + "<html>\n"
                + "<head>\n"
                + "    <meta charset=\"utf-8\">\n"
                + "    <title>Xác nhận Hợp đồng Thuê Máy phát điện</title>\n"
                + "    <style>\n"
                + "        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; color: #333333; margin: 0; padding: 0; }\n"
                + "        .email-wrapper { max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.05); border: 1px solid #e1e8ed; }\n"
                + "        .email-header { background: linear-gradient(135deg, #1e3a5f 0%, #2563eb 100%); color: #ffffff; padding: 25px 20px; text-align: center; }\n"
                + "        .email-header h2 { margin: 0; font-size: 22px; font-weight: 600; letter-spacing: 0.5px; }\n"
                + "        .email-header p { margin: 5px 0 0 0; font-size: 14px; color: rgba(255, 255, 255, 0.85); }\n"
                + "        .email-body { padding: 30px 25px; line-height: 1.6; }\n"
                + "        .greeting { font-size: 16px; font-weight: bold; color: #1e3a5f; margin-bottom: 15px; }\n"
                + "        .intro { font-size: 14px; color: #555555; margin-bottom: 25px; }\n"
                + "        .section-title { font-size: 14px; font-weight: bold; color: #1e3a5f; border-bottom: 2px solid #e1e8ed; padding-bottom: 5px; margin-top: 25px; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.5px; }\n"
                + "        .info-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }\n"
                + "        .info-table td { padding: 10px 12px; font-size: 14px; border-bottom: 1px solid #f0f3f6; }\n"
                + "        .info-table td.label { font-weight: 600; color: #666666; width: 35%; }\n"
                + "        .info-table td.value { color: #111111; }\n"
                + "        .highlight-box { background-color: #f0f4fd; border-left: 4px solid #2563eb; padding: 15px; border-radius: 4px; margin: 20px 0; }\n"
                + "        .highlight-box p { margin: 5px 0; font-size: 14px; color: #1e3a5f; }\n"
                + "        .highlight-box .total-price { font-size: 18px; font-weight: bold; color: #2563eb; }\n"
                + "        .note-box { background-color: #fff9e6; border-left: 4px solid #ffc107; padding: 12px 15px; border-radius: 4px; font-size: 13.5px; color: #664d03; margin: 15px 0; }\n"
                + "        .footer-note { font-size: 13px; color: #777777; margin-top: 30px; border-top: 1px solid #e1e8ed; padding-top: 15px; }\n"
                + "        .email-footer { background-color: #f8fafc; padding: 20px; text-align: center; font-size: 12px; color: #888888; border-top: 1px solid #e1e8ed; }\n"
                + "    </style>\n"
                + "</head>\n"
                + "<body>\n"
                + "    <div class=\"email-wrapper\">\n"
                + "        <div class=\"email-header\">\n"
                + "            <h2>HỢP ĐỒNG THUÊ MÁY PHÁT ĐIỆN</h2>\n"
                + "            <p>Mã hợp đồng: <strong>{CONTRACT_CODE}</strong></p>\n"
                + "        </div>\n"
                + "        <div class=\"email-body\">\n"
                + "            <div class=\"greeting\">Kính gửi Ông/Bà {CUSTOMER_NAME},</div>\n"
                + "            <div class=\"intro\">\n"
                + "                Cảm ơn Quý khách đã tin tưởng sử dụng dịch vụ tại <strong>Generator Management System (GMS)</strong>.\n"
                + "                Dưới đây là thông tin chi tiết hợp đồng thuê máy phát điện vừa được lập trên hệ thống và đang <strong>chờ Quản kho xét duyệt</strong>:\n"
                + "            </div>\n"
                + "            \n"
                + "            <div class=\"section-title\">Thông tin chung</div>\n"
                + "            <table class=\"info-table\">\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Mã hợp đồng</td>\n"
                + "                    <td class=\"value\"><strong>{CONTRACT_CODE}</strong></td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Trạng thái hợp đồng</td>\n"
                + "                    <td class=\"value\">\n"
                + "                        <span style=\"background-color: #ffc107; color: #664d03; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 13px;\">Chờ Quản kho xét duyệt</span>\n"
                + "                    </td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Nhân viên thực hiện</td>\n"
                + "                    <td class=\"value\">{SELLER_NAME}</td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Kho bàn giao máy</td>\n"
                + "                    <td class=\"value\">{WAREHOUSE_NAME} ({WAREHOUSE_ADDRESS})</td>\n"
                + "                </tr>\n"
                + "            </table>\n"
                + "\n"
                + "            <div class=\"section-title\">Thông tin thiết bị thuê</div>\n"
                + "            <table class=\"info-table\">\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Tên máy phát điện</td>\n"
                + "                    <td class=\"value\"><strong>{GENERATOR_NAME}</strong></td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Số Serial / Công suất</td>\n"
                + "                    <td class=\"value\">{SERIAL_NUMBER} / {POWER_VALUE}</td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Thương hiệu / Nhiên liệu</td>\n"
                + "                    <td class=\"value\">{BRAND} / {FUEL_TYPE}</td>\n"
                + "                </tr>\n"
                + "            </table>\n"
                + "\n"
                + "            <div class=\"section-title\">Thời gian & Chi phí</div>\n"
                + "            <table class=\"info-table\">\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Ngày bắt đầu</td>\n"
                + "                    <td class=\"value\">{START_DATE}</td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Ngày dự kiến trả</td>\n"
                + "                    <td class=\"value\">{EXPECTED_RETURN_DATE}</td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Đơn giá thuê</td>\n"
                + "                    <td class=\"value\">{RENTAL_PRICE} VNĐ / ngày</td>\n"
                + "                </tr>\n"
                + "            </table>\n"
                + "\n"
                + "            <div class=\"highlight-box\">\n"
                + "                <p>Tiền đặt cọc: <strong>{DEPOSIT_AMOUNT} VNĐ</strong></p>\n"
                + "                <p>Tổng chi phí dự kiến: <span class=\"total-price\">{TOTAL_AMOUNT} VNĐ</span></p>\n"
                + "            </div>\n"
                + "\n"
                + "            {NOTE_SECTION}\n"
                + "\n"
                + "            <div class=\"footer-note\">\n"
                + "                <strong>Lưu ý quan trọng:</strong> Quý khách vui lòng kiểm tra kỹ thuật máy cùng với nhân viên giao nhận khi nhận bàn giao máy vật lý tại kho.\n"
                + "            </div>\n"
                + "        </div>\n"
                + "        <div class=\"email-footer\">\n"
                + "            <p>Đây là email tự động từ hệ thống Generator Management System (GMS).</p>\n"
                + "            <p>&copy; 2026 Generator Management System. All rights reserved.</p>\n"
                + "        </div>\n"
                + "    </div>\n"
                + "</body>\n"
                + "</html>";
    }

    public static void sendContractApprovedEmailAsync(
            model.Customer customer,
            model.Generator generator,
            model.Warehouse warehouse,
            model.CustomerRentalContract contract,
            double rentalPrice) {
        new Thread(() -> {
            try {
                if (!isConfigured()) {
                    System.err.println("SMTP is not configured. Cannot send contract approved email.");
                    return;
                }

                // Date formats
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                String startDateStr = contract.getStartDate() != null ? sdf.format(new java.util.Date(contract.getStartDate().getTime())) : "-";
                String returnDateStr = contract.getExpectedReturnDate() != null ? sdf.format(new java.util.Date(contract.getExpectedReturnDate().getTime())) : "-";

                // Currency formats
                java.text.DecimalFormat df = new java.text.DecimalFormat("#,###");
                String depositStr = df.format(contract.getDepositAmount() != null ? contract.getDepositAmount() : java.math.BigDecimal.ZERO);
                String totalStr = df.format(contract.getTotalAmount() != null ? contract.getTotalAmount() : java.math.BigDecimal.ZERO);
                String priceStr = df.format(rentalPrice);

                // Prepare HTML template
                String html = getContractApprovedEmailTemplate()
                        .replace("{CONTRACT_CODE}", contract.getContractCode())
                        .replace("{CUSTOMER_NAME}", htmlEscape(customer.getCustomerName()))
                        .replace("{GENERATOR_NAME}", htmlEscape(generator.getGeneratorName()))
                        .replace("{SERIAL_NUMBER}", htmlEscape(generator.getSerialNumber() != null ? generator.getSerialNumber() : "-"))
                        .replace("{START_DATE}", startDateStr)
                        .replace("{EXPECTED_RETURN_DATE}", returnDateStr)
                        .replace("{RENTAL_PRICE}", priceStr)
                        .replace("{DEPOSIT_AMOUNT}", depositStr)
                        .replace("{TOTAL_AMOUNT}", totalStr);

                Properties props = new Properties();
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");
                props.put("mail.smtp.host", SMTP_HOST);
                props.put("mail.smtp.port", SMTP_PORT);

                Session session = Session.getInstance(props, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
                    }
                });

                MimeMessage message = new MimeMessage(session);
                message.setFrom(new InternetAddress(isNotBlank(SMTP_FROM) ? SMTP_FROM : SMTP_USER));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(customer.getEmail()));
                message.setSubject("Xác nhận Duyệt Hợp đồng Thuê Máy phát điện #" + contract.getContractCode(), "UTF-8");
                message.setContent(html, "text/html; charset=UTF-8");

                Transport.send(message);
                System.out.println("Contract approved email sent successfully to " + customer.getEmail());
            } catch (Exception e) {
                System.err.println("Error sending contract approved email: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();
    }

    private static String getContractApprovedEmailTemplate() {
        return "<!DOCTYPE html>\n"
                + "<html>\n"
                + "<head>\n"
                + "    <meta charset=\"utf-8\">\n"
                + "    <title>Xác nhận Duyệt Hợp đồng Thuê Máy phát điện</title>\n"
                + "    <style>\n"
                + "        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; color: #333333; margin: 0; padding: 0; }\n"
                + "        .email-wrapper { max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.05); border: 1px solid #e1e8ed; }\n"
                + "        .email-header { background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%); color: #ffffff; padding: 25px 20px; text-align: center; }\n"
                + "        .email-header h2 { margin: 0; font-size: 20px; font-weight: 600; letter-spacing: 0.5px; }\n"
                + "        .email-header p { margin: 5px 0 0 0; font-size: 14px; color: rgba(255, 255, 255, 0.85); }\n"
                + "        .email-body { padding: 30px 25px; line-height: 1.6; }\n"
                + "        .greeting { font-size: 16px; font-weight: bold; color: #1e7e34; margin-bottom: 15px; }\n"
                + "        .intro { font-size: 14px; color: #555555; margin-bottom: 25px; }\n"
                + "        .section-title { font-size: 14px; font-weight: bold; color: #1e7e34; border-bottom: 2px solid #e1e8ed; padding-bottom: 5px; margin-top: 25px; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.5px; }\n"
                + "        .info-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }\n"
                + "        .info-table td { padding: 10px 12px; font-size: 14px; border-bottom: 1px solid #f0f3f6; }\n"
                + "        .info-table td.label { font-weight: 600; color: #666666; width: 35%; }\n"
                + "        .info-table td.value { color: #111111; }\n"
                + "        .highlight-box { background-color: #f4faf6; border-left: 4px solid #28a745; padding: 15px; border-radius: 4px; margin: 20px 0; }\n"
                + "        .highlight-box p { margin: 5px 0; font-size: 14px; color: #1e7e34; }\n"
                + "        .highlight-box .total-price { font-size: 18px; font-weight: bold; color: #28a745; }\n"
                + "        .footer-note { font-size: 13px; color: #777777; margin-top: 30px; border-top: 1px solid #e1e8ed; padding-top: 15px; }\n"
                + "        .email-footer { background-color: #f8fafc; padding: 20px; text-align: center; font-size: 12px; color: #888888; border-top: 1px solid #e1e8ed; }\n"
                + "    </style>\n"
                + "</head>\n"
                + "<body>\n"
                + "    <div class=\"email-wrapper\">\n"
                + "        <div class=\"email-header\">\n"
                + "            <h2>HỢP ĐỒNG ĐÃ ĐƯỢC PHÊ DUYỆT</h2>\n"
                + "            <p>Mã hợp đồng: <strong>{CONTRACT_CODE}</strong></p>\n"
                + "        </div>\n"
                + "        <div class=\"email-body\">\n"
                + "            <div class=\"greeting\">Kính gửi Ông/Bà {CUSTOMER_NAME},</div>\n"
                + "            <div class=\"intro\">\n"
                + "                Chúng tôi xin chân thành cảm ơn Quý khách đã tin tưởng sử dụng dịch vụ của chúng tôi.\n"
                + "                Hợp đồng thuê máy phát điện của Quý khách đã được <strong>Quản kho phê duyệt thành công</strong>.\n"
                + "                Nhân viên giao nhận sẽ sớm liên hệ với Quý khách để thực hiện bàn giao thiết bị thực tế.\n"
                + "            </div>\n"
                + "            \n"
                + "            <div class=\"section-title\">Chi tiết hợp đồng phê duyệt</div>\n"
                + "            <table class=\"info-table\">\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Mã hợp đồng</td>\n"
                + "                    <td class=\"value\"><strong>{CONTRACT_CODE}</strong></td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Trạng thái hợp đồng</td>\n"
                + "                    <td class=\"value\">\n"
                + "                        <span style=\"background-color: #28a745; color: #ffffff; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 13px;\">Đã phê duyệt (APPROVED)</span>\n"
                + "                    </td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Tên máy phát điện</td>\n"
                + "                    <td class=\"value\">{GENERATOR_NAME} ({SERIAL_NUMBER})</td>\n"
                + "                </tr>\n"
                + "                <tr>\n"
                + "                    <td class=\"label\">Thời gian thuê</td>\n"
                + "                    <td class=\"value\">Từ ngày {START_DATE} đến {EXPECTED_RETURN_DATE}</td>\n"
                + "                </tr>\n"
                + "            </table>\n"
                + "\n"
                + "            <div class=\"highlight-box\">\n"
                + "                <p>Tiền đặt cọc: <strong>{DEPOSIT_AMOUNT} VNĐ</strong></p>\n"
                + "                <p>Tổng chi phí dự kiến: <span class=\"total-price\">{TOTAL_AMOUNT} VNĐ</span></p>\n"
                + "            </div>\n"
                + "\n"
                + "            <div class=\"footer-note\">\n"
                + "                <strong>Lưu ý:</strong> Khi nhận máy phát điện, vui lòng ký biên bản giao nhận với nhân viên kho để chính thức nhận bàn giao máy.\n"
                + "            </div>\n"
                + "        </div>\n"
                + "        <div class=\"email-footer\">\n"
                + "            <p>Đây là email tự động từ hệ thống Generator Management System (GMS).</p>\n"
                + "            <p>&copy; 2026 Generator Management System. All rights reserved.</p>\n"
                + "        </div>\n"
                + "    </div>\n"
                + "</body>\n"
                + "</html>";
    }

    private static String getConfig(String key) {
        String value = System.getenv(key);
        if (isNotBlank(value)) {
            return value;
        }
        return System.getProperty(key);
    }

    private static boolean isNotBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
