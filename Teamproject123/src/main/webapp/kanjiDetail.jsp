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
    int index = Integer.parseInt(request.getParameter("index"));

    // ========== DB에서 한자 가져오기 ==========
    KanjiDAO kanjiDAO = new KanjiDAO();
    List<KanjiDTO> kanjiList = kanjiDAO.getKanjiByLevelSector(level, sector);

    int totalInSector = kanjiList.size();

    // 범위 체크
    if (index >= totalInSector) index = totalInSector - 1;
    if (index < 0) index = 0;

    KanjiDTO kanji = kanjiList.get(index);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>한자 상세 - <%= kanji.getKanji() %></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #C9A9E9 0%, #E6C9F5 50%, #F5D4FF 100%);
            min-height: 100vh;
            display: flex; justify-content: center; align-items: center;
            padding: 20px;
        }
        .container {
            background: rgba(255,255,255,0.95);
            border-radius: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            padding: 40px; max-width: 500px; width: 100%;
            text-align: center;
        }
        .header { color: #E6C9F5; font-size: 14px; margin-bottom: 15px; }
        .korean-title { font-size: 24px; color: #555; margin-bottom: 5px; }
        .kanji-char {
            font-size: 120px; font-weight: 700; color: #333;
            background: #f0e8f8; border-radius: 20px;
            display: inline-block; padding: 10px 30px; margin: 10px 0;
        }
        .info-section { text-align: left; margin: 25px 0; font-size: 16px; line-height: 2; }
        .info-section strong { color: #7B68EE; }
        .example-section {
            text-align: left; margin: 20px 0; padding: 20px;
            background: #f9f9f9; border-radius: 15px;
        }
        .example-section h3 { margin-bottom: 10px; color: #555; }
        .example-section p { margin: 10px 0; font-size: 15px; }
        .nav-buttons { display: flex; justify-content: center; gap: 20px; margin: 25px 0; }
        .nav-btn {
            width: 60px; height: 60px; border-radius: 50%;
            border: none; font-size: 24px; cursor: pointer;
            background: linear-gradient(135deg, #6B9BD1, #5A8AC0);
            color: white; display: flex; align-items: center; justify-content: center;
        }
        .nav-btn:disabled { opacity: 0.4; cursor: not-allowed; }
        .back-btn {
            margin-top: 10px; padding: 12px 30px; font-size: 14px;
            background: #e0e0e0; color: #555; border: none; border-radius: 20px; cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">한자 설명보기</div>

        <!-- 한국어 뜻 + 한자 -->
        <div class="korean-title"><%= kanji.getKoreanMeaning() %></div>
        <div class="kanji-char"><%= kanji.getKanji() %></div>

        <!-- 상세 정보 -->
        <div class="info-section">
            <p><strong>음독:</strong>
                <%= kanji.getOnyomi1() != null ? kanji.getOnyomi1() : "-" %><%= kanji.getOnyomi2() != null ? "　" + kanji.getOnyomi2() : "" %><%= kanji.getOnyomi3() != null ? "　" + kanji.getOnyomi3() : "" %>
            </p>
            <p><strong>훈독:</strong>
                <%= kanji.getKunyomi1() != null ? kanji.getKunyomi1() : "-" %><%= kanji.getKunyomi2() != null ? "　" + kanji.getKunyomi2() : "" %><%= kanji.getKunyomi3() != null ? "　" + kanji.getKunyomi3() : "" %>
            </p>
            <p><strong>의미:</strong> <%= kanji.getMeaningDescription() != null ? kanji.getMeaningDescription() : "-" %></p>
        </div>

        <!-- 예시 단어 -->
        <div class="example-section">
            <h3>예시 단어</h3>
            <% if (kanji.getExample1() != null && !kanji.getExample1().isEmpty()) { %>
                <p><%= kanji.getExample1() %></p>
            <% } %>
            <% if (kanji.getExample2() != null && !kanji.getExample2().isEmpty()) { %>
                <p><%= kanji.getExample2() %></p>
            <% } %>
            <% if (kanji.getExample3() != null && !kanji.getExample3().isEmpty()) { %>
                <p><%= kanji.getExample3() %></p>
            <% } %>
        </div>

        <!-- 이전/다음 버튼 -->
        <div class="nav-buttons">
            <button class="nav-btn" <%= index == 0 ? "disabled" : "" %>
                onclick="location.href='kanjiDetail.jsp?level=<%= level %>&sector=<%= sector %>&index=<%= index - 1 %>'">
                ◀
            </button>
            <button class="nav-btn" <%= index >= totalInSector - 1 ? "disabled" : "" %>
                onclick="location.href='kanjiDetail.jsp?level=<%= level %>&sector=<%= sector %>&index=<%= index + 1 %>'">
                ▶
            </button>
        </div>

        <button class="back-btn" onclick="location.href='kanjiStudy.jsp?level=<%= level %>&sector=<%= sector %>&index=<%= index %>'">
            학습으로 돌아가기
        </button>
    </div>
</body>
</html>