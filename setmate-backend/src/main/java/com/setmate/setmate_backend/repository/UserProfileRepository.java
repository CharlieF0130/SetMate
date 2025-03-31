package com.setmate.setmate_backend.repository;

import com.setmate.setmate_backend.model.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserProfileRepository extends JpaRepository<UserProfile, Integer> {
    Optional<UserProfile> findByUserId(int userId);
}
