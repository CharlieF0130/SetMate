package com.setmate.setmate_backend.DTO;

import java.util.List;

public class ExerciseSummaryDTO {
    private final String unit;
    private final List<Double> values;
    private final double avgMinutes;
    private final double totalMinutes;

    public ExerciseSummaryDTO(String unit, List<Double> values) {
        this.unit = unit;
        this.values = values;
        this.totalMinutes = values.stream().mapToDouble(Double::doubleValue).sum();
        this.avgMinutes = values.isEmpty() ? 0 : totalMinutes / values.size();
    }

    public String getUnit() {
        return unit;
    }

    public List<Double> getValues() {
        return values;
    }

    public double getAvgMinutes() {
        return avgMinutes;
    }

    public double getTotalMinutes() {
        return totalMinutes;
    }
}
