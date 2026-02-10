<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>복습 테스트 결과</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            max-width: 600px;
            width: 100%;
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            text-align: center;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 32px;
        }
        .result-icon {
            font-size: 80px;
            margin: 20px 0;
        }
        .score-display {
            font-size: 48px;
            font-weight: bold;
            color: #4CAF50;
            margin: 20px 0;
        }
        .score-details {
            display: flex;
            justify-content: space-around;
            margin: 30px 0;
        }
        .score-box {
            flex: 1;
            padding: 20px;
            margin: 0 10px;
            border-radius: 10px;
        }
        .correct-box {
            background: #e8f5e9;
            border: 2px solid #4CAF50;
        }
        .wrong-box {
            background: #ffebee;
            border: 2px solid #f44336;
        }
        .score-box h3 {
            margin: 0 0 10px 0;
            font-size: 16px;
            color: #666;
        }
        .score-box .number {
            font-size: 36px;
            font-weight: bold;
        }
        .correct-box .number {
            color: #4CAF50;
        }
        .wrong-box .number {
            color: #f44336;
        }
        .percentage {
            font-size: 24px;
            color: #666;
            margin: 10px 0;
        }
        .message {
            font-size: 18px;
            color: #555;
            margin: 20px 0;
            line-height: 1.6;
        }
        .btn-container {
            margin-top: 40px;
        }
        .btn {
            display: inline-block;
            padding: 15px 30px;
            margin: 0 10px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            transition: all 0.3s;
        }
        .btn-primary {
            background: #4CAF50;
            color: white;
        }
        .btn-primary:hover {
            background: #45a049;
            transform: translateY(-2px);
        }
        .btn-secondary {
            background: #667eea;
            color: white;
        }
        .btn-secondary:hover {
            background: #5568d3;
            transform: translateY(-2px);
        }
        .btn-danger {
            background: #f44336;
            color: white;
        }
        .btn-danger:hover {
            background: #da190b;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

<div class="container">
    <h1>🔄 복습 테스트 결과</h1>

    <div class="result-icon">${resultIcon}</div>

    <div class="score-display">
        <fmt:formatNumber value="${resultPercentage}" maxFractionDigits="0"/>점
    </div>

    <div class="percentage">
        ( ${correctCount} / ${totalQuestions} 문제 정답 )
    </div>

    <div class="score-details">
        <div class="score-box correct-box">
            <h3>정답</h3>
            <div class="number">${correctCount}</div>
        </div>
        <div class="score-box wrong-box">
            <h3>오답</h3>
            <div class="number">${wrongCount}</div>
        </div>
    </div>

    <div class="message">
        ${resultMessage}
    </div>

    <div class="btn-container">
        <c:if test="${wrongCount > 0}">
            <a href="WrongKanjiStudyCon.do?level=${level}<c:if test="${not empty sectorStr}">&sector=${sectorStr}</c:if>"
               class="btn btn-danger">
                🔄 다시 복습하기
            </a>
        </c:if>
        <a href="WrongKanjiTestCon.do?level=${level}<c:if test="${not empty sectorStr}">&sector=${sectorStr}</c:if>"
           class="btn btn-primary">
            📝 다시 테스트
        </a>
        <a href="main.jsp" class="btn btn-secondary">
            🏠 메인으로
        </a>
    </div>
</div>

</body>
</html>
