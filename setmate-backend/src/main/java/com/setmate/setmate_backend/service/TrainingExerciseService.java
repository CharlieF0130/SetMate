package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.TrainingExercise;
import java.util.List;

public interface TrainingExerciseService {
    TrainingExercise addExercise(TrainingExercise exercise);
    List<TrainingExercise> getExercisesByTrainingId(Integer trainingId);
    void deleteExerciseById(Integer exerciseId);
    TrainingExercise updateExercise(TrainingExercise exercise);
    List<TrainingExercise> addExercisesBatch(List<TrainingExercise> exercises);
}