package com.setmate.setmate_backend.controller;

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

import java.util.List;

@RestController
@RequestMapping("/api/exercises")
@CrossOrigin(origins = "*")
public class TrainingExerciseController {

    private final TrainingExerciseService exerciseService;
    private final TrainingSessionService trainingSessionService;
    private final UserService userService;

    public TrainingExerciseController(TrainingExerciseService exerciseService,
                                      TrainingSessionService trainingSessionService,
                                      UserService userService) {
        this.exerciseService = exerciseService;
        this.trainingSessionService = trainingSessionService;
        this.userService = userService;
    }

    /**
     * Add a new exercise to a training session (with user validation)
     */
    @PostMapping("/add")
    public ResponseEntity<?> addExercise(@RequestBody TrainingExercise exercise) {
        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        TrainingSession session = trainingSessionService.getSessionById(exercise.getTrainingId())
                .orElseThrow(() -> new RuntimeException("Training session not found"));

        if (!session.getUserId().equals(user.getUserId())) {
            return ResponseEntity.status(403).body("Access denied: This training session does not belong to you.");
        }

        return ResponseEntity.ok(exerciseService.addExercise(exercise));
    }

    /**
     * Get all exercises for a specific training session
     */
    @GetMapping("/session/{trainingId}")
    public ResponseEntity<List<TrainingExercise>> getExercisesBySession(@PathVariable Integer trainingId) {
        return ResponseEntity.ok(exerciseService.getExercisesByTrainingId(trainingId));
    }

    /**
     * Delete an exercise by its ID
     */
    @DeleteMapping("/{exerciseId}")
    public ResponseEntity<?> deleteExercise(@PathVariable Integer exerciseId) {

        String username = getCurrentUsername();  // 从 token 获取用户名
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        TrainingExercise exercise = exerciseService.getExerciseById(exerciseId)
                .orElseThrow(() -> new RuntimeException("Exercise not found"));

        TrainingSession session = trainingSessionService.getSessionById(exercise.getTrainingId())
                .orElseThrow(() -> new RuntimeException("Training session not found"));

        System.out.println("🔍 当前登录用户: " + user.getUserId());
        System.out.println("📦 当前训练属于用户: " + session.getUserId());

        if (!session.getUserId().equals(user.getUserId())) {
            return ResponseEntity.status(403).body("⛔️ You do not have permission to delete this exercise.");
        }

        exerciseService.deleteExerciseById(exerciseId);
        return ResponseEntity.ok("✅ Exercise deleted successfully.");
    }


    /**
     * Update an existing exercise
     */
    @PutMapping("/{exerciseId}")
    public ResponseEntity<?> updateExercise(@PathVariable Integer exerciseId, @RequestBody TrainingExercise newData) {

        String username = getCurrentUsername();  // 从 token 获取用户名
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        TrainingExercise old = exerciseService.getExerciseById(exerciseId)
                .orElseThrow(() -> new RuntimeException("Exercise not found"));

        TrainingSession session = trainingSessionService.getSessionById(old.getTrainingId())
                .orElseThrow(() -> new RuntimeException("Training session not found"));
        System.out.println("🔍 当前登录用户: " + user.getUserId());
        System.out.println("📦 当前训练属于用户: " + session.getUserId());


        if (!session.getUserId().equals(user.getUserId())) {
            return ResponseEntity.status(403).body("⛔️ This exercise does not belong to you.");
             }

        // 安全验证通过，可以更新字段
        old.setExerciseName(newData.getExerciseName());
        old.setSets(newData.getSets());
        old.setReps(newData.getReps());
        old.setWeight(newData.getWeight());
        old.setRestTime(newData.getRestTime());
        old.setType(newData.getType());

        TrainingExercise updated = exerciseService.updateExercise(old);
        return ResponseEntity.ok(updated);
    }


    /**
     * Submit a list of exercises for a session
     */
    @PostMapping("/batch")
    public ResponseEntity<?> addExercisesBatch(@RequestBody List<TrainingExercise> exercises) {
        if (exercises.isEmpty()) {
            return ResponseEntity.badRequest().body("Exercise list is empty");
        }

        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Integer trainingId = exercises.get(0).getTrainingId();
        TrainingSession session = trainingSessionService.getSessionById(trainingId)
                .orElseThrow(() -> new RuntimeException("Training session not found"));

        if (!session.getUserId().equals(user.getUserId())) {
            return ResponseEntity.status(403).body("Access denied: Training session does not belong to user.");
        }

        return ResponseEntity.ok(exerciseService.addExercisesBatch(exercises));
    }

    private String getCurrentUsername() {
        UserDetails userDetails =
                (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return userDetails.getUsername();
    }
}