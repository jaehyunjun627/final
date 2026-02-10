package model;

import java.util.*;

/**
 * TestDAO.java - 테스트/퀴즈 비즈니스 로직
 *
 * Test_main.jsp, Test_result.jsp, WrongKanjiTest.jsp,
 * WrongKanjiTestResult.jsp, WrongKanjiStudy.jsp의
 * 스크립틀릿 로직을 추출하여 통합한 클래스
 */
public class TestDAO {

    // ========== 퀴즈 문제 데이터 ==========
    public static class QuizItem {
        private int kanjiID;
        private String kanji;
        private String correctAnswer;
        private List<String> options;
        private int correctIndex;

        public int getKanjiID() { return kanjiID; }
        public void setKanjiID(int kanjiID) { this.kanjiID = kanjiID; }
        public String getKanji() { return kanji; }
        public void setKanji(String kanji) { this.kanji = kanji; }
        public String getCorrectAnswer() { return correctAnswer; }
        public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }
        public List<String> getOptions() { return options; }
        public void setOptions(List<String> options) { this.options = options; }
        public int getCorrectIndex() { return correctIndex; }
        public void setCorrectIndex(int correctIndex) { this.correctIndex = correctIndex; }
    }

    // ========== 결과 메시지 데이터 ==========
    public static class ResultInfo {
        private String message;
        private String icon;
        private double percentage;

        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public String getIcon() { return icon; }
        public void setIcon(String icon) { this.icon = icon; }
        public double getPercentage() { return percentage; }
        public void setPercentage(double percentage) { this.percentage = percentage; }
    }

    // ========== 틀린 단어 학습 데이터 ==========
    public static class WrongKanjiStudyItem {
        private KanjiDTO kanji;
        private int correctCount;
        private int wrongCount;

        public KanjiDTO getKanji() { return kanji; }
        public void setKanji(KanjiDTO kanji) { this.kanji = kanji; }
        public int getCorrectCount() { return correctCount; }
        public void setCorrectCount(int correctCount) { this.correctCount = correctCount; }
        public int getWrongCount() { return wrongCount; }
        public void setWrongCount(int wrongCount) { this.wrongCount = wrongCount; }
    }

    // ========== 일반 테스트 퀴즈 데이터 생성 (Test_main.jsp 스크립틀릿 추출) ==========
    public List<QuizItem> buildQuizData(String level, int sector) {
        KanjiDAO kanjiDAO = new KanjiDAO();
        List<KanjiDTO> kanjiList = kanjiDAO.getKanjiByLevelSector(level, sector);

        if (kanjiList == null || kanjiList.isEmpty()) {
            return Collections.emptyList();
        }

        // 모든 읽기(음독/훈독) 수집 (오답 보기용)
        List<String> allReadings = new ArrayList<>();
        for (KanjiDTO k : kanjiList) {
            if (k.getOnyomi1() != null && !k.getOnyomi1().isEmpty()) allReadings.add(k.getOnyomi1());
            if (k.getOnyomi2() != null && !k.getOnyomi2().isEmpty()) allReadings.add(k.getOnyomi2());
            if (k.getKunyomi1() != null && !k.getKunyomi1().isEmpty()) allReadings.add(k.getKunyomi1());
        }

        List<QuizItem> quizItems = new ArrayList<>();
        Random rand = new Random();

        for (KanjiDTO kanji : kanjiList) {
            String correctAnswer = kanji.getOnyomi1();
            if (correctAnswer == null || correctAnswer.isEmpty()) {
                correctAnswer = kanji.getKunyomi1();
            }
            if (correctAnswer == null || correctAnswer.isEmpty()) {
                continue;
            }

            // 오답 보기 수집
            List<String> wrongOptions = new ArrayList<>();
            for (String reading : allReadings) {
                if (!reading.equals(correctAnswer) && !wrongOptions.contains(reading)) {
                    wrongOptions.add(reading);
                }
            }
            Collections.shuffle(wrongOptions);

            // 보기 구성: 정답 + 오답 3개
            List<String> options = new ArrayList<>();
            options.add(correctAnswer);
            for (int j = 0; j < 3 && j < wrongOptions.size(); j++) {
                options.add(wrongOptions.get(j));
            }
            Collections.shuffle(options);

            QuizItem item = new QuizItem();
            item.setKanjiID(kanji.getKanjiID());
            item.setKanji(kanji.getKanji());
            item.setCorrectAnswer(correctAnswer);
            item.setOptions(options);
            item.setCorrectIndex(options.indexOf(correctAnswer));
            quizItems.add(item);
        }

        return quizItems;
    }

    // ========== 테스트 결과 저장 (Test_result.jsp 스크립틀릿 추출) ==========
    public boolean saveTestResult(int accID, String resultDataParam, String level, int sector) {
        if (resultDataParam == null || resultDataParam.isEmpty()) {
            return false;
        }

        boolean saveSuccess = false;
        try {
            KanjiDAO kanjiDAO = new KanjiDAO();
            KanjiLogDAO logDAO = new KanjiLogDAO();

            // JSON 파싱: [{"kanji":"日","isCorrect":1}, ...]
            String data = resultDataParam.trim();
            if (data.startsWith("[")) data = data.substring(1);
            if (data.endsWith("]")) data = data.substring(0, data.length() - 1);

            if (!data.isEmpty()) {
                String[] items = data.split("\\},\\{");

                for (String item : items) {
                    item = item.replace("{", "").replace("}", "");

                    String kanjiChar = null;
                    int isCorrect = 0;

                    String[] fields = item.split(",");
                    for (String field : fields) {
                        field = field.trim();
                        if (field.startsWith("\"kanji\"")) {
                            int colonIdx = field.indexOf(":");
                            if (colonIdx > 0) {
                                kanjiChar = field.substring(colonIdx + 1).replace("\"", "").trim();
                            }
                        } else if (field.startsWith("\"isCorrect\"")) {
                            int colonIdx = field.indexOf(":");
                            if (colonIdx > 0) {
                                isCorrect = Integer.parseInt(field.substring(colonIdx + 1).trim());
                            }
                        }
                    }

                    if (kanjiChar != null && !kanjiChar.isEmpty()) {
                        int kanjiID = kanjiDAO.getKanjiID(kanjiChar, level, sector);
                        if (kanjiID > 0) {
                            logDAO.insertLog(accID, kanjiID, isCorrect);
                            saveSuccess = true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return saveSuccess;
    }

    // ========== 일반 테스트 결과 메시지 생성 (Test_result.jsp) ==========
    public ResultInfo getResultInfo(int score, int total) {
        ResultInfo info = new ResultInfo();
        double percentage = (total > 0) ? ((double) score / total * 100) : 0;
        info.setPercentage(percentage);

        if (percentage == 100) {
            info.setMessage("완벽합니다! 🌟<br>모든 문제를 맞히셨네요!");
            info.setIcon("🏆");
        } else if (percentage >= 80) {
            info.setMessage("훌륭해요!<br>조금만 더 복습하면 완벽해요!");
            info.setIcon("🎉");
        } else if (percentage >= 60) {
            info.setMessage("좋아요!<br>꾸준히 노력하고 있네요!");
            info.setIcon("😊");
        } else if (percentage >= 40) {
            info.setMessage("괜찮아요!<br>복습이 좀 더 필요해요!");
            info.setIcon("📚");
        } else {
            info.setMessage("힘내세요!<br>다시 학습하고 도전해보세요!");
            info.setIcon("💪");
        }
        return info;
    }

    // ========== 복습 테스트 결과 메시지 생성 (WrongKanjiTestResult.jsp) ==========
    public ResultInfo getWrongKanjiResultInfo(int correctCount, int totalQuestions) {
        ResultInfo info = new ResultInfo();
        double percentage = (totalQuestions > 0) ? ((double) correctCount / totalQuestions * 100) : 0;
        info.setPercentage(percentage);

        if (percentage == 100) {
            info.setIcon("🎉");
            info.setMessage("완벽합니다! 모든 문제를 맞췄어요!");
        } else if (percentage >= 80) {
            info.setIcon("😊");
            info.setMessage("훌륭해요! 거의 다 맞췄네요!");
        } else if (percentage >= 60) {
            info.setIcon("👍");
            info.setMessage("좋아요! 조금만 더 연습하면 완벽할 거예요!");
        } else if (percentage >= 40) {
            info.setIcon("💪");
            info.setMessage("괜찮아요! 계속 복습하면 실력이 늘 거예요!");
        } else {
            info.setIcon("📚");
            info.setMessage("다시 한번 복습이 필요해요. 포기하지 마세요!");
        }
        return info;
    }

    // ========== 복습 테스트 퀴즈 데이터 생성 (WrongKanjiTest.jsp 스크립틀릿 추출) ==========
    public List<QuizItem> buildWrongKanjiQuizData(int accID, String level, int sector) {
        KanjiLogDAO logDao = new KanjiLogDAO();
        KanjiDAO kanjiDao = new KanjiDAO();

        List<Integer> studiedKanjiIDs = logDao.getStudiedKanjiIDs(accID);
        if (studiedKanjiIDs.isEmpty()) {
            return null; // null = 학습한 한자 없음
        }

        // 학습한 한자 목록 생성
        List<KanjiDTO> studiedKanjiList = new ArrayList<>();
        for (int kanjiID : studiedKanjiIDs) {
            KanjiDTO kanji = kanjiDao.findByKanjiID(kanjiID);
            if (kanji != null) {
                studiedKanjiList.add(kanji);
            }
        }

        // 전체 한자 목록 (선택지 생성용)
        List<KanjiDTO> allKanjiList = new ArrayList<>();
        if (level != null && !level.isEmpty()) {
            if (sector > 0) {
                allKanjiList = kanjiDao.findBySector(level, sector);
            } else {
                allKanjiList = kanjiDao.findByLevel(level);
            }
        } else {
            Set<String> levels = new HashSet<>();
            for (KanjiDTO k : studiedKanjiList) {
                levels.add(k.getJlptLevel());
            }
            for (String lv : levels) {
                allKanjiList.addAll(kanjiDao.findByLevel(lv));
            }
        }

        // 각 문제에 대한 선택지 생성
        List<QuizItem> quizItems = new ArrayList<>();

        for (KanjiDTO currentKanji : studiedKanjiList) {
            // 정답 읽기 가져오기
            String correctReading = "";
            if (currentKanji.getOnyomi1() != null && !currentKanji.getOnyomi1().isEmpty()) {
                correctReading = currentKanji.getOnyomi1();
            } else if (currentKanji.getKunyomi1() != null && !currentKanji.getKunyomi1().isEmpty()) {
                correctReading = currentKanji.getKunyomi1();
            }

            List<String> options = new ArrayList<>();
            options.add(correctReading);

            // 오답 선택지 3개 생성
            List<String> wrongOptions = new ArrayList<>();
            for (KanjiDTO wrongKanji : allKanjiList) {
                if (wrongKanji.getKanjiID() == currentKanji.getKanjiID()) continue;

                String reading = "";
                if (wrongKanji.getOnyomi1() != null && !wrongKanji.getOnyomi1().isEmpty()) {
                    reading = wrongKanji.getOnyomi1();
                } else if (wrongKanji.getKunyomi1() != null && !wrongKanji.getKunyomi1().isEmpty()) {
                    reading = wrongKanji.getKunyomi1();
                }

                if (!reading.isEmpty() && !wrongOptions.contains(reading) && !reading.equals(correctReading)) {
                    wrongOptions.add(reading);
                }
                if (wrongOptions.size() >= 3) break;
            }

            options.addAll(wrongOptions);
            Collections.shuffle(options);

            QuizItem item = new QuizItem();
            item.setKanjiID(currentKanji.getKanjiID());
            item.setKanji(currentKanji.getKanji());
            item.setCorrectAnswer(correctReading);
            item.setOptions(options);
            item.setCorrectIndex(options.indexOf(correctReading));
            quizItems.add(item);
        }

        return quizItems;
    }

    // ========== 틀린 단어 학습 데이터 (WrongKanjiStudy.jsp 스크립틀릿 추출) ==========
    public List<WrongKanjiStudyItem> getWrongKanjiStudyItems(int accID, String level, String sectorStr) {
        KanjiLogDAO logDao = new KanjiLogDAO();
        KanjiDAO kanjiDao = new KanjiDAO();

        List<Integer> wrongKanjiIDs;
        if (sectorStr != null && !sectorStr.isEmpty()) {
            int sector = Integer.parseInt(sectorStr);
            wrongKanjiIDs = logDao.getWrongKanjiIDsByLevelSector(accID, level, sector);
        } else {
            wrongKanjiIDs = logDao.getWrongKanjiIDsByLevel(accID, level);
        }

        List<WrongKanjiStudyItem> items = new ArrayList<>();
        for (Integer kanjiID : wrongKanjiIDs) {
            KanjiDTO kanji = kanjiDao.findByKanjiID(kanjiID);
            if (kanji == null) continue;

            int[] score = logDao.getKanjiScore(accID, kanjiID);
            WrongKanjiStudyItem item = new WrongKanjiStudyItem();
            item.setKanji(kanji);
            item.setCorrectCount(score[0]);
            item.setWrongCount(score[1]);
            items.add(item);
        }
        return items;
    }

    // ========== 틀린 단어 수 (WrongKanjiStudy.jsp) ==========
    public int getWrongKanjiCount(int accID, String level, String sectorStr) {
        KanjiLogDAO logDao = new KanjiLogDAO();
        if (sectorStr != null && !sectorStr.isEmpty()) {
            int sector = Integer.parseInt(sectorStr);
            return logDao.getWrongKanjiCountByLevelSector(accID, level, sector);
        } else {
            return logDao.getWrongKanjiCountByLevel(accID, level);
        }
    }

    // ========== 퀴즈 데이터를 JSON 문자열로 변환 (JavaScript 전달용) ==========
    public String quizDataToJson(List<QuizItem> quizItems) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < quizItems.size(); i++) {
            QuizItem item = quizItems.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"question\":\"").append(escapeJson(item.getKanji())).append("\",");
            sb.append("\"options\":[");
            List<String> opts = item.getOptions();
            for (int j = 0; j < opts.size(); j++) {
                if (j > 0) sb.append(",");
                sb.append("\"").append(escapeJson(opts.get(j))).append("\"");
            }
            sb.append("],");
            sb.append("\"correctIndex\":").append(item.getCorrectIndex());
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
