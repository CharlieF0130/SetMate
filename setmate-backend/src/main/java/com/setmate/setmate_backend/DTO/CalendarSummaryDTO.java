package com.setmate.setmate_backend.DTO;

import java.time.LocalDate;

public class CalendarSummaryDTO {
    private LocalDate date;
    private String trainingTitle;

    public CalendarSummaryDTO(LocalDate date, String trainingTitle) {
        this.date = date;
        this.trainingTitle = trainingTitle;
    }

    public LocalDate getDate() {
        return date;
    }

    public String getTrainingTitle() {
        return trainingTitle;
    }
}
