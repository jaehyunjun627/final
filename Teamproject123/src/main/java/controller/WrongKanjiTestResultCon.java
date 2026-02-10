package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.AccountDTO;

@WebServlet("/WrongKanjiTestResultCon.do")
public class WrongKanjiTestResultCon extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 로그인 체크
        HttpSession session = request.getSession();
        AccountDTO loginUser = (AccountDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 세션에서 결과 데이터 가져오기
        String testType = (String) session.getAttribute("testType");
        if (testType == null || !testType.equals("wrong_review")) {
            response.sendRedirect("main.jsp");
            return;
        }

        // 세션 데이터를 request 속성으로 전달
        request.setAttribute("level", session.getAttribute("testLevel"));
        request.setAttribute("sectorStr", session.getAttribute("testSector"));
        request.setAttribute("totalQuestions", session.getAttribute("totalQuestions"));
        request.setAttribute("correctCount", session.getAttribute("correctCount"));
        request.setAttribute("wrongCount", session.getAttribute("wrongCount"));
        request.setAttribute("resultIcon", session.getAttribute("resultIcon"));
        request.setAttribute("resultMessage", session.getAttribute("resultMessage"));
        request.setAttribute("resultPercentage", session.getAttribute("resultPercentage"));

        // 세션 데이터 정리
        session.removeAttribute("testType");
        session.removeAttribute("testLevel");
        session.removeAttribute("testSector");
        session.removeAttribute("totalQuestions");
        session.removeAttribute("correctCount");
        session.removeAttribute("wrongCount");
        session.removeAttribute("resultIcon");
        session.removeAttribute("resultMessage");
        session.removeAttribute("resultPercentage");

        // JSP로 포워드
        request.getRequestDispatcher("WrongKanjiTestResult.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
