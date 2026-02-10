package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.AccountDTO;
import model.KanjiLogDAO;
import model.TestDAO;

@WebServlet("/TestResultCon.do")
public class TestResultCon extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 로그인 체크
        HttpSession session = request.getSession();
        AccountDTO user = (AccountDTO) session.getAttribute("loginUser");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int accID = user.getAccID();

        // 파라미터 받기
        String level = request.getParameter("level");
        String sectorParam = request.getParameter("sector");
        String scoreParam = request.getParameter("score");
        String totalParam = request.getParameter("total");
        String resultDataParam = request.getParameter("resultData");

        int sector = 1;
        int score = 0;
        int total = 10;

        try {
            if (sectorParam != null) sector = Integer.parseInt(sectorParam);
            if (scoreParam != null) score = Integer.parseInt(scoreParam);
            if (totalParam != null) total = Integer.parseInt(totalParam);
        } catch (NumberFormatException e) {
            // 기본값 사용
        }

        // 오늘 출석 여부 확인
        KanjiLogDAO logDAO = new KanjiLogDAO();
        boolean isFirstTodayStudy = !logDAO.isTodayAttended(accID);

        // 테스트 결과 저장 및 메시지 생성
        TestDAO testDAO = new TestDAO();
        boolean saveSuccess = testDAO.saveTestResult(accID, resultDataParam, level, sector);
        TestDAO.ResultInfo resultInfo = testDAO.getResultInfo(score, total);

        // request 속성 설정
        request.setAttribute("level", level);
        request.setAttribute("sector", sector);
        request.setAttribute("score", score);
        request.setAttribute("total", total);
        request.setAttribute("percentage", resultInfo.getPercentage());
        request.setAttribute("message", resultInfo.getMessage());
        request.setAttribute("icon", resultInfo.getIcon());
        request.setAttribute("isFirstTodayStudy", isFirstTodayStudy);
        request.setAttribute("saveSuccess", saveSuccess);

        // JSP로 포워드
        request.getRequestDispatcher("Test_result.jsp").forward(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
