package com.setmate.setmate_backend.DTO;

import com.setmate.setmate_backend.model.TrainingExercise;

import java.time.LocalTime;
import java.util.List;

public class DailyTrainingDetailDTO {
    private String trainingTitle;
    private String note;
    private LocalTime startTime;
    private LocalTime endTime;
    private List<TrainingExercise> exercises;
    private Integer trainingId;

    public DailyTrainingDetailDTO(Integer trainingId, String trainingTitle, String note,
                                  LocalTime startTime, LocalTime endTime, List<TrainingExercise> exercises) {
        this.trainingId = trainingId;
        this.trainingTitle = trainingTitle;
        this.note = note;
        this.startTime = startTime;
        this.endTime = endTime;
        this.exercises = exercises;
    }

    public Integer getTrainingId() {
        return trainingId;
    }

    public String getTrainingTitle() {
        return trainingTitle;
    }

    public String getNote() {
        return note;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public List<TrainingExercise> getExercises() {
        return exercises;
    }
}
