package com.setmate.setmate_backend.model;

import jakarta.persistence.*;

/**
 * Represents an exercise within a training session.
 */
@Entity
@Table(name = "training_exercises", indexes = {
        @Index(name = "idx_exercise_trainingid", columnList = "trainingId")
})
public class TrainingExercise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer exerciseId;

    @Column(nullable = false)
    private Integer trainingId;

    @Column(nullable = false)
    private String exerciseName;

    @Column(nullable = false)
    private int sets;

    @Column(nullable = false)
    private int reps;


    private Double weight;      // optional
    private Integer restTime;   // optional
    @Column(name = "type", nullable = true)
    private String type;



    public Integer getExerciseId() {
        return exerciseId;
    }

    public void setExerciseId(Integer exerciseId) {
        this.exerciseId = exerciseId;
    }

    public Integer getTrainingId() {
        return trainingId;
    }

    public void setTrainingId(Integer trainingId) {
        this.trainingId = trainingId;
    }

    public String getExerciseName() {
        return exerciseName;
    }

    public void setExerciseName(String exerciseName) {
        this.exerciseName = exerciseName;
    }

    public int getSets() {
        return sets;
    }

    public void setSets(int sets) {
        this.sets = sets;
    }

    public int getReps() {
        return reps;
    }

    public void setReps(int reps) {
        this.reps = reps;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public Integer getRestTime() {
        return restTime;
    }

    public void setRestTime(Integer restTime) {
        this.restTime = restTime;
    }
    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }
}