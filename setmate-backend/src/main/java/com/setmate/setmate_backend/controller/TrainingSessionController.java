package com.setmate.setmate_backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.setmate.setmate_backend.model.TrainingExercise;
import com.setmate.setmate_backend.model.TrainingSession;
import com.setmate.setmate_backend.model.User;
import com.setmate.setmate_backend.service.TrainingExerciseService;
import com.setmate.setmate_backend.service.TrainingSessionService;
import com.setmate.setmate_backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/training")
@CrossOrigin(origins = "*")
public class TrainingSessionController {

    private final TrainingSessionService trainingSessionService;
    private final UserService userService;

    private final TrainingExerciseService exerciseService;

    public TrainingSessionController(TrainingSessionService trainingSessionService,
                                     UserService userService,
                                     TrainingExerciseService exerciseService) {
        this.trainingSessionService = trainingSessionService;
        this.userService = userService;
        this.exerciseService = exerciseService;
    }

    @PostMapping("/add")
    public ResponseEntity<TrainingSession> addSession(@RequestBody TrainingSession session) {
        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        session.setUserId(user.getUserId());
        TrainingSession saved = trainingSessionService.addSession(session);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/my")
    public ResponseEntity<List<TrainingSession>> getMySessions() {
        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return ResponseEntity.ok(trainingSessionService.getSessionsByUserId(user.getUserId()));
    }

    private String getCurrentUsername() {
        UserDetails userDetails =
                (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return userDetails.getUsername();
    }

    /**
     * Add a training session and related exercises in one request
     */
    @PostMapping("/complete")
    public ResponseEntity<?> addTrainingWithExercises(@RequestBody Map<String, Object> payload) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            String jsonString = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(payload);
            System.out.println("📦 Received Payload from Frontend:\n" + jsonString);
        } catch (Exception e) {
            e.printStackTrace();
        }
        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Extract session info
        Map<String, Object> sessionData = (Map<String, Object>) payload.get("session");
        List<Map<String, Object>> exerciseList = (List<Map<String, Object>>) payload.get("exercises");

        TrainingSession session = new TrainingSession();
        session.setUserId(user.getUserId());
        session.setDate(LocalDate.parse((String) sessionData.get("date")));
        session.setStartTime(LocalTime.parse((String) sessionData.get("startTime")));
        session.setEndTime(LocalTime.parse((String) sessionData.get("endTime")));
        session.setNote((String) sessionData.get("note"));
        session.setTrainingTitle((String) sessionData.get("trainingTitle"));
        session.setCustomType((Boolean) sessionData.get("isCustomType"));

        TrainingSession savedSession = trainingSessionService.addSession(session);

        List<TrainingExercise> savedExercises = exerciseList.stream().map(e -> {
            TrainingExercise ex = new TrainingExercise();
            ex.setTrainingId(savedSession.getTrainingId());
            ex.setExerciseName((String) e.get("exerciseName"));
            ex.setSets((Integer) e.get("sets"));
            ex.setReps((Integer) e.get("reps"));
            ex.setWeight(((Number) e.get("weight")).doubleValue());
            ex.setRestTime((Integer) e.get("restTime"));
            ex.setType((String) e.get("type"));
            return ex;
        }).map(exerciseService::addExercise).toList();

        return ResponseEntity.ok(Map.of(
                "trainingSession", savedSession,
                "exercises", savedExercises
        ));

    }
    @DeleteMapping("/{trainingId}")
    public ResponseEntity<?> deleteTrainingSession(@PathVariable Integer trainingId) {
        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        TrainingSession session = trainingSessionService.getSessionById(trainingId)
                .orElseThrow(() -> new RuntimeException("Training session not found"));

        // 权限检查
        if (!session.getUserId().equals(user.getUserId())) {
            return ResponseEntity.status(403).body("⛔️ You do not have permission to delete this session.");
        }

        // 删除所有 exercises
        List<TrainingExercise> exercises = exerciseService.getExercisesByTrainingId(trainingId);
        exercises.forEach(e -> exerciseService.deleteExerciseById(e.getExerciseId()));

        // 删除 session 本体
        trainingSessionService.deleteSessionById(trainingId);

        return ResponseEntity.ok("✅ Training session and its exercises deleted.");
    }


}
