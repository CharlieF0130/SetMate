package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.UserProfile;
import com.setmate.setmate_backend.repository.UserProfileRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserProfileServiceImpl implements UserProfileService {

    private final UserProfileRepository userProfileRepository;

    public UserProfileServiceImpl(UserProfileRepository userProfileRepository) {
        this.userProfileRepository = userProfileRepository;
    }

    @Override
    public UserProfile saveOrUpdate(UserProfile profile) {
        return userProfileRepository.save(profile);
    }

    @Override
    public Optional<UserProfile> getByUserId(int userId) {
        return userProfileRepository.findByUserId(userId);
    }
}
