package com.setmate.setmate_backend.controller;

import com.setmate.setmate_backend.DTO.ExerciseSummaryDTO;
import com.setmate.setmate_backend.model.User;
import com.setmate.setmate_backend.service.HistoryService;
import com.setmate.setmate_backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/summary")
@CrossOrigin(origins = "*")
public class SummaryController {

    private final HistoryService historyService;
    private final UserService userService;

    public SummaryController(HistoryService historyService, UserService userService) {
        this.historyService = historyService;
        this.userService = userService;
    }

    private String getCurrentUsername() {
        UserDetails userDetails =
                (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return userDetails.getUsername();
    }

    @GetMapping
    public ResponseEntity<ExerciseSummaryDTO> getSummary(
            @RequestParam String range,
            @RequestParam String start) {

        String username = getCurrentUsername();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        ExerciseSummaryDTO dto = historyService.getSummary(user.getUserId(), range, start);
        return ResponseEntity.ok(dto);
    }
}
