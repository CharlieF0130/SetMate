package com.setmate.setmate_backend.repository;

import com.setmate.setmate_backend.model.TrainingSession;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TrainingSessionRepository extends JpaRepository<TrainingSession, Integer> {
    List<TrainingSession> findByUserId(Integer userId);
    void deleteByTrainingId(Integer trainingId);
}
