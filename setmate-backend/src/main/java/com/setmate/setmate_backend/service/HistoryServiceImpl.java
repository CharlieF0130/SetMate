package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.DTO.CalendarSummaryDTO;
import com.setmate.setmate_backend.DTO.DailyTrainingDetailDTO;
import com.setmate.setmate_backend.DTO.ExerciseSummaryDTO;
import com.setmate.setmate_backend.model.TrainingExercise;
import com.setmate.setmate_backend.model.TrainingSession;
import com.setmate.setmate_backend.repository.TrainingExerciseRepository;
import com.setmate.setmate_backend.repository.TrainingSessionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;

@Service
public class HistoryServiceImpl implements HistoryService {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private TrainingSessionRepository sessionRepo;

    @Autowired
    private TrainingExerciseRepository exerciseRepo;


    /**
     * Retrieves training summary for calendar view.
     * <p>
     * Uses PreparedStatement to securely query training_sessions table.
     * Parameters are bound (userId, month, year) to prevent SQL injection.
     */
    @Override
    public List<CalendarSummaryDTO> getCalendarSummary(int userId, YearMonth month) {
        List<CalendarSummaryDTO> result = new ArrayList<>();

        String sql = "SELECT date, training_title FROM training_sessions " +
                "WHERE user_id = ? AND MONTH(date) = ? AND YEAR(date) = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, month.getMonthValue());
            ps.setInt(3, month.getYear());

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                LocalDate date = rs.getDate("date").toLocalDate();
                String title = rs.getString("training_title");
                result.add(new CalendarSummaryDTO(date, title));
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch calendar summary", e);
        }

