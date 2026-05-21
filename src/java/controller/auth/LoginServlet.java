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
        //Login JSP
        //→ POST /auth/login
        //→ LoginServlet
        //→ UserDAO.authenticate(username, password)
        //→ Query bảng users + roles
        //→ Nếu đúng: lưu currentUser vào session
        //→ Redirect theo role
        //→ Nếu sai: quay lại login.jsp và hiện error
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
            req.setAttribute("error", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userDAO.authenticate(username.trim(), password.trim());

            if (user == null) {
                req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
                req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
                return;
            }

         if (user == null) {
                keepLoginInput(req, username, rememberMe);

                req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
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
            req.setAttribute("error", "Có lỗi hệ thống, vui lòng thử lại.");
            req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
        }
    }

    private void redirectByRole(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {

        String contextPath = req.getContextPath();

        if (user.hasRole("ADMIN")) {
            resp.sendRedirect(contextPath + "/admin/dashboard");
        } else if (user.hasRole("MANAGER")) {
            resp.sendRedirect(contextPath + "/dashboard");
        } else if (user.hasRole("WAREHOUSE_MANAGER")) {
            resp.sendRedirect(contextPath + "/views/asset/asset-list.jsp");
        } else if (user.hasRole("STAFF")) {
            resp.sendRedirect(contextPath + "/views/asset/asset-list.jsp");
        } else {
            resp.sendRedirect(contextPath + "/dashboard");
        }
    }
    private void keepLoginInput(HttpServletRequest req, String username, String rememberMe) {
    req.setAttribute("inputUsername", username);
    req.setAttribute("rememberMeChecked", rememberMe != null);
}
}