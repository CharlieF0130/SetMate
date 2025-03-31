package com.setmate.setmate_backend.repository;

import com.setmate.setmate_backend.model.TrainingExercise;
import com.setmate.setmate_backend.model.TrainingSession;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TrainingExerciseRepository extends JpaRepository<TrainingExercise, Integer> {
    List<TrainingExercise> findByTrainingId(Integer trainingId);

}