        return result;
    }

    /**
     * Retrieves detailed training session and its exercises for a specific date.
     * <p>
     * Uses PreparedStatement twice: once for fetching session, once for exercises.
     * Parameter binding ensures security and prevents SQL injection.
     * Does NOT use JPA/ORM — directly queries DB using raw JDBC.
     */
    @Override
    public DailyTrainingDetailDTO getTrainingDetails(int userId, String dateStr) {
        LocalDate date = LocalDate.parse(dateStr);
        DailyTrainingDetailDTO dto = null;

        String sessionSql = "SELECT * FROM training_sessions WHERE user_id = ? AND date = ?";
        String exerciseSql = "SELECT * FROM training_exercises WHERE training_id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement sessionStmt = conn.prepareStatement(sessionSql)) {

            sessionStmt.setInt(1, userId);
            sessionStmt.setDate(2, Date.valueOf(date));

            ResultSet sessionRs = sessionStmt.executeQuery();
            if (sessionRs.next()) {
                int trainingId = sessionRs.getInt("training_id");
                String title = sessionRs.getString("training_title");
                String note = sessionRs.getString("note");
                Time startTime = sessionRs.getTime("start_time");
                Time endTime = sessionRs.getTime("end_time");

                // 查询 exercises
                List<TrainingExercise> exercises = new ArrayList<>();
                try (PreparedStatement exerciseStmt = conn.prepareStatement(exerciseSql)) {
                    exerciseStmt.setInt(1, trainingId);
                    ResultSet exerciseRs = exerciseStmt.executeQuery();
                    while (exerciseRs.next()) {
                        TrainingExercise exercise = new TrainingExercise();
                        exercise.setExerciseId(exerciseRs.getInt("exercise_id"));
                        exercise.setTrainingId(trainingId);
                        exercise.setExerciseName(exerciseRs.getString("exercise_name"));
                        exercise.setReps(exerciseRs.getInt("reps"));
                        exercise.setSets(exerciseRs.getInt("sets"));
                        exercise.setWeight(exerciseRs.getDouble("weight"));
                        exercise.setRestTime(exerciseRs.getInt("rest_time"));
                        exercise.setType(exerciseRs.getString("type"));

                        exercises.add(exercise);
                    }
                }

                dto = new DailyTrainingDetailDTO(trainingId, title, note, startTime.toLocalTime(), endTime.toLocalTime(), exercises);

            } else {
                throw new RuntimeException("No training found for this date");
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch training details", e);
        }

        return dto;
    }

    /**
     * Retrieves all training sessions and exercises for a user on a given date.
     * <p>
     * Uses PreparedStatement to fetch all sessions, and nested PreparedStatement to fetch exercises.
     * Bound parameters used to avoid SQL injection.
     * Does not rely on Spring Data JPA or ORM — pure JDBC access.
     */
    @Override
    public List<DailyTrainingDetailDTO> getAllTrainingDetails(int userId, String dateStr) {
        LocalDate date = LocalDate.parse(dateStr);
        List<DailyTrainingDetailDTO> result = new ArrayList<>();

        String sessionSql = "SELECT * FROM training_sessions WHERE user_id = ? AND date = ?";
        String exerciseSql = "SELECT * FROM training_exercises WHERE training_id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement sessionStmt = conn.prepareStatement(sessionSql)) {

            sessionStmt.setInt(1, userId);
            sessionStmt.setDate(2, Date.valueOf(date));

            ResultSet sessionRs = sessionStmt.executeQuery();
            while (sessionRs.next()) {
                int trainingId = sessionRs.getInt("training_id");
                String title = sessionRs.getString("training_title");
                String note = sessionRs.getString("note");
                Time startTime = sessionRs.getTime("start_time");
                Time endTime = sessionRs.getTime("end_time");

                // 查询 exercises
                List<TrainingExercise> exercises = new ArrayList<>();
                try (PreparedStatement exerciseStmt = conn.prepareStatement(exerciseSql)) {
                    exerciseStmt.setInt(1, trainingId);
                    ResultSet exerciseRs = exerciseStmt.executeQuery();
                    while (exerciseRs.next()) {
                        TrainingExercise exercise = new TrainingExercise();
                        exercise.setExerciseId(exerciseRs.getInt("exercise_id"));
                        exercise.setTrainingId(trainingId);
                        exercise.setExerciseName(exerciseRs.getString("exercise_name"));
                        exercise.setReps(exerciseRs.getInt("reps"));
                        exercise.setSets(exerciseRs.getInt("sets"));
                        exercise.setWeight(exerciseRs.getDouble("weight"));
                        exercise.setRestTime(exerciseRs.getInt("rest_time"));
                        exercise.setType(exerciseRs.getString("type"));
                        exercises.add(exercise);
                    }
                }

                DailyTrainingDetailDTO dto = new DailyTrainingDetailDTO(
                        trainingId,
                        title,
                        note,
                        startTime.toLocalTime(),
                        endTime.toLocalTime(),
                        exercises
                );


                result.add(dto);
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch training details", e);
        }

        return result;
    }

    /**
     * Retrieves summarized exercise duration for a user over a specified range (week, month, year).
     * <p>
     * Uses PreparedStatement to fetch training session date and time range.
     * Calculates duration in minutes and maps them to day/week/month buckets.
     * Bound parameters are used to prevent SQL injection.
     * Does not use Spring Data JPA — relies on raw JDBC access.
     */
    @Override
    public ExerciseSummaryDTO getSummary(int userId, String range, String startDateStr) {
        LocalDate startDate = LocalDate.parse(startDateStr);
        List<Double> result = new ArrayList<>();
        String unit = "";  // ✅ 提前定义 unit

        try (Connection conn = dataSource.getConnection()) {
            String sql = "SELECT date, start_time, end_time FROM training_sessions WHERE user_id = ? AND date >= ? AND date <= ?";

            LocalDate endDate;
            switch (range.toLowerCase()) {
                case "week":
                    endDate = startDate.plusDays(6);
                    unit = "day";
                    for (int i = 0; i < 7; i++) result.add(0.0);
                    break;
                case "month":
                    endDate = startDate.plusMonths(1).minusDays(1);
                    unit = "week";
                    for (int i = 0; i < 5; i++) result.add(0.0);
                    break;
                case "year":
                    endDate = startDate.plusYears(1).minusDays(1);
                    unit = "month";
                    for (int i = 0; i < 12; i++) result.add(0.0);
                    break;
                default:
                    throw new IllegalArgumentException("Unsupported range: " + range);
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setDate(2, Date.valueOf(startDate));
                ps.setDate(3, Date.valueOf(endDate));

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    LocalDate date = rs.getDate("date").toLocalDate();
                    LocalTime start = rs.getTime("start_time").toLocalTime();
                    LocalTime end = rs.getTime("end_time").toLocalTime();
                    double minutes = java.time.Duration.between(start, end).toMillis() / 60000.0;


                    int index = 0;
                    switch (range.toLowerCase()) {
                        case "week":
                            index = (int) java.time.temporal.ChronoUnit.DAYS.between(startDate, date);
                            break;
                        case "month":
                            index = (date.getDayOfMonth() - 1) / 7;
                            break;
                        case "year":
                            index = date.getMonthValue() - 1;
                            break;
                    }

                    if (index >= 0 && index < result.size()) {
                        result.set(index, result.get(index) + minutes);
                    }
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to load summary data", e);
        }

        return new ExerciseSummaryDTO(unit, result);
    }



}
