package com.setmate.setmate_backend.controller;

import com.setmate.setmate_backend.DTO.CalendarSummaryDTO;
import com.setmate.setmate_backend.DTO.DailyTrainingDetailDTO;
import com.setmate.setmate_backend.model.User;
import com.setmate.setmate_backend.service.HistoryService;
import com.setmate.setmate_backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.YearMonth;
import java.util.List;

@RestController
@RequestMapping("/api/history")
@CrossOrigin(origins = "*")
public class HistoryController {

    @Autowired
    private HistoryService historyService;

    @Autowired
    private UserService userService;

    private String getCurrentUsername() {
        UserDetails userDetails =
                (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return userDetails.getUsername();
    }

    /**
     * 获取某月的训练日期和标题（用于日历显示 tag）
     */
    @GetMapping("/calendar")
    public ResponseEntity<List<CalendarSummaryDTO>> getTrainingDates(@RequestParam String month) {
        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        YearMonth yearMonth = YearMonth.parse(month); // 2025-03
        return ResponseEntity.ok(historyService.getCalendarSummary(user.getUserId(), yearMonth));
    }

    /**
     * 获取某天的完整训练记录（用于弹窗详情）
     */
    @GetMapping("/details")
    public ResponseEntity<DailyTrainingDetailDTO> getTrainingDetails(@RequestParam String date) {
        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return ResponseEntity.ok(historyService.getTrainingDetails(user.getUserId(), date));
    }
    @GetMapping("/details/multiple")
    public ResponseEntity<List<DailyTrainingDetailDTO>> getMultipleTrainings(@RequestParam String date) {
        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<DailyTrainingDetailDTO> list = historyService.getAllTrainingDetails(user.getUserId(), date);

        System.out.println("📅 Total Training Sessions: " + list.size());

        for (DailyTrainingDetailDTO dto : list) {
            System.out.println("📦 Training Title: " + dto.getTrainingTitle());
            System.out.println("🕐 Start Time: " + dto.getStartTime());
            for (var e : dto.getExercises()) {
                System.out.println("  - Name: " + e.getExerciseName() + ", Type: " + e.getType());
            }
        }

        return ResponseEntity.ok(list);
    }


}
