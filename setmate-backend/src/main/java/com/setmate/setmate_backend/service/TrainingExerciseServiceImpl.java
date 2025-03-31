package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.TrainingExercise;
import com.setmate.setmate_backend.repository.TrainingExerciseRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TrainingExerciseServiceImpl implements TrainingExerciseService {

    private final TrainingExerciseRepository exerciseRepository;

    public TrainingExerciseServiceImpl(TrainingExerciseRepository exerciseRepository) {
        this.exerciseRepository = exerciseRepository;
    }

    @Override
    public TrainingExercise addExercise(TrainingExercise exercise) {
        return exerciseRepository.save(exercise);
    }

    @Override
    public List<TrainingExercise> getExercisesByTrainingId(Integer trainingId) {
        return exerciseRepository.findByTrainingId(trainingId);
    }

    @Override
    public void deleteExerciseById(Integer exerciseId) {
        exerciseRepository.deleteById(exerciseId);
    }

    @Override
    public TrainingExercise updateExercise(TrainingExercise exercise) {
        return exerciseRepository.save(exercise);
    }

    @Override
    public List<TrainingExercise> addExercisesBatch(List<TrainingExercise> exercises) {
        return exerciseRepository.saveAll(exercises);
    }
    @Override
    public Optional<TrainingExercise> getExerciseById(Integer exerciseId) {
        return exerciseRepository.findById(exerciseId);
    }

}