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
import model.KanjiLogDAO;
import model.TestDAO;

@WebServlet("/WrongKanjiTestCon.do")
public class WrongKanjiTestCon extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // ========== GET: 복습 테스트 퀴즈 데이터 준비 ==========
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 세션 체크
        HttpSession session = request.getSession();
        AccountDTO loginUser = (AccountDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int accID = loginUser.getAccID();

        // 파라미터 받기
        String level = request.getParameter("level");
        String sectorStr = request.getParameter("sector");
        int sector = 0;
        if (sectorStr != null && !sectorStr.isEmpty()) {
            sector = Integer.parseInt(sectorStr);
        }

        // 퀴즈 데이터 생성
        TestDAO testDAO = new TestDAO();
        List<TestDAO.QuizItem> quizItems = testDAO.buildWrongKanjiQuizData(accID, level, sector);

        if (quizItems == null) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('학습한 한자가 없습니다. 먼저 테스트를 진행해주세요.'); location.href='main.jsp';</script>");
            return;
        }

        // request 속성 설정
        request.setAttribute("level", level != null ? level : "");
        request.setAttribute("sector", sector);
        request.setAttribute("quizItems", quizItems);
        request.setAttribute("quizItemsSize", quizItems.size());

        // JSP로 포워드
        request.getRequestDispatcher("WrongKanjiTest.jsp").forward(request, response);
    }

    // ========== POST: 복습 테스트 결과 처리 ==========
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 세션 체크
        HttpSession session = request.getSession();
        AccountDTO loginUser = (AccountDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int accID = loginUser.getAccID();

        // 파라미터 받기
        String level = request.getParameter("level");
        String sectorStr = request.getParameter("sector");
        String totalQuestionsStr = request.getParameter("totalQuestions");

        if (totalQuestionsStr == null) {
            response.sendRedirect("main.jsp");
            return;
        }

        int totalQuestions = Integer.parseInt(totalQuestionsStr);
        int sector = (sectorStr != null && !sectorStr.isEmpty()) ? Integer.parseInt(sectorStr) : 0;

        KanjiLogDAO logDao = new KanjiLogDAO();

        int correctCount = 0;
        int wrongCount = 0;

        // 각 문제 채점 및 로그 저장
        for (int i = 0; i < totalQuestions; i++) {
            String userAnswer = request.getParameter("answer_" + i);
            String correctAnswer = request.getParameter("correctAnswer_" + i);
            String kanjiIDStr = request.getParameter("kanjiID_" + i);

            if (userAnswer == null || correctAnswer == null || kanjiIDStr == null) {
                continue;
            }

            int kanjiID = Integer.parseInt(kanjiIDStr);
            boolean isCorrect = !userAnswer.trim().isEmpty() && userAnswer.trim().equals(correctAnswer.trim());

            if (isCorrect) {
                // 맞춘 경우: 해당 한자의 틀린 기록을 모두 삭제
                logDao.deleteWrongLogs(accID, kanjiID);
                correctCount++;
            } else {
                // 틀린 경우: 틀린 기록 추가
                String logLevel = (level != null && !level.isEmpty()) ? level : null;
                logDao.insertLog(accID, kanjiID, 0, logLevel, sector);
                wrongCount++;
            }
        }

        // 결과 메시지 계산 (TestDAO 활용)
        TestDAO testDAO = new TestDAO();
        TestDAO.ResultInfo resultInfo = testDAO.getWrongKanjiResultInfo(correctCount, totalQuestions);

        // 결과를 세션에 저장
        session.setAttribute("testType", "wrong_review");
        session.setAttribute("testLevel", level != null ? level : "전체");
        session.setAttribute("testSector", sectorStr);
        session.setAttribute("totalQuestions", totalQuestions);
        session.setAttribute("correctCount", correctCount);
        session.setAttribute("wrongCount", wrongCount);
        session.setAttribute("resultIcon", resultInfo.getIcon());
        session.setAttribute("resultMessage", resultInfo.getMessage());
        session.setAttribute("resultPercentage", resultInfo.getPercentage());

        // 결과 페이지로 리다이렉트
        response.sendRedirect("WrongKanjiTestResultCon.do");
    }
}
