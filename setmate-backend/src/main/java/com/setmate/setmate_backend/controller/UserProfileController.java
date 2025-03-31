package com.setmate.setmate_backend.controller;

import com.setmate.setmate_backend.DTO.UserProfileDTO;
import com.setmate.setmate_backend.model.User;
import com.setmate.setmate_backend.model.UserProfile;
import com.setmate.setmate_backend.service.UserProfileService;
import com.setmate.setmate_backend.service.UserService;
import com.setmate.setmate_backend.util.JwtUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/user-profile")
@CrossOrigin(origins = "*")
public class UserProfileController {

    private final UserProfileService userProfileService;
    private final UserService userService;
    private final JwtUtil jwtUtil;

    public UserProfileController(UserProfileService userProfileService, UserService userService, JwtUtil jwtUtil) {
        this.userProfileService = userProfileService;
        this.userService = userService;
        this.jwtUtil = jwtUtil;
    }

    @PutMapping
    public ResponseEntity<?> updateProfile(@RequestHeader("Authorization") String authHeader,
                                           @RequestBody UserProfile newProfileData) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body("Missing or invalid Authorization header");
        }

        String token = authHeader.substring(7);
        String username = jwtUtil.extractUsername(token);

        Optional<User> userOpt = userService.findByUsername(username);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body("User not found");
        }

        User user = userOpt.get();
        int userId = user.getUserId();

        // 查找是否已有 profile
        Optional<UserProfile> existingOpt = userProfileService.getByUserId(userId);
        UserProfile profile;

        if (existingOpt.isPresent()) {
            profile = existingOpt.get(); // ✅ 更新已有 profile
        } else {
            profile = new UserProfile(); // ✅ 新建一个新的
            profile.setUserId(userId);
        }

        // 设置/更新数据（只取有效字段）
        profile.setAge(newProfileData.getAge());
        profile.setHeight(newProfileData.getHeight());
        profile.setCurrentWeight(newProfileData.getCurrentWeight());
        profile.setGoalWeight(newProfileData.getGoalWeight());
        profile.setBodyFatPercentage(newProfileData.getBodyFatPercentage());

        UserProfile saved = userProfileService.saveOrUpdate(profile);
        return ResponseEntity.ok(saved);
    }


    @GetMapping
    public ResponseEntity<?> getProfile(@RequestHeader("Authorization") String authHeader) {
        System.out.println("✅ getProfile endpoint called");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body("Missing or invalid Authorization header");
        }

        String token = authHeader.substring(7);
        String username = jwtUtil.extractUsername(token);

        Optional<User> userOpt = userService.findByUsername(username);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body("User not found");
        }

        int userId = userOpt.get().getUserId();
        Optional<UserProfile> profileOpt = userProfileService.getByUserId(userId);

        if (profileOpt.isEmpty()) {
            return ResponseEntity.status(404).body("Profile not found");
        }

        UserProfile profile = profileOpt.get();
        UserProfileDTO dto = new UserProfileDTO(
                username,
                profile.getAge(),
                profile.getHeight(),
                profile.getCurrentWeight(),
                profile.getGoalWeight(),
                profile.getBodyFatPercentage()
        );

        return ResponseEntity.ok(dto);
    }

}
