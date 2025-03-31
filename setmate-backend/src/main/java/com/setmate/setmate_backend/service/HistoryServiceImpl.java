package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.DTO.CalendarSummaryDTO;
import com.setmate.setmate_backend.DTO.DailyTrainingDetailDTO;
import com.setmate.setmate_backend.model.TrainingExercise;
import com.setmate.setmate_backend.model.TrainingSession;
import com.setmate.setmate_backend.repository.TrainingExerciseRepository;
import com.setmate.setmate_backend.repository.TrainingSessionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDate;
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
                        exercises.add(exercise);
                    }
                }

                dto = new DailyTrainingDetailDTO(title, note, startTime.toLocalTime(), endTime.toLocalTime(), exercises);
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
                        exercises.add(exercise);
                    }
                }

                DailyTrainingDetailDTO dto = new DailyTrainingDetailDTO(
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


}
