package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.TrainingExercise;
import java.util.List;
import java.util.Optional;

public interface TrainingExerciseService {
    TrainingExercise addExercise(TrainingExercise exercise);
    List<TrainingExercise> getExercisesByTrainingId(Integer trainingId);
    void deleteExerciseById(Integer exerciseId);
    TrainingExercise updateExercise(TrainingExercise exercise);
    List<TrainingExercise> addExercisesBatch(List<TrainingExercise> exercises);

    // ✅ 新增：通过 exerciseId 查找单个训练动作
    Optional<TrainingExercise> getExerciseById(Integer exerciseId);
}
