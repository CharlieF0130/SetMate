package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.UserProfile;

import java.util.Optional;

public interface UserProfileService {
    UserProfile saveOrUpdate(UserProfile profile);
    Optional<UserProfile> getByUserId(int userId);
}
