<%@page import="model.KanjiLogDAO"%>
<%@page import="model.KanjiDAO"%>
<%@page import="model.KanjiDTO"%>
<%@page import="model.AccountDTO"%>
<%@page import="java.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>복습 테스트</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .progress {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            font-size: 18px;
            color: #666;
        }

        .score {
            font-size: 32px;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .kanji-display {
            text-align: center;
            font-size: 120px;
            font-weight: 700;
            margin: 40px 0;
            color: #333;
        }

        .options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 30px;
        }

        .option-btn {
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            padding: 20px;
            font-size: 24px;
            cursor: pointer;
            transition: all 0.3s ease;
            color: #333;
        }

        .option-btn:hover:not(:disabled) {
            border-color: #667eea;
            background: #f8f9ff;
            transform: translateY(-2px);
        }

        .option-btn:disabled {
            cursor: not-allowed;
        }

        .option-btn.correct {
            border-color: #4CAF50;
            background: #4CAF50;
            color: white;
        }

        .option-btn.wrong {
            border-color: #f44336;
            background: #f44336;
            color: white;
        }

        .option-btn.answer {
            border-color: #2196F3;
            background: #2196F3;
            color: white;
        }

        .submit-btn {
            width: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 15px;
            padding: 18px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .submit-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .question-info {
            text-align: center;
            color: #999;
            font-size: 14px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<%
    // 세션 체크
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

    // 학습한 모든 한자 가져오기 (정답 + 오답)
    KanjiLogDAO logDao = new KanjiLogDAO();
    List<Integer> studiedKanjiIDs = logDao.getStudiedKanjiIDs(accID);

    if (studiedKanjiIDs.isEmpty()) {
        out.println("<script>alert('학습한 한자가 없습니다. 먼저 테스트를 진행해주세요.'); location.href='main.jsp';</script>");
        return;
    }

    // 학습한 한자 목록 생성
    KanjiDAO kanjiDao = new KanjiDAO();
    List<KanjiDTO> studiedKanjiList = new ArrayList<>();
    for (int kanjiID : studiedKanjiIDs) {
        KanjiDTO kanji = kanjiDao.findByKanjiID(kanjiID);
        if (kanji != null) {
            studiedKanjiList.add(kanji);
        }
    }

    // 전체 한자 목록 (선택지 생성용)
    List<KanjiDTO> allKanjiList = new ArrayList<>();
    
    // level이 있으면 해당 레벨, 없으면 학습한 한자들의 레벨별로 가져오기
    if (level != null && !level.isEmpty()) {
        if (sector > 0) {
            allKanjiList = kanjiDao.findBySector(level, sector);
        } else {
            allKanjiList = kanjiDao.findByLevel(level);
        }
    } else {
        // level 파라미터가 없으면 학습한 한자들의 레벨별로 선택지 생성
        Set<String> levels = new HashSet<>();
        for (KanjiDTO k : studiedKanjiList) {
            levels.add(k.getJlptLevel());
        }
        for (String lv : levels) {
            allKanjiList.addAll(kanjiDao.findByLevel(lv));
        }
    }

    // 각 문제에 대한 선택지 생성
    Random random = new Random();
    Map<Integer, List<String>> questionOptions = new HashMap<>();
    Map<Integer, String> correctAnswers = new HashMap<>();
    Map<Integer, Integer> correctIndexes = new HashMap<>();

    for (int i = 0; i < studiedKanjiList.size(); i++) {
        KanjiDTO currentKanji = studiedKanjiList.get(i);
        List<String> options = new ArrayList<>();

        // 정답 읽기 가져오기
        String correctReading = "";
        if (currentKanji.getOnyomi1() != null && !currentKanji.getOnyomi1().isEmpty()) {
            correctReading = currentKanji.getOnyomi1();
        } else if (currentKanji.getKunyomi1() != null && !currentKanji.getKunyomi1().isEmpty()) {
            correctReading = currentKanji.getKunyomi1();
        }
        options.add(correctReading);
        correctAnswers.put(i, correctReading);

        // 오답 선택지 3개 생성
        List<String> wrongOptions = new ArrayList<>();
        for (KanjiDTO wrongKanji : allKanjiList) {
            if (wrongKanji.getKanjiID() == currentKanji.getKanjiID()) {
                continue;
            }

            String reading = "";
            if (wrongKanji.getOnyomi1() != null && !wrongKanji.getOnyomi1().isEmpty()) {
                reading = wrongKanji.getOnyomi1();
            } else if (wrongKanji.getKunyomi1() != null && !wrongKanji.getKunyomi1().isEmpty()) {
                reading = wrongKanji.getKunyomi1();
            }
            
            if (!reading.isEmpty() && !wrongOptions.contains(reading) && !reading.equals(correctReading)) {
                wrongOptions.add(reading);
            }

            if (wrongOptions.size() >= 3) {
                break;
            }
        }

        options.addAll(wrongOptions);
        Collections.shuffle(options);
        
        // 정답의 인덱스 저장
        correctIndexes.put(i, options.indexOf(correctReading));
        questionOptions.put(i, options);
    }
%>

    <div class="container">
        <form id="testForm" action="WrongKanjiTestCon.do" method="post">
            <input type="hidden" name="level" value="<%= level != null ? level : "" %>">
            <input type="hidden" name="sector" value="<%= sector %>">
            <input type="hidden" name="totalQuestions" value="<%= studiedKanjiList.size() %>">

            <% for (int i = 0; i < studiedKanjiList.size(); i++) { 
                KanjiDTO kanji = studiedKanjiList.get(i);
                List<String> options = questionOptions.get(i);
                int correctIdx = correctIndexes.get(i);
            %>
            <div class="question-container" id="question_<%= i %>" style="<%= i == 0 ? "" : "display:none;" %>" data-correct-index="<%= correctIdx %>" data-correct-answer="<%= correctAnswers.get(i) %>">
                <div class="progress">
                    <span><%= i + 1 %>/<%= studiedKanjiList.size() %></span>
                    <span class="score">복습</span>
                </div>

                <div class="kanji-display"><%= kanji.getKanji() %></div>

                <div class="options">
                    <% for (int j = 0; j < options.size(); j++) { %>
                    <button type="button" class="option-btn" data-index="<%= j %>" onclick="selectAnswer(<%= i %>, <%= j %>, '<%= options.get(j) %>')">
                        <%= options.get(j) %>
                    </button>
                    <% } %>
                </div>

                <input type="hidden" name="kanjiID_<%= i %>" value="<%= kanji.getKanjiID() %>">
                <input type="hidden" name="correctAnswer_<%= i %>" value="<%= correctAnswers.get(i) %>">
                <input type="hidden" name="answer_<%= i %>" id="answer_<%= i %>">

                <% if (i < studiedKanjiList.size() - 1) { %>
                <button type="button" class="submit-btn" id="nextBtn_<%= i %>" onclick="passQuestion(<%= i %>)">
                    모르겠어요
                </button>
                <% } else { %>
                <button type="button" class="submit-btn" id="finalBtn_<%= i %>" onclick="handleFinalQuestion(<%= i %>)">
                    모르겠어요
                </button>
                <% } %>

                <div class="question-info">
                    이 한자의 뜻은 무엇인가요?
                </div>
            </div>
            <% } %>
        </form>
    </div>

    <script>
        let currentQuestion = 0;
        const totalQuestions = <%= studiedKanjiList.size() %>;
        let answered = false;

        function selectAnswer(questionNum, selectedIndex, answer) {
            if (answered) return;
            
            const container = document.getElementById('question_' + questionNum);
            const buttons = container.querySelectorAll('.option-btn');
            const correctIndex = parseInt(container.dataset.correctIndex);
            
            answered = true;
            
            // 모든 버튼 비활성화
            buttons.forEach(btn => btn.disabled = true);
            
            // 정답 체크
            if (selectedIndex === correctIndex) {
                // 정답 - 파란색
                buttons[selectedIndex].classList.add('answer');
                document.getElementById('answer_' + questionNum).value = answer;
            } else {
                // 오답 - 선택한 것은 빨간색, 정답은 초록색
                buttons[selectedIndex].classList.add('wrong');
                buttons[correctIndex].classList.add('correct');
                document.getElementById('answer_' + questionNum).value = answer;
            }
            
            // 1.5초 후 다음 문제로
            setTimeout(() => {
                if (questionNum < totalQuestions - 1) {
                    nextQuestion(questionNum);
                } else {
                    // 마지막 문제면 제출
                    document.getElementById('testForm').submit();
                }
            }, 1500);
        }

        function passQuestion(questionNum) {
            if (answered) return;
            
            const container = document.getElementById('question_' + questionNum);
            const buttons = container.querySelectorAll('.option-btn');
            const correctIndex = parseInt(container.dataset.correctIndex);
            
            answered = true;
            
            // 모든 버튼 비활성화
            buttons.forEach(btn => btn.disabled = true);
            
            // 정답을 초록색으로 표시
            buttons[correctIndex].classList.add('correct');
            
            // 빈 답안 저장 (틀린 것으로 처리)
            document.getElementById('answer_' + questionNum).value = '';
            
            // 1.5초 후 다음 문제로
            setTimeout(() => {
                nextQuestion(questionNum);
            }, 1500);
        }

        function handleFinalQuestion(questionNum) {
            if (answered) return;
            
            const container = document.getElementById('question_' + questionNum);
            const buttons = container.querySelectorAll('.option-btn');
            const correctIndex = parseInt(container.dataset.correctIndex);
            
            answered = true;
            
            // 모든 버튼 비활성화
            buttons.forEach(btn => btn.disabled = true);
            
            // 정답을 초록색으로 표시
            buttons[correctIndex].classList.add('correct');
            
            // 빈 답안 저장 (틀린 것으로 처리)
            document.getElementById('answer_' + questionNum).value = '';
            
            // 1.5초 후 제출
            setTimeout(() => {
                document.getElementById('testForm').submit();
            }, 1500);
        }

        function nextQuestion(currentNum) {
            // 현재 문제 숨기기
            document.getElementById('question_' + currentNum).style.display = 'none';
            
            // 다음 문제로
            currentQuestion = currentNum + 1;
            
            if (currentQuestion < totalQuestions) {
                // 다음 문제 보이기
                document.getElementById('question_' + currentQuestion).style.display = 'block';
                answered = false;
            }
        }
    </script>
</body>
</html>