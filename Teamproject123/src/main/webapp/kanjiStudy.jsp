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
    
    // ========== DB에서 한자 가져오기 ==========
    KanjiDAO kanjiDAO = new KanjiDAO();
    List<KanjiDTO> kanjiList = kanjiDAO.getKanjiByLevelSector(level, sector);
    
    int totalInSector = kanjiList.size();
    
    // ========== 현재 인덱스 ==========
    int currentIndex = 0;
    String indexParam = request.getParameter("index");
    if (indexParam != null) {
        currentIndex = Integer.parseInt(indexParam);
    }
    
    // 범위 체크
    if (currentIndex >= totalInSector) currentIndex = totalInSector - 1;
    if (currentIndex < 0) currentIndex = 0;
    
    KanjiDTO currentKanji = null;
    if (totalInSector > 0) {
        currentKanji = kanjiList.get(currentIndex);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>한자 학습 - <%= level %> 섹터 <%= sector %></title>
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
        .header { color: #E6C9F5; font-size: 14px; margin-bottom: 10px; }
        .progress { text-align: right; font-size: 18px; font-weight: 600; color: #333; margin-bottom: 10px; }
        .korean-meaning { font-size: 22px; color: #555; margin-bottom: 5px; }
        .kanji-char { font-size: 120px; font-weight: 700; color: #333; cursor: pointer; margin: 10px 0; }
        .meaning-desc { font-size: 16px; color: #666; margin-bottom: 20px; }
        .reading-section { margin-bottom: 20px; font-size: 16px; }
        .reading-section p { margin: 5px 0; }
        .example-section { text-align: left; margin: 20px 0; padding: 15px; background: #f9f9f9; border-radius: 15px; }
        .example-section h3 { margin-bottom: 10px; color: #555; }
        .example-section p { margin: 8px 0; font-size: 15px; }
        .nav-buttons { display: flex; justify-content: center; gap: 20px; margin: 25px 0; }
        .nav-btn {
            width: 60px; height: 60px; border-radius: 50%;
            border: none; font-size: 24px; cursor: pointer;
            background: linear-gradient(135deg, #6B9BD1, #5A8AC0);
            color: white; display: flex; align-items: center; justify-content: center;
        }
        .nav-btn:disabled { opacity: 0.4; cursor: not-allowed; }
        .test-btn {
            width: 100%; padding: 18px; font-size: 16px; font-weight: 700;
            background: linear-gradient(135deg, #FF6B6B, #EE5A24);
            color: white; border: none; border-radius: 25px; cursor: pointer;
            margin-top: 15px;
        }
        .back-btn {
            margin-top: 15px; padding: 12px 30px; font-size: 14px;
            background: #e0e0e0; color: #555; border: none; border-radius: 20px; cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">한자 학습</div>
        
        <% if (currentKanji != null) { %>
            <div class="progress"><%= currentIndex + 1 %>/<%= totalInSector %></div>
            
            <!-- 한국어 뜻 + 한자 -->
            <div class="korean-meaning"><%= currentKanji.getKoreanMeaning() %></div>
            <div class="kanji-char" 
                 onclick="location.href='kanjiDetail.jsp?level=<%= level %>&sector=<%= sector %>&index=<%= currentIndex %>'">
                <%= currentKanji.getKanji() %>
            </div>
            
            <!-- 읽기 정보 -->
            <div class="reading-section">
                <p><strong>음독:</strong> 
                    <%= currentKanji.getOnyomi1() != null ? currentKanji.getOnyomi1() : "-" %><%= currentKanji.getOnyomi2() != null ? ", " + currentKanji.getOnyomi2() : "" %><%= currentKanji.getOnyomi3() != null ? ", " + currentKanji.getOnyomi3() : "" %>
                </p>
                <p><strong>훈독:</strong> 
                    <%= currentKanji.getKunyomi1() != null ? currentKanji.getKunyomi1() : "-" %><%= currentKanji.getKunyomi2() != null ? ", " + currentKanji.getKunyomi2() : "" %><%= currentKanji.getKunyomi3() != null ? ", " + currentKanji.getKunyomi3() : "" %>
                </p>
            </div>
            
            <!-- 의미 설명 -->
            <% if (currentKanji.getMeaningDescription() != null) { %>
                <div class="meaning-desc"><%= currentKanji.getMeaningDescription() %></div>
            <% } %>
            
            <!-- 예시 단어 -->
            <div class="example-section">
                <h3>예시 단어</h3>
                <% if (currentKanji.getExample1() != null && !currentKanji.getExample1().isEmpty()) { %>
                    <p><%= currentKanji.getExample1() %></p>
                <% } %>
                <% if (currentKanji.getExample2() != null && !currentKanji.getExample2().isEmpty()) { %>
                    <p><%= currentKanji.getExample2() %></p>
                <% } %>
                <% if (currentKanji.getExample3() != null && !currentKanji.getExample3().isEmpty()) { %>
                    <p><%= currentKanji.getExample3() %></p>
                <% } %>
            </div>
            
            <!-- 이전/다음 버튼 -->
            <div class="nav-buttons">
                <button class="nav-btn" <%= currentIndex == 0 ? "disabled" : "" %>
                    onclick="location.href='kanjiStudy.jsp?level=<%= level %>&sector=<%= sector %>&index=<%= currentIndex - 1 %>'">
                    ◀
                </button>
                <button class="nav-btn" <%= currentIndex >= totalInSector - 1 ? "disabled" : "" %>
                    onclick="location.href='kanjiStudy.jsp?level=<%= level %>&sector=<%= sector %>&index=<%= currentIndex + 1 %>'">
                    ▶
                </button>
            </div>
            
            <!-- 마지막 한자일 때 테스트 버튼 -->
            <% if (currentIndex == totalInSector - 1) { %>
                <button class="test-btn" onclick="location.href='TestMainCon.do?level=<%= level %>&sector=<%= sector %>'">
                    🎯 테스트 시작하기
                </button>
            <% } %>
            
        <% } else { %>
            <p>등록된 한자가 없습니다.</p>
        <% } %>
        
        <button class="back-btn" onclick="location.href='sectorSelect.jsp?level=<%= level %>'">섹터 선택으로</button>
    </div>
</body>
</html>