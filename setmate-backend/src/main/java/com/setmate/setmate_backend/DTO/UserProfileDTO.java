package com.setmate.setmate_backend.DTO;

public class UserProfileDTO {
    private String username;
    private Integer age;
    private Double height;
    private Double currentWeight;
    private Double goalWeight;
    private Double bodyFatPercentage;

    public UserProfileDTO() {
    }

    public UserProfileDTO(String username, Integer age, Double height, Double currentWeight, Double goalWeight, Double bodyFatPercentage) {
        this.username = username;
        this.age = age;
        this.height = height;
        this.currentWeight = currentWeight;
        this.goalWeight = goalWeight;
        this.bodyFatPercentage = bodyFatPercentage;
    }

    // Getters and setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public Double getHeight() {
        return height;
    }

    public void setHeight(Double height) {
        this.height = height;
    }

    public Double getCurrentWeight() {
        return currentWeight;
    }

    public void setCurrentWeight(Double currentWeight) {
        this.currentWeight = currentWeight;
    }

    public Double getGoalWeight() {
        return goalWeight;
    }

    public void setGoalWeight(Double goalWeight) {
        this.goalWeight = goalWeight;
    }

    public Double getBodyFatPercentage() {
        return bodyFatPercentage;
    }

    public void setBodyFatPercentage(Double bodyFatPercentage) {
        this.bodyFatPercentage = bodyFatPercentage;
    }
}
