package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.User;

import java.util.Optional;

public interface UserService {
    String register(User user);
    String login(User user);
    Optional<User> findByUsername(String username);
}
