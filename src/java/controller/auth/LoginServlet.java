package controller.auth;

import dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "LoginServlet", urlPatterns = {"/auth/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String rememberMe = req.getParameter("rememberMe");

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            keepLoginInput(req, username, rememberMe);
            req.setAttribute("error", "Please enter username and password.");
            req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userDAO.authenticate(username.trim(), password.trim());

            if (user == null) {
                keepLoginInput(req, username, rememberMe);
                req.setAttribute("error", "Username or password is incorrect.");
                req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
                return;
            }

            if (!user.isActive()) {
                keepLoginInput(req, username, rememberMe);
                req.setAttribute("error", "This account has been locked. Please contact an administrator.");
                req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
                return;
            }

            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", user);

            if (rememberMe != null) {
                session.setMaxInactiveInterval(7 * 24 * 60 * 60);
            } else {
                session.setMaxInactiveInterval(30 * 60);
            }

            redirectByRole(req, resp, user);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "System error. Please try again.");
            req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
        }
    }

    private void redirectByRole(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {

        String contextPath = req.getContextPath();

        if (user.hasRole("ADMIN")) {
            resp.sendRedirect(contextPath + "/admin/dashboard");
        } else if (user.hasRole("MANAGER")) {
            resp.sendRedirect(contextPath + "/manager/home");
        } else if (user.hasRole("WAREHOUSE_MANAGER")) {
            resp.sendRedirect(contextPath + "/warehouse/dashboard");
        } else if (user.hasRole("STAFF")) {
            resp.sendRedirect(contextPath + "/staff/home");
        } else {
            resp.sendRedirect(contextPath + "/dashboard");
        }
    }

    private void keepLoginInput(HttpServletRequest req, String username, String rememberMe) {
        req.setAttribute("inputUsername", username);
        req.setAttribute("rememberMeChecked", rememberMe != null);
    }
}
