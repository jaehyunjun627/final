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

@WebServlet("/WrongKanjiStudyCon.do")
public class WrongKanjiStudyCon extends HttpServlet {
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

        // 파라미터 받기
        String level = request.getParameter("level");
        String sectorStr = request.getParameter("sector");

        if (level == null) {
            request.setAttribute("noLevel", true);
            request.getRequestDispatcher("WrongKanjiStudy.jsp").forward(request, response);
            return;
        }

        int accID = loginUser.getAccID();
        TestDAO testDAO = new TestDAO();

        // 틀린 단어 학습 데이터 조회
        List<TestDAO.WrongKanjiStudyItem> studyItems = testDAO.getWrongKanjiStudyItems(accID, level, sectorStr);
        int totalWrong = testDAO.getWrongKanjiCount(accID, level, sectorStr);

        // request 속성 설정
        request.setAttribute("level", level);
        request.setAttribute("sectorStr", sectorStr);
        request.setAttribute("totalWrong", totalWrong);
        request.setAttribute("studyItems", studyItems);

        // JSP로 포워드
        request.getRequestDispatcher("WrongKanjiStudy.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
