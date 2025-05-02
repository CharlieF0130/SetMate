package com.setmate.setmate_backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "user_profile", indexes = {
        @Index(name = "idx_user_profile_userid", columnList = "user_Id")
})
public class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "profile_id")
    private int profileId;

    @Column(name = "user_Id")
    private int userId;


    private Integer age;

    @Column(name = "height")
    private Double height; // 单位：cm

    @Column(name = "current_weight")
    private Double currentWeight; // 单位：kg

    @Column(name = "goal_weight")
    private Double goalWeight; // 单位：kg

    @Column(name = "body_fat_percentage")
    private Double bodyFatPercentage;// 单位：%
    @Column(name = "goal_daily_time")
    private Integer goalDailyTime;

    public Integer getGoalDailyTime() {
        return goalDailyTime;
    }

    public void setGoalDailyTime(Integer goalDailyTime) {
        this.goalDailyTime = goalDailyTime;
    }


    public UserProfile() {
    }

    public int getProfileId() {
        return profileId;
    }

    public void setProfileId(int profileId) {
        this.profileId = profileId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
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
