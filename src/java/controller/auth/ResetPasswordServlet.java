package controller.auth;

import dao.PasswordResetTokenDAO;
import dao.UserDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import model.PasswordResetToken;
import model.User;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

    private final PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");

        if (token == null || token.trim().isEmpty()) {
            showInvalidToken(request, response);
            return;
        }

        try {
            PasswordResetToken resetToken = tokenDAO.findValidByToken(token.trim());
            if (resetToken == null) {
                showInvalidToken(request, response);
                return;
            }

            User user = userDAO.findById(resetToken.getUserId());
            if (user == null || !user.isActive()) {
                showInvalidToken(request, response);
                return;
            }

            request.setAttribute("token", token.trim());
            request.setAttribute("email", user.getEmail());
            request.setAttribute("canReset", true);
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System error. Please try again later.");
            request.setAttribute("canReset", false);
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (token == null || token.trim().isEmpty()) {
            showInvalidToken(request, response);
            return;
        }

        try {
            PasswordResetToken resetToken = tokenDAO.findValidByToken(token.trim());
            if (resetToken == null) {
                showInvalidToken(request, response);
                return;
            }

            User user = userDAO.findById(resetToken.getUserId());
            if (user == null || !user.isActive()) {
                showInvalidToken(request, response);
                return;
            }

            request.setAttribute("token", token.trim());
            request.setAttribute("email", user.getEmail());
            request.setAttribute("canReset", true);

            if (newPassword == null || newPassword.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please enter a new password.");
                request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Password confirmation does not match.");
                request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            if (!isValidPassword(newPassword)) {
                request.setAttribute("errorMessage",
                        "Password must be at least 6 characters and contain at least 1 uppercase letter and 1 number.");
                request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            boolean updated = userDAO.updatePassword(user.getUserId(), newPassword);
            if (!updated) {
                request.setAttribute("errorMessage", "Could not update password. Please try again.");
                request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            tokenDAO.markUsed(resetToken.getTokenId());

            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Password reset successfully. Please log in with your new password.");
            response.sendRedirect(request.getContextPath() + "/auth/login");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System error. Please try again later.");
            request.setAttribute("canReset", false);
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
        }
    }

    private void showInvalidToken(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", "Password reset link is invalid or expired.");
        request.setAttribute("canReset", false);
        request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
    }

    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 6) {
            return false;
        }
        return password.matches(".*[A-Z].*") && password.matches(".*\\d.*");
    }
}
