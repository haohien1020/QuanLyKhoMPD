package util;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import javax.imageio.ImageIO;

public class BarcodeGenerator {

    private static final String ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%";
    
    private static final int[] ENCODINGS = {
        0x034, 0x121, 0x061, 0x160, 0x031, 0x130, 0x070, 0x025, 0x124, 0x064, // Ký tự từ 0-9
        0x109, 0x049, 0x148, 0x019, 0x118, 0x058, 0x00D, 0x10C, 0x04C, 0x01C, // Ký tự từ A-J
        0x103, 0x043, 0x142, 0x013, 0x112, 0x052, 0x007, 0x106, 0x046, 0x016, // Ký tự từ K-T
        0x181, 0x0C1, 0x1C0, 0x091, 0x190, 0x0D0, 0x085, 0x184, 0x0C4, 0x0A8, // Ký tự từ U-$
        0x0A2, 0x08A, 0x02A                                                   // Ký tự từ /-%
    };
    
    private static final int ASTERISK = 0x094;

    public static String generateCode39(String text) {
        if (text == null || text.trim().isEmpty()) {
            return "";
        }
        
        String cleanText = text.trim().toUpperCase();
        // Loại bỏ các ký tự không được hỗ trợ bởi mã Code 39
        StringBuilder sb = new StringBuilder();
        for (char c : cleanText.toCharArray()) {
            if (ALPHABET.indexOf(c) != -1) {
                sb.append(c);
            }
        }
        String toEncode = sb.toString();
        if (toEncode.isEmpty()) {
            return "";
        }

        // Mỗi ký tự: 5 vạch (bars), 4 khoảng trắng (spaces). 3 rộng (độ rộng 3), 6 hẹp (độ rộng 1).
        // Tổng độ rộng mỗi ký tự = 3 * 3 + 6 * 1 = 15 đơn vị (modules).
        // Tổng số ký tự = toEncode.length() + 2 (bao gồm ký tự bắt đầu/kết thúc dấu sao *).
        // Khoảng cách giữa các ký tự = Tổng số ký tự - 1 (mỗi khoảng cách rộng 1 đơn vị hẹp).
        int charCount = toEncode.length() + 2;
        int quietZone = 10;
        int totalModules = charCount * 15 + (charCount - 1) + 2 * quietZone;
        
        int moduleWidth = 2; // Độ rộng pixel của một đơn vị (module) hẹp
        int height = 50;     // Chiều cao barcode theo pixel
        int width = totalModules * moduleWidth;
        
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2 = image.createGraphics();
        g2.setColor(Color.WHITE);
        g2.fillRect(0, 0, width, height);
        
        int currentModule = quietZone;
        
        // Vẽ ký tự bắt đầu (*)
        drawCharacter(g2, ASTERISK, currentModule, moduleWidth, height);
        currentModule += 15;
        currentModule += 1; // khoảng cách (gap)
        
        // Vẽ các ký tự dữ liệu
        for (int i = 0; i < toEncode.length(); i++) {
            char c = toEncode.charAt(i);
            int idx = ALPHABET.indexOf(c);
            int encoding = ENCODINGS[idx];
            drawCharacter(g2, encoding, currentModule, moduleWidth, height);
            currentModule += 15;
            currentModule += 1; // khoảng cách (gap)
        }
        
        // Vẽ ký tự kết thúc (*)
        drawCharacter(g2, ASTERISK, currentModule, moduleWidth, height);
        
        g2.dispose();
        
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            ImageIO.write(image, "png", baos);
            byte[] bytes = baos.toByteArray();
            return Base64.getEncoder().encodeToString(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }
    
    private static void drawCharacter(Graphics2D g2, int encoding, int startModule, int moduleWidth, int height) {
        int current = startModule;
        for (int i = 8; i >= 0; i--) {
            int bit = (encoding >> i) & 1;
            boolean isBar = (i % 2 == 0); // Các bit ở vị trí chẵn là vạch đen, vị trí lẻ là khoảng trắng
            int width = (bit == 1) ? 3 : 1;
            
            if (isBar) {
                g2.setColor(Color.BLACK);
                g2.fillRect(current * moduleWidth, 0, width * moduleWidth, height);
            } else {
                g2.setColor(Color.WHITE);
                g2.fillRect(current * moduleWidth, 0, width * moduleWidth, height);
            }
            current += width;
        }
    }
}
