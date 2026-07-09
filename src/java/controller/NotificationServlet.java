package controller;

import dao.NotificationDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Notification;
import model.User;

@WebServlet(name = "NotificationServlet", urlPatterns = {
    "/notifications",
    "/notifications/mark-read",
    "/notifications/mark-all-read",
    "/notifications/delete",
    "/notifications/clear-all"
})
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/notifications/mark-all-read".equals(path)) {
                notificationDAO.markAllAsRead(currentUser.getUserId());
                response.sendRedirect(request.getContextPath() + "/notifications?success=marked_all_read");
                return;
            } else if ("/notifications/clear-all".equals(path)) {
                notificationDAO.deleteAllForUser(currentUser.getUserId());
                response.sendRedirect(request.getContextPath() + "/notifications?success=cleared_all");
                return;
            }

            List<Notification> notifications = notificationDAO.findNotificationsForUser(currentUser.getUserId());
            int unreadCount = notificationDAO.countUnreadNotifications(currentUser.getUserId());
            
            request.setAttribute("notifications", notifications);
            request.setAttribute("unreadCount", unreadCount);
            request.getRequestDispatcher("/views/notification/notifications-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Không thể tải danh sách thông báo: " + e.getMessage());
            request.getRequestDispatcher("/views/notification/notifications-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/notifications/mark-read".equals(path)) {
                String idStr = request.getParameter("notificationId");
                if (idStr != null) {
                    int notificationId = Integer.parseInt(idStr.trim());
                    Notification noti = notificationDAO.findById(notificationId);
                    if (noti != null && noti.getUserId() == currentUser.getUserId()) {
                        notificationDAO.markAsRead(notificationId);
                        response.setContentType("text/plain");
                        response.getWriter().write("success");
                        return;
                    }
                }
                response.getWriter().write("error");
            } else if ("/notifications/delete".equals(path)) {
                String idStr = request.getParameter("notificationId");
                if (idStr != null) {
                    int notificationId = Integer.parseInt(idStr.trim());
                    Notification noti = notificationDAO.findById(notificationId);
                    if (noti != null && noti.getUserId() == currentUser.getUserId()) {
                        notificationDAO.delete(notificationId);
                        response.sendRedirect(request.getContextPath() + "/notifications?success=deleted");
                        return;
                    }
                }
                response.sendRedirect(request.getContextPath() + "/notifications?error=delete_failed");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if ("/notifications/mark-read".equals(path)) {
                response.getWriter().write("error: " + e.getMessage());
            } else {
                response.sendRedirect(request.getContextPath() + "/notifications?error=" + e.getMessage());
            }
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (User) session.getAttribute("currentUser") : null;
    }
}
