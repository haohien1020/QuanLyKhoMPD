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

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SMTP_USER = "";
    private static final String SMTP_PASS = "";
    private static final String SMTP_FROM = "";

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
