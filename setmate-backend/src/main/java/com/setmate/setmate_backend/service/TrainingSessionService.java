package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.TrainingSession;
import java.util.List;
import java.util.Optional;

public interface TrainingSessionService {
    TrainingSession addSession(TrainingSession session);
    List<TrainingSession> getSessionsByUserId(Integer userId);
    Optional<TrainingSession> getSessionById(Integer trainingId);
    void deleteSessionById(Integer trainingId);

}