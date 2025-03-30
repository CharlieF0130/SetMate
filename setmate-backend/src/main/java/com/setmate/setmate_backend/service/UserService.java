package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.User;

public interface UserService {
    String register(User user);
    String login(User user);
}
