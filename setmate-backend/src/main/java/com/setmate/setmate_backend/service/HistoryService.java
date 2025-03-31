package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.DTO.CalendarSummaryDTO;
import com.setmate.setmate_backend.DTO.DailyTrainingDetailDTO;

import java.time.YearMonth;
import java.util.List;

public interface HistoryService {
    List<CalendarSummaryDTO> getCalendarSummary(int userId, YearMonth month);
    DailyTrainingDetailDTO getTrainingDetails(int userId, String date);
    List<DailyTrainingDetailDTO> getAllTrainingDetails(int userId, String date);

}
