package controller.auth;

import dao.PasswordResetTokenDAO;
import dao.UserDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.UUID;
import model.PasswordResetToken;
import model.User;
import util.EmailUtil;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private static final long TOKEN_EXPIRY_MILLIS = 60 * 60 * 1000;
    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please enter your email address.");
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        email = email.trim().toLowerCase();

        if (!isValidEmail(email)) {
            request.setAttribute("errorMessage", "Email address is invalid.");
            request.setAttribute("inputEmail", email);
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            User user = userDAO.findByEmail(email);

            if (user != null && user.isActive()) {
                tokenDAO.markUserTokensUsed(user.getUserId());

                String resetToken = UUID.randomUUID().toString();
                Timestamp expiryTime = new Timestamp(System.currentTimeMillis() + TOKEN_EXPIRY_MILLIS);

                PasswordResetToken item = new PasswordResetToken();
                item.setUserId(user.getUserId());
                item.setToken(resetToken);
                item.setExpiredAt(expiryTime);
                item.setUsed(false);

                int tokenId = tokenDAO.insert(item);
                if (tokenId > 0) {
                    String resetLink = getResetLink(request, resetToken);
                    if (EmailUtil.isConfigured()) {
                        EmailUtil.sendPasswordResetEmail(user.getEmail(), resetLink);
                    } else {
                        System.out.println("Password reset link for " + user.getEmail() + ": " + resetLink);
                    }
                }
            }

            request.setAttribute("successMessage",
                    "If this email exists in our system, a password reset link has been sent.");
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System error. Please try again later.");
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
        }
    }

    private String getResetLink(HttpServletRequest request, String token) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        StringBuilder resetLink = new StringBuilder();
        resetLink.append(scheme).append("://").append(serverName);

        if (("http".equals(scheme) && serverPort != 80)
                || ("https".equals(scheme) && serverPort != 443)) {
            resetLink.append(":").append(serverPort);
        }

        resetLink.append(contextPath).append("/reset-password?token=").append(token);

        return resetLink.toString();
    }

    private boolean isValidEmail(String email) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        return email != null && email.matches(emailRegex);
    }
}
