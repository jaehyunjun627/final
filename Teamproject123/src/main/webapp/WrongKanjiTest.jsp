<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

    <div class="container">
        <form id="testForm" action="WrongKanjiTestCon.do" method="post">
            <input type="hidden" name="level" value="${level}">
            <input type="hidden" name="sector" value="${sector}">
            <input type="hidden" name="totalQuestions" value="${quizItemsSize}">

            <c:forEach var="item" items="${quizItems}" varStatus="status">
            <div class="question-container" id="question_${status.index}" style="${status.index == 0 ? '' : 'display:none;'}" data-correct-index="${item.correctIndex}" data-correct-answer="${item.correctAnswer}">
                <div class="progress">
                    <span>${status.index + 1}/${quizItemsSize}</span>
                    <span class="score">복습</span>
                </div>

                <div class="kanji-display">${item.kanji}</div>

                <div class="options">
                    <c:forEach var="opt" items="${item.options}" varStatus="optStatus">
                    <button type="button" class="option-btn" data-index="${optStatus.index}" onclick="selectAnswer(${status.index}, ${optStatus.index}, '${opt}')">
                        ${opt}
                    </button>
                    </c:forEach>
                </div>

                <input type="hidden" name="kanjiID_${status.index}" value="${item.kanjiID}">
                <input type="hidden" name="correctAnswer_${status.index}" value="${item.correctAnswer}">
                <input type="hidden" name="answer_${status.index}" id="answer_${status.index}">

                <c:choose>
                    <c:when test="${status.index < quizItemsSize - 1}">
                <button type="button" class="submit-btn" id="nextBtn_${status.index}" onclick="passQuestion(${status.index})">
                    모르겠어요
                </button>
                    </c:when>
                    <c:otherwise>
                <button type="button" class="submit-btn" id="finalBtn_${status.index}" onclick="handleFinalQuestion(${status.index})">
                    모르겠어요
                </button>
                    </c:otherwise>
                </c:choose>

                <div class="question-info">
                    이 한자의 뜻은 무엇인가요?
                </div>
            </div>
            </c:forEach>
        </form>
    </div>

    <script>
        let currentQuestion = 0;
        const totalQuestions = ${quizItemsSize};
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
