<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>퀴즈 결과</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #C9A9E9 0%, #E6C9F5 50%, #F5D4FF 100%);
            min-height: 100vh;
            display: flex; justify-content: center; align-items: center;
            padding: 20px;
        }
        .result-container {
            background: white; border-radius: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 50px; max-width: 500px; width: 100%; text-align: center;
        }
        .result-icon { font-size: 80px; margin-bottom: 20px; }
        .result-title { font-size: 32px; color: #333; margin-bottom: 10px; font-weight: bold; }
        .level-info { font-size: 16px; color: #666; margin-bottom: 30px; }
        .score-display { font-size: 48px; color: #7B68EE; margin-bottom: 20px; font-weight: bold; }
        .score-label { font-size: 18px; color: #666; margin-bottom: 20px; }
        .attendance-badge {
            display: inline-block; padding: 10px 20px; border-radius: 25px;
            font-size: 14px; font-weight: 600; margin-bottom: 30px;
        }
        .attendance-badge.new { background: linear-gradient(135deg, #4CAF50, #45a049); color: white; }
        .attendance-badge.already { background: linear-gradient(135deg, #9e9e9e, #757575); color: white; }
        .attendance-badge.fail { background: linear-gradient(135deg, #f44336, #d32f2f); color: white; }
        .result-message { font-size: 20px; color: #333; margin-bottom: 40px; line-height: 1.6; }
        .button-group { display: flex; flex-direction: column; gap: 15px; }
        .btn {
            padding: 15px 30px; font-size: 16px; border: none; border-radius: 15px;
            cursor: pointer; font-weight: bold; text-decoration: none; display: block;
            transition: all 0.3s;
        }
        .btn-primary { background: linear-gradient(135deg, #7B68EE, #6B5CE7); color: white; }
        .btn-primary:hover { transform: translateY(-2px); }
        .btn-secondary { background: #e0e0e0; color: #555; }
        .btn-secondary:hover { background: #d0d0d0; transform: translateY(-2px); }
    </style>
</head>
<body>
    <div class="result-container">
        <div class="result-icon">${icon}</div>
        <h1 class="result-title">퀴즈 완료!</h1>
        <p class="level-info">${level} - 섹터 ${sector}</p>

        <div class="score-display">${score} / ${total}</div>
        <div class="score-label">맞힌 문제 수</div>

        <c:choose>
            <c:when test="${isFirstTodayStudy && saveSuccess}">
                <div class="attendance-badge new">✅ 오늘 출석 완료!</div>
            </c:when>
            <c:when test="${saveSuccess}">
                <div class="attendance-badge already">📌 오늘 이미 학습함</div>
            </c:when>
            <c:otherwise>
                <div class="attendance-badge fail">⚠️ 저장 실패</div>
            </c:otherwise>
        </c:choose>

        <div class="result-message">${message}</div>

        <div class="button-group">
            <a href="TestMainCon.do?level=${level}&sector=${sector}" class="btn btn-primary">🔄 다시 도전하기</a>
            <a href="kanjiStudy.jsp?level=${level}&sector=${sector}" class="btn btn-secondary">📖 다시 학습하기</a>
            <a href="main.jsp" class="btn btn-secondary">🏠 홈으로</a>
        </div>
    </div>
</body>
</html>
