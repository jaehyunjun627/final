<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>틀린 단어 복습</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 10px;
        }
        .info {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        .wrong-count {
            background: #ff6b6b;
            color: white;
            padding: 10px 20px;
            border-radius: 20px;
            display: inline-block;
            margin-bottom: 20px;
        }
        .kanji-card {
            border: 2px solid #ddd;
            padding: 30px;
            margin-bottom: 20px;
            border-radius: 8px;
            background: #fafafa;
        }
        .kanji-char {
            font-size: 80px;
            text-align: center;
            color: #333;
            margin: 20px 0;
        }
        .kanji-info {
            margin: 15px 0;
        }
        .kanji-info h3 {
            color: #555;
            margin-bottom: 10px;
            font-size: 16px;
            border-bottom: 2px solid #4CAF50;
            padding-bottom: 5px;
        }
        .kanji-info p {
            color: #666;
            font-size: 15px;
            line-height: 1.6;
            margin: 5px 0;
        }
        .score-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 13px;
            margin-right: 10px;
        }
        .correct-badge {
            background: #4CAF50;
            color: white;
        }
        .wrong-badge {
            background: #ff6b6b;
            color: white;
        }
        .btn-container {
            text-align: center;
            margin-top: 30px;
        }
        .btn {
            padding: 12px 30px;
            margin: 0 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary {
            background: #4CAF50;
            color: white;
        }
        .btn-primary:hover {
            background: #45a049;
        }
        .btn-secondary {
            background: #666;
            color: white;
        }
        .btn-secondary:hover {
            background: #555;
        }
        .no-data {
            text-align: center;
            padding: 50px;
            color: #999;
            font-size: 18px;
        }
    </style>
</head>
<body>

<c:if test="${noLevel}">
<div class="container"><div class="no-data">레벨 정보가 없습니다.</div></div>
</c:if>

<c:if test="${not noLevel}">
<div class="container">
    <h1>🔄 틀린 단어 복습</h1>
    <div class="info">
        ${level}<c:if test="${not empty sectorStr}"> - 섹터 ${sectorStr}</c:if>
        <br>
        <span class="wrong-count">틀린 단어: ${totalWrong}개</span>
    </div>

    <c:choose>
        <c:when test="${empty studyItems}">
            <div class="no-data">
                😊 축하합니다!<br>
                틀린 단어가 없습니다.
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="item" items="${studyItems}">
                <div class="kanji-card">
                    <div class="kanji-char">${item.kanji.kanji}</div>

                    <div class="kanji-info">
                        <h3>📖 의미</h3>
                        <p><strong>${item.kanji.koreanMeaning}</strong></p>
                        <c:if test="${not empty item.kanji.meaningDescription}">
                            <p>${item.kanji.meaningDescription}</p>
                        </c:if>
                    </div>

                    <div class="kanji-info">
                        <h3>🔊 읽기</h3>
                        <c:if test="${not empty item.kanji.onyomi1}">
                            <p><strong>음독:</strong>
                                ${item.kanji.onyomi1}
                                <c:if test="${not empty item.kanji.onyomi2}">, ${item.kanji.onyomi2}</c:if>
                                <c:if test="${not empty item.kanji.onyomi3}">, ${item.kanji.onyomi3}</c:if>
                            </p>
                        </c:if>
                        <c:if test="${not empty item.kanji.kunyomi1}">
                            <p><strong>훈독:</strong>
                                ${item.kanji.kunyomi1}
                                <c:if test="${not empty item.kanji.kunyomi2}">, ${item.kanji.kunyomi2}</c:if>
                                <c:if test="${not empty item.kanji.kunyomi3}">, ${item.kanji.kunyomi3}</c:if>
                            </p>
                        </c:if>
                    </div>

                    <div class="kanji-info">
                        <h3>📝 예시</h3>
                        <c:if test="${not empty item.kanji.example1}">
                            <p>${item.kanji.example1}</p>
                        </c:if>
                        <c:if test="${not empty item.kanji.example2}">
                            <p>${item.kanji.example2}</p>
                        </c:if>
                        <c:if test="${not empty item.kanji.example3}">
                            <p>${item.kanji.example3}</p>
                        </c:if>
                    </div>

                    <div class="kanji-info">
                        <h3>📊 학습 기록</h3>
                        <span class="score-badge correct-badge">정답 ${item.correctCount}회</span>
                        <span class="score-badge wrong-badge">오답 ${item.wrongCount}회</span>
                    </div>
                </div>
            </c:forEach>

            <div class="btn-container">
                <a href="WrongKanjiTestCon.do?level=${level}<c:if test="${not empty sectorStr}">&sector=${sectorStr}</c:if>" class="btn btn-primary">
                    📝 복습 테스트 시작
                </a>
                <a href="main.jsp" class="btn btn-secondary">메인으로</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</c:if>

</body>
</html>
