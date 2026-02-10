package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ReviewCon.do")
public class ReviewCon extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String level = request.getParameter("level");
        String sector = request.getParameter("sector");
        String page = request.getParameter("page");

        String url = "kanjiReview.jsp?level=" + level + "&sector=" + sector;
        if (page != null) {
            url += "&page=" + page;
        }
        response.sendRedirect(url);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
