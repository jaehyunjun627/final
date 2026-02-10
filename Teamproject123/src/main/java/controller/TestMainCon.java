package controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.AccountDTO;
import model.TestDAO;

@WebServlet("/TestMainCon.do")
public class TestMainCon extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 로그인 체크
        HttpSession session = request.getSession();
        AccountDTO user = (AccountDTO) session.getAttribute("loginUser");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 파라미터 받기
        String level = request.getParameter("level");
        String sectorParam = request.getParameter("sector");
        int sector = 1;
        if (sectorParam != null && !sectorParam.isEmpty()) {
            try {
                sector = Integer.parseInt(sectorParam);
            } catch (NumberFormatException e) {
                sector = 1;
            }
        }

        // 퀴즈 데이터 생성
        TestDAO testDAO = new TestDAO();
        List<TestDAO.QuizItem> quizItems = testDAO.buildQuizData(level, sector);

        if (quizItems.isEmpty()) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('테스트 데이터가 없습니다.'); history.back();</script>");
            return;
        }

        // JSON 변환 (JavaScript 전달용)
        String quizDataJson = testDAO.quizDataToJson(quizItems);

        // request 속성 설정
        request.setAttribute("level", level);
        request.setAttribute("sector", sector);
        request.setAttribute("quizSize", quizItems.size());
        request.setAttribute("quizDataJson", quizDataJson);

        // JSP로 포워드
        request.getRequestDispatcher("Test_main.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
