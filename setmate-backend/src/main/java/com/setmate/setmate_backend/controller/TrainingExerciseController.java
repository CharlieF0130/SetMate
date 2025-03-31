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
    @DeleteMapping("/delete/{exerciseId}")
    public ResponseEntity<String> deleteExercise(@PathVariable Integer exerciseId) {
        exerciseService.deleteExerciseById(exerciseId);
        return ResponseEntity.ok("Exercise deleted successfully.");
    }

    /**
     * Update an existing exercise
     */
    @PutMapping("/update")
    public ResponseEntity<TrainingExercise> updateExercise(@RequestBody TrainingExercise exercise) {
        return ResponseEntity.ok(exerciseService.updateExercise(exercise));
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