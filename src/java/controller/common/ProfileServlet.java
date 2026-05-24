package controller.common;

import dao.UserDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        try {
            User profileUser = userDAO.findById(currentUser.getUserId());
            if (profileUser == null) {
                response.sendRedirect(request.getContextPath() + "/auth/logout");
                return;
            }

            request.getSession().setAttribute("currentUser", profileUser);
            request.setAttribute("profileUser", profileUser);
            request.getRequestDispatcher("/views/profile/profile.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("profileUser", currentUser);
            request.setAttribute("error", "Could not load profile. Please try again later.");
            request.getRequestDispatcher("/views/profile/profile.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));

        try {
            User profileUser = userDAO.findById(currentUser.getUserId());
            if (profileUser == null) {
                response.sendRedirect(request.getContextPath() + "/auth/logout");
                return;
            }

            String error = validateProfile(fullName, email, phone, currentUser.getUserId());
            if (error != null) {
                request.setAttribute("profileUser", profileUser);
                request.setAttribute("error", error);
                request.setAttribute("editMode", true);
                request.getRequestDispatcher("/views/profile/profile.jsp").forward(request, response);
                return;
            }

            boolean updated = userDAO.updateProfile(currentUser.getUserId(), fullName, email, phone);
            if (!updated) {
                request.setAttribute("profileUser", profileUser);
                request.setAttribute("error", "Could not update profile. Please try again.");
                request.setAttribute("editMode", true);
                request.getRequestDispatcher("/views/profile/profile.jsp").forward(request, response);
                return;
            }

            User updatedUser = userDAO.findById(currentUser.getUserId());
            request.getSession().setAttribute("currentUser", updatedUser);
            request.getSession().setAttribute("successMessage", "Profile updated successfully.");
            response.sendRedirect(request.getContextPath() + "/profile");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("profileUser", currentUser);
            request.setAttribute("error", "System error. Please try again later.");
            request.setAttribute("editMode", true);
            request.getRequestDispatcher("/views/profile/profile.jsp").forward(request, response);
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (User) session.getAttribute("currentUser") : null;
    }

    private String validateProfile(String fullName, String email, String phone, int userId) throws Exception {
        if (fullName == null || fullName.isEmpty()) {
            return "Full name is required.";
        }
        if (fullName.length() < 2 || fullName.length() > 100) {
            return "Full name must be between 2 and 100 characters.";
        }
        if (email == null || email.isEmpty()) {
            return "Email is required.";
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            return "Email address is invalid.";
        }
        if (userDAO.isEmailUsedByAnotherUser(email, userId)) {
            return "Email is already used by another account.";
        }
        if (phone == null || phone.isEmpty()) {
            return "Phone number is required.";
        }
        if (!phone.matches("^(\\+84|0)(\\d[\\d\\s-]{7,})$")) {
            return "Phone number is invalid.";
        }
        return null;
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
