package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.TrainingSession;
import com.setmate.setmate_backend.repository.TrainingSessionRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TrainingSessionServiceImpl implements TrainingSessionService {

    private final TrainingSessionRepository sessionRepository;
    // ORM
    public TrainingSessionServiceImpl(TrainingSessionRepository sessionRepository) {
        this.sessionRepository = sessionRepository;
    }

    @Override
    public TrainingSession addSession(TrainingSession session) {
        return sessionRepository.save(session);
    }

    @Override
    public List<TrainingSession> getSessionsByUserId(Integer userId) {
        return sessionRepository.findByUserId(userId);
    }

    @Override
    public Optional<TrainingSession> getSessionById(Integer trainingId) {
        return sessionRepository.findById(trainingId);
    }
    @Override
    public void deleteSessionById(Integer trainingId) {
        sessionRepository.deleteById(trainingId);
    }

} 