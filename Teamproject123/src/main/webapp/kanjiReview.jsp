<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.AccountDTO, model.KanjiDTO, model.KanjiDAO" %>
<%@ page import="java.util.List" %>
<%
    // ========== 로그인 체크 ==========
    AccountDTO user = (AccountDTO) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // ========== 파라미터 받기 ==========
    String level = request.getParameter("level");
    int sector = Integer.parseInt(request.getParameter("sector"));

    int currentPage = 0;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        currentPage = Integer.parseInt(pageParam);
    }

    // ========== DB에서 한자 가져오기 ==========
    KanjiDAO kanjiDAO = new KanjiDAO();
    List<KanjiDTO> kanjiList = kanjiDAO.getKanjiByLevelSector(level, sector);

    int totalKanji = kanjiList.size();
    int perPage = 4;
    int totalPages = (int) Math.ceil((double) totalKanji / perPage);

    if (currentPage < 0) currentPage = 0;
    if (currentPage >= totalPages) currentPage = totalPages - 1;

    int startIdx = currentPage * perPage;
    int endIdx = Math.min(startIdx + perPage, totalKanji);

    boolean isLastPage = (currentPage >= totalPages - 1);
    boolean isFirstPage = (currentPage == 0);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>복습 - <%= level %> 섹터 <%= sector %></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans KR', -apple-system, sans-serif;
            background: linear-gradient(135deg, #C9A9E9 0%, #E6C9F5 50%, #F5D4FF 100%);
            min-height: 100vh;
            display: flex; justify-content: center; align-items: center;
            padding: 20px;
        }
        .container {
            background: rgba(255,255,255,0.95);
            border-radius: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            padding: 40px; max-width: 520px; width: 100%;
            text-align: center;
        }
        .header {
            color: #5a3a7a;
            font-size: 14px;
            margin-bottom: 5px;
            font-weight: 600;
        }
        .sub-header {
            display: inline-block;
            background: linear-gradient(135deg, #E6C9F5, #C9A9E9);
            color: #5a3a7a;
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 20px;
        }
        .progress {
            text-align: right;
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
        }
        .kanji-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-bottom: 25px;
        }
        .kanji-card {
            background: #f9f5ff;
            border-radius: 20px;
            padding: 20px 15px;
            border: 2px solid #e8d8f5;
            transition: transform 0.2s;
        }
        .kanji-card:hover {
            transform: translateY(-3px);
            border-color: #C9A9E9;
        }
        .kanji-char {
            font-size: 60px;
            font-weight: 700;
            color: #333;
            line-height: 1.2;
            margin-bottom: 10px;
        }
        .kanji-meaning {
            font-size: 16px;
            font-weight: 600;
            color: #5a3a7a;
            margin-bottom: 8px;
        }
        .kanji-reading {
            font-size: 13px;
            color: #666;
            line-height: 1.6;
        }
        .kanji-reading span {
            display: block;
        }
        .reading-label {
            font-weight: 600;
            color: #888;
        }
        .nav-buttons {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin: 20px 0;
        }
        .nav-btn {
            width: 60px; height: 60px; border-radius: 50%;
            border: none; font-size: 24px; cursor: pointer;
            background: linear-gradient(135deg, #6B9BD1, #5A8AC0);
            color: white; display: flex; align-items: center; justify-content: center;
        }
        .nav-btn:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }
        .test-btn {
            width: 100%; padding: 18px; font-size: 16px; font-weight: 700;
            background: linear-gradient(135deg, #FF6B6B, #EE5A24);
            color: white; border: none; border-radius: 25px; cursor: pointer;
            margin-top: 10px;
            transition: transform 0.2s;
        }
        .test-btn:hover {
            transform: translateY(-2px);
        }
        .back-btn {
            margin-top: 15px; padding: 12px 30px; font-size: 14px;
            background: #e0e0e0; color: #555; border: none; border-radius: 20px; cursor: pointer;
        }
        .back-btn:hover {
            background: #d0d0d0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">복습</div>
        <div class="sub-header"><%= level %> - 섹터 <%= sector %></div>

        <div class="progress"><%= currentPage + 1 %>/<%= totalPages %></div>

        <div class="kanji-grid">
            <% for (int i = startIdx; i < endIdx; i++) {
                KanjiDTO k = kanjiList.get(i);
                String onyomi = (k.getOnyomi1() != null && !k.getOnyomi1().isEmpty()) ? k.getOnyomi1() : "-";
                String kunyomi = (k.getKunyomi1() != null && !k.getKunyomi1().isEmpty()) ? k.getKunyomi1() : "-";
            %>
            <div class="kanji-card">
                <div class="kanji-char"><%= k.getKanji() %></div>
                <div class="kanji-meaning"><%= k.getKoreanMeaning() %></div>
                <div class="kanji-reading">
                    <span><span class="reading-label">음독</span> <%= onyomi %></span>
                    <span><span class="reading-label">훈독</span> <%= kunyomi %></span>
                </div>
            </div>
            <% } %>
        </div>

        <!-- 이전/다음 버튼 -->
        <div class="nav-buttons">
            <button class="nav-btn" <%= isFirstPage ? "disabled" : "" %>
                onclick="location.href='kanjiReview.jsp?level=<%= level %>&sector=<%= sector %>&page=<%= currentPage - 1 %>'">
                ◀
            </button>
            <button class="nav-btn" <%= isLastPage ? "disabled" : "" %>
                onclick="location.href='kanjiReview.jsp?level=<%= level %>&sector=<%= sector %>&page=<%= currentPage + 1 %>'">
                ▶
            </button>
        </div>

        <!-- 마지막 페이지에서 테스트 시작 버튼 -->
        <% if (isLastPage) { %>
            <button class="test-btn" onclick="location.href='Test_main.jsp?level=<%= level %>&sector=<%= sector %>'">
                테스트 시작하기
            </button>
        <% } %>

        <button class="back-btn" onclick="location.href='kanjiStudy.jsp?level=<%= level %>&sector=<%= sector %>&index=0'">학습으로 돌아가기</button>
    </div>
</body>
</html>
