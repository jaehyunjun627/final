<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>한자 테스트 - ${level} 섹터 ${sector}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans KR', -apple-system, sans-serif;
            background: linear-gradient(135deg, #C9A9E9 0%, #E6C9F5 50%, #F5D4FF 100%);
            min-height: 100vh;
            display: flex; justify-content: center; align-items: center;
            padding: 20px;
        }
        .quiz-container {
            background: rgba(255,255,255,0.95);
            border-radius: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            padding: 40px; max-width: 450px; width: 100%;
        }
        .quiz-header { text-align: center; margin-bottom: 30px; }
        .level-badge {
            display: inline-block;
            background: linear-gradient(135deg, #E6C9F5, #C9A9E9);
            color: #5a3a7a; padding: 8px 20px; border-radius: 20px;
            font-size: 14px; font-weight: 600; margin-bottom: 15px;
        }
        .progress-info {
            display: flex; justify-content: space-between; align-items: center;
            font-size: 16px; color: #333; font-weight: 600;
        }
        .timer { color: #7B68EE; font-size: 18px; }
        .question-section { margin: 30px 0; text-align: center; }
        .question-kanji { font-size: 120px; font-weight: 700; color: #333; line-height: 1; }
        .options-grid { display: grid; grid-template-columns: repeat(2,1fr); gap: 15px; margin-bottom: 20px; }
        .option-btn {
            padding: 20px; font-size: 16px; font-weight: 600;
            border: 2px solid #e0e0e0; background: white; border-radius: 15px;
            cursor: pointer; transition: all 0.3s; color: #333;
            min-height: 70px; display: flex; align-items: center; justify-content: center;
        }
        .option-btn:hover:not(:disabled) { background: #f8f9fa; border-color: #7B68EE; transform: translateY(-2px); }
        .option-btn:disabled { cursor: not-allowed; }
        .option-btn.correct { background: #6B9BD1 !important; border-color: #5A8AC0 !important; color: white !important; }
        .option-btn.wrong { background: #E88B8B !important; border-color: #D77A7A !important; color: white !important; }
        .option-btn.answer { background: #90C695 !important; border-color: #7FB584 !important; color: white !important; }
        .pass-button {
            width: 100%; padding: 18px; font-size: 16px; font-weight: 700;
            background: linear-gradient(135deg, #6B9BD1, #5A8AC0);
            color: white; border: none; border-radius: 25px; cursor: pointer;
        }
        .pass-button:disabled { opacity: 0.6; cursor: not-allowed; }
    </style>
</head>
<body>
    <div class="quiz-container">
        <div class="quiz-header">
            <div class="level-badge">${level} - 섹터 ${sector}</div>
            <div class="progress-info">
                <span><span id="currentQ">1</span>/<span id="totalQ">${quizSize}</span></span>
                <span class="timer" id="timer">5</span>
            </div>
        </div>
        <div class="question-section">
            <div class="question-kanji" id="questionKanji"></div>
        </div>
        <div class="options-grid" id="optionsContainer"></div>
        <button class="pass-button" id="passButton">모르겠어요</button>
    </div>

    <script>
        var quizData = ${quizDataJson};
        var testLevel = "${level}";
        var testSector = ${sector};

        var currentQ = 0;
        var score = 0;
        var qStartTime = 0;
        var totalTime = 5;
        var timerInterval = null;
        var isAnswered = false;
        var resultData = [];

        function init() {
            if (quizData.length === 0) { alert("퀴즈 데이터가 없습니다."); history.back(); return; }
            loadQuestion();
        }

        function startTimer() {
            qStartTime = Date.now();
            updateTimer();
            if (timerInterval) clearInterval(timerInterval);
            timerInterval = setInterval(updateTimer, 100);
        }

        function updateTimer() {
            var left = totalTime - Math.floor((Date.now() - qStartTime) / 1000);
            document.getElementById("timer").textContent = Math.max(0, left);
            if (left <= 0) { clearInterval(timerInterval); handleTimeout(); }
        }

        function loadQuestion() {
            var q = quizData[currentQ];
            document.getElementById("questionKanji").textContent = q.question;
            document.getElementById("currentQ").textContent = currentQ + 1;

            var c = document.getElementById("optionsContainer");
            c.innerHTML = "";
            for (var i = 0; i < q.options.length; i++) {
                var btn = document.createElement("button");
                btn.className = "option-btn";
                btn.textContent = q.options[i];
                btn.onclick = (function(idx) { return function() { selectOption(idx); }; })(i);
                c.appendChild(btn);
            }
            document.getElementById("passButton").disabled = false;
            isAnswered = false;
            startTimer();
        }

        function selectOption(idx) {
            if (isAnswered) return;
            checkAnswer(idx);
        }

        function checkAnswer(selIdx) {
            if (isAnswered) return;
            isAnswered = true;
            clearInterval(timerInterval);

            var q = quizData[currentQ];
            var btns = document.querySelectorAll(".option-btn");
            for (var i = 0; i < btns.length; i++) btns[i].disabled = true;
            document.getElementById("passButton").disabled = true;

            var correct = (selIdx === q.correctIndex);
            resultData.push({ kanji: q.question, isCorrect: correct ? 1 : 0 });

            if (correct) { btns[selIdx].classList.add("correct"); score++; }
            else { btns[selIdx].classList.add("wrong"); btns[q.correctIndex].classList.add("answer"); }

            setTimeout(nextQuestion, 1500);
        }

        function passQuestion() {
            if (isAnswered) return;
            isAnswered = true;
            clearInterval(timerInterval);
            var q = quizData[currentQ];
            var btns = document.querySelectorAll(".option-btn");
            for (var i = 0; i < btns.length; i++) btns[i].disabled = true;
            document.getElementById("passButton").disabled = true;
            resultData.push({ kanji: q.question, isCorrect: 0 });
            btns[q.correctIndex].classList.add("answer");
            setTimeout(nextQuestion, 1500);
        }

        function handleTimeout() {
            if (isAnswered) return;
            isAnswered = true;
            var q = quizData[currentQ];
            var btns = document.querySelectorAll(".option-btn");
            for (var i = 0; i < btns.length; i++) btns[i].disabled = true;
            document.getElementById("passButton").disabled = true;
            resultData.push({ kanji: q.question, isCorrect: 0 });
            btns[q.correctIndex].classList.add("answer");
            setTimeout(nextQuestion, 1500);
        }

        function nextQuestion() {
            currentQ++;
            if (currentQ >= quizData.length) { endQuiz(); return; }
            loadQuestion();
        }

        function endQuiz() {
            if (timerInterval) clearInterval(timerInterval);
            var form = document.createElement("form");
            form.method = "POST";
            form.action = "TestResultCon.do";
            addInput(form, "level", testLevel);
            addInput(form, "sector", testSector);
            addInput(form, "score", score);
            addInput(form, "total", quizData.length);
            addInput(form, "resultData", JSON.stringify(resultData));
            document.body.appendChild(form);
            form.submit();
        }

        function addInput(form, name, value) {
            var inp = document.createElement("input");
            inp.type = "hidden"; inp.name = name; inp.value = value;
            form.appendChild(inp);
        }

        document.getElementById("passButton").onclick = passQuestion;
        window.onload = init;
    </script>
</body>
</html>
